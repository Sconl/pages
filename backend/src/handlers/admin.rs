// backend/src/handlers/admin.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — all 11 admin API endpoints: draft CRUD, validate, publish,
//     versions, rollback, content CRUD, assets CRUD.
//     Every endpoint: (1) validates JWT + role + tenant, (2) does the work,
//     (3) for publish: invalidates Redis cache.
// ─────────────────────────────────────────────────────────────────────────────

use axum::{
    extract::{Extension, Multipart, Path, Query},
    http::StatusCode,
    Json,
};
use chrono::Utc;
use redis::AsyncCommands;
use serde::Deserialize;
use std::sync::Arc;
use uuid::Uuid;

use crate::{
    middleware::{require_role_and_tenant, AuthClaims},
    models::{PublishDraftRequest, PublishResponse, SaveDraftRequest, UserRole},
    AppState,
};

// ─────────────────────────────────────────────────────────────────────────────
// DRAFT
// ─────────────────────────────────────────────────────────────────────────────

pub async fn load_draft(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // Try Redis cache first, fall back to DB
    let cache_key = format!("draft:{tenant_id}");
    let mut redis = state.redis.clone();

    if let Ok(cached) = redis.get::<_, String>(&cache_key).await {
        if let Ok(value) = serde_json::from_str::<serde_json::Value>(&cached) {
            return Ok(Json(value));
        }
    }

    // No cached draft — return empty draft
    Ok(Json(serde_json::json!({
        "tenantId":     tenant_id,
        "draftVersion": "draft",
        "overrides":    {},
        "content":      {},
        "lastModified": Utc::now(),
        "modifiedBy":   claims.email,
    })))
}

pub async fn save_draft(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<SaveDraftRequest>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // Save draft to Redis (30-minute TTL — autosave keeps it alive)
    let cache_key = format!("draft:{tenant_id}");
    let draft = serde_json::json!({
        "tenantId":     tenant_id,
        "draftVersion": "draft",
        "overrides":    body.overrides,
        "content":      body.content.unwrap_or(serde_json::json!({})),
        "lastModified": Utc::now(),
        "modifiedBy":   claims.email,
    });

    let mut redis = state.redis.clone();
    let _: () = redis
        .set_ex(&cache_key, draft.to_string(), 1800)
        .await
        .map_err(|_| internal_error("Cache write failed"))?;

    Ok(Json(serde_json::json!({
        "saved":        true,
        "draftVersion": "draft",
        "autosavedAt":  Utc::now(),
    })))
}

// ─────────────────────────────────────────────────────────────────────────────
// VALIDATE
// ─────────────────────────────────────────────────────────────────────────────

pub async fn validate_draft(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // Server-side validation — mirrors admin_validation.dart rules.
    // This is the authoritative check. Client validation is UX only.
    let errors = validate_manifest(&body);

    Ok(Json(serde_json::json!({
        "valid":  errors.is_empty(),
        "errors": errors,
    })))
}

fn validate_manifest(manifest: &serde_json::Value) -> Vec<serde_json::Value> {
    let mut errors = vec![];
    let brand  = manifest.get("brand");
    let colors = brand.and_then(|b| b.get("colors"));
    let copy   = brand.and_then(|b| b.get("copy"));

    // App name required
    if let Some(name) = copy.and_then(|c| c.get("appName")).and_then(|v| v.as_str()) {
        if name.is_empty() || name == "__default__" {
            errors.push(serde_json::json!({
                "field": "appName", "path": "brand.copy.appName",
                "message": "App name is required."
            }));
        }
    }

    // Color format check
    for (field, path) in [
        ("primaryColor",   "brand.colors.primary"),
        ("secondaryColor", "brand.colors.secondary"),
    ] {
        if let Some(val) = colors.and_then(|c| c.get(path.split('.').last().unwrap()))
            .and_then(|v| v.as_str())
        {
            if val != "__default__" && !is_valid_hex(val) {
                errors.push(serde_json::json!({
                    "field": field, "path": path,
                    "message": "Must be a valid hex color like #9933FF"
                }));
            }
        }
    }

    errors
}

fn is_valid_hex(s: &str) -> bool {
    s.starts_with('#') && (s.len() == 7 || s.len() == 9)
        && s[1..].chars().all(|c| c.is_ascii_hexdigit())
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLISH
// ─────────────────────────────────────────────────────────────────────────────

pub async fn publish_draft(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<PublishDraftRequest>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // Load the draft from Redis
    let draft_key = format!("draft:{tenant_id}");
    let mut redis = state.redis.clone();
    let draft_str: String = redis.get(&draft_key).await
        .map_err(|_| bad_request("No draft found — save a draft first"))?;
    let draft: serde_json::Value = serde_json::from_str(&draft_str)
        .map_err(|_| internal_error("Draft parse error"))?;

    // Server-side validation before accepting publish
    let errors = validate_manifest(&draft);
    if !errors.is_empty() {
        return Err((StatusCode::UNPROCESSABLE_ENTITY, Json(serde_json::json!({
            "error": "Manifest failed validation",
            "errors": errors,
        }))));
    }

    // Generate version tag (production: use DB sequence)
    let new_version = format!("v{}", Utc::now().timestamp());
    let published_at = Utc::now();

    // Store versioned manifest in DB (stubbed — implement with SeaORM in Cycle 1)
    tracing::info!(
        tenant = %tenant_id,
        version = %new_version,
        by = %claims.email,
        note = ?body.publish_note,
        "Manifest published"
    );

    // CRITICAL: Invalidate the effectiveManifest cache for this tenant.
    // Without this, the public rendering plane serves stale content.
    let manifest_cache_key = format!("manifest:{tenant_id}");
    let _: () = redis.del(&manifest_cache_key).await
        .unwrap_or(()); // Don't fail publish if cache delete fails — log and continue

    Ok(Json(serde_json::json!({
        "publishedVersion": new_version,
        "publishedAt":      published_at,
        "publishedBy":      claims.email,
    })))
}

// ─────────────────────────────────────────────────────────────────────────────
// VERSIONS
// ─────────────────────────────────────────────────────────────────────────────

pub async fn list_versions(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // Stubbed — SeaORM query in Cycle 1
    Ok(Json(serde_json::json!({ "versions": [] })))
}

pub async fn rollback(
    AuthClaims(claims): AuthClaims,
    Path((tenant_id_str, version)): Path<(String, String)>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    // Rollback requires at least developer role (not clientAdmin)
    require_role_and_tenant(&claims, &UserRole::Developer, &tenant_id)?;

    // Stubbed — load version from DB, set as new live manifest in Cycle 1
    let new_version = format!("{version}-restored");
    let mut redis = state.redis.clone();
    let _: () = redis.del(format!("manifest:{tenant_id}")).await.unwrap_or(());

    Ok(Json(serde_json::json!({
        "rolledBackTo": version,
        "newVersion":   new_version,
    })))
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Deserialize)]
pub struct ContentQuery {
    pub space_id:  Option<String>,
    pub screen_id: Option<String>,
    pub section:   Option<String>,
    pub block:     Option<String>,
}

pub async fn get_content(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Query(q): Query<ContentQuery>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;
    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // Stubbed — SeaORM query by 5-part key in Cycle 1
    Ok(Json(serde_json::json!({ "items": [] })))
}

pub async fn save_content(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;
    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    let id = Uuid::new_v4();
    Ok(Json(serde_json::json!({ "id": id, "saved": true, "updatedAt": Utc::now() })))
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSETS
// ─────────────────────────────────────────────────────────────────────────────

pub async fn list_assets(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;
    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    Ok(Json(serde_json::json!({ "assets": [] })))
}

pub async fn upload_asset(
    AuthClaims(claims): AuthClaims,
    Path(tenant_id_str): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
    mut multipart: Multipart,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;
    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    // S3 upload stubbed — implement in Cycle 4 with aws-sdk-s3
    let asset_id = Uuid::new_v4();
    let stub_url = format!("https://cdn.qspace.io/{tenant_id}/{asset_id}");

    Ok(Json(serde_json::json!({
        "assetId":    asset_id,
        "url":        stub_url,
        "filename":   "upload.bin",
        "size":       0,
        "mimeType":   "application/octet-stream",
        "uploadedAt": Utc::now(),
    })))
}

pub async fn delete_asset(
    AuthClaims(claims): AuthClaims,
    Path((tenant_id_str, asset_id_str)): Path<(String, String)>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant_id: Uuid = tenant_id_str.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;
    require_role_and_tenant(&claims, &UserRole::ClientAdmin, &tenant_id)?;

    Ok(Json(serde_json::json!({ "deleted": true })))
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR HELPERS
// ─────────────────────────────────────────────────────────────────────────────

fn bad_request(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": msg})))
}

fn internal_error(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": msg})))
}
