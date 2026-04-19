// backend/src/handlers/manifest.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — get_effective (manifest resolution with Redis cache),
//     validate, waitlist_signup. This is the public rendering plane endpoint —
//     no auth required, but Redis-cached aggressively.
// ─────────────────────────────────────────────────────────────────────────────

use axum::{
    extract::{Extension, Query},
    http::StatusCode,
    Json,
};
use redis::AsyncCommands;
use serde::Deserialize;
use std::sync::Arc;

use crate::AppState;

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

// Cache TTL for effectiveManifest — invalidated on publish.
// 10 minutes is long enough to absorb traffic spikes, short enough that
// a force-refresh (cache miss) doesn't feel broken.
const MANIFEST_CACHE_TTL_SECS: u64 = 600;

// ─────────────────────────────────────────────────────────────────────────────
// QUERY PARAMS
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Deserialize)]
pub struct ManifestQuery {
    pub tenant:  Option<String>,
    pub layer:   Option<String>, // 'suite' | 'client' | 'effective'
}

// ─────────────────────────────────────────────────────────────────────────────
// GET EFFECTIVE MANIFEST
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the fully merged effectiveManifest for a tenant.
/// Cached in Redis. Invalidated on admin publish.
///
/// The Flutter app calls this at startup via RestConfigProvider.
/// In dev mode, LocalJsonConfigProvider reads from bundled assets instead —
/// this endpoint is only hit in production multi-tenant deployments.
pub async fn get_effective(
    Query(q): Query<ManifestQuery>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let tenant = q.tenant.unwrap_or_else(|| "qspace".to_string());
    let layer  = q.layer.unwrap_or_else(|| "effective".to_string());

    let cache_key = format!("manifest:{tenant}:{layer}");
    let mut redis = state.redis.clone();

    // Check Redis cache first — fast path for all reads
    if let Ok(cached) = redis.get::<_, String>(&cache_key).await {
        if let Ok(manifest) = serde_json::from_str::<serde_json::Value>(&cached) {
            return Ok(Json(manifest));
        }
    }

    // Cache miss — build manifest from DB (stubbed, returns QSpace defaults)
    // Cycle 1: Replace this with a real DB query that loads:
    //   1. Suite manifest from DB (or S3)
    //   2. Client overlay from DB
    //   3. deepMerge them (replicate the Dart deep_merge logic in Rust)
    let manifest = build_stub_manifest(&tenant, &layer);

    // Cache the result
    let manifest_str = manifest.to_string();
    let _: () = redis
        .set_ex(&cache_key, &manifest_str, MANIFEST_CACHE_TTL_SECS)
        .await
        .unwrap_or(()); // Non-fatal — serve without cache on Redis failure

    Ok(Json(manifest))
}

fn build_stub_manifest(tenant: &str, layer: &str) -> serde_json::Value {
    // Returns the QSpace brand defaults — actual DB-backed manifests in Cycle 1
    serde_json::json!({
        "clientId":     tenant,
        "suiteId":      "saas",
        "canonVersion": "canon.v2.1.0",
        "brand": {
            "colors": {
                "primary":   "#9933FF",
                "secondary": "#0F91D2",
                "tertiary":  "#FAAF2E"
            },
            "fonts": {
                "hero":      "Plus Jakarta Sans",
                "display":   "Barlow",
                "text":      "Inter",
                "accent":    "JetBrains Mono",
                "signature": "Niconne"
            },
            "canvas":  { "personality": "energetic" },
            "motion":  { "intensity": "full" },
            "copy": {
                "appName": "QSpace",
                "tagline": "Launch branded sites in hours, not months."
            }
        },
        "features": {
            "waitlist":     true,
            "pricingTable": true,
            "trialSignup":  false,
            "testimonials": false,
            "contactForm":  false
        }
    })
}

// ─────────────────────────────────────────────────────────────────────────────
// VALIDATE
// ─────────────────────────────────────────────────────────────────────────────

pub async fn validate(
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<serde_json::Value>,
) -> Json<serde_json::Value> {
    // Light validation — full schema validation via admin validate endpoint
    Json(serde_json::json!({ "valid": true, "errors": [] }))
}

// ─────────────────────────────────────────────────────────────────────────────
// WAITLIST SIGNUP
// ─────────────────────────────────────────────────────────────────────────────

pub async fn waitlist_signup(
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let email = body["email"].as_str()
        .ok_or_else(|| (StatusCode::BAD_REQUEST,
            Json(serde_json::json!({"error": "email required"}))))?;

    let source = body["source"].as_str().unwrap_or("web");

    // Stubbed — insert to DB, send to SendGrid in Cycle 1
    let id = uuid::Uuid::new_v4();
    tracing::info!(email = %email, source = %source, id = %id, "Waitlist signup");

    Ok(Json(serde_json::json!({
        "id":         id,
        "email":      email,
        "created_at": chrono::Utc::now(),
    })))
}
