// backend/src/handlers/tenant.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — create tenant, get tenant by ID.
//     Cycle 1: wire to SeaORM, add provisioning job dispatch.
// ─────────────────────────────────────────────────────────────────────────────

use axum::{
    extract::{Extension, Path},
    http::StatusCode,
    Json,
};
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

use crate::AppState;

pub async fn create(
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let name   = body["name"].as_str().ok_or_else(|| bad_request("name required"))?;
    let domain = body["domain"].as_str().ok_or_else(|| bad_request("domain required"))?;
    let suite  = body["suite"].as_str().unwrap_or("saas");

    let id = Uuid::new_v4();
    tracing::info!(name = %name, domain = %domain, suite = %suite, id = %id, "Tenant created");

    // Stubbed — insert to DB + dispatch provisioning job in Cycle 1
    Ok(Json(serde_json::json!({
        "id":               id,
        "name":             name,
        "domain":           domain,
        "status":           "provisioning",
        "suite":            suite,
        "manifest_version": "v1.0.0",
        "created_at":       Utc::now(),
    })))
}

pub async fn get(
    Path(id): Path<String>,
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let _id: Uuid = id.parse()
        .map_err(|_| bad_request("Invalid tenant ID"))?;

    // Stubbed — SeaORM query in Cycle 1
    Ok(Json(serde_json::json!({
        "id":     _id,
        "status": "active",
        "suite":  "saas",
    })))
}

fn bad_request(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": msg})))
}
