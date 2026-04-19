// backend/src/handlers/auth.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — register, login. bcrypt password hashing, JWT signing.
//     Error messages are generic — never leak DB errors or user existence.
// ─────────────────────────────────────────────────────────────────────────────

use axum::{extract::Extension, http::StatusCode, Json};
use chrono::Utc;
use jsonwebtoken::{encode, EncodingKey, Header};
use std::sync::Arc;

use crate::{
    middleware::Claims,
    models::{LoginRequest, LoginResponse, UserRole, UserSummary},
    AppState,
};

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const TOKEN_EXPIRY_SECS: i64 = 86_400; // 24 hours

// ─────────────────────────────────────────────────────────────────────────────
// REGISTER
// ─────────────────────────────────────────────────────────────────────────────

pub async fn register(
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<serde_json::Value>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let email = body["email"].as_str()
        .ok_or_else(|| bad_request("email required"))?;
    let password = body["password"].as_str()
        .ok_or_else(|| bad_request("password required"))?;
    let name = body["name"].as_str().unwrap_or("New User");

    if password.len() < 8 {
        return Err(bad_request("Password must be at least 8 characters"));
    }

    // Hash password — bcrypt cost 12 is a reasonable default for 2026 hardware
    let hash = bcrypt::hash(password, 12)
        .map_err(|_| internal_error("Registration failed"))?;

    // Stubbed — insert into DB via SeaORM in Cycle 1
    let user_id = uuid::Uuid::new_v4();
    tracing::info!(email = %email, id = %user_id, "User registered");

    Ok(Json(serde_json::json!({
        "id":         user_id,
        "email":      email,
        "name":       name,
        "created_at": Utc::now(),
    })))
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────────────────────────────────────

pub async fn login(
    Extension(state): Extension<Arc<AppState>>,
    Json(body): Json<LoginRequest>,
) -> Result<Json<LoginResponse>, (StatusCode, Json<serde_json::Value>)> {
    // Stubbed DB lookup — replace with SeaORM query in Cycle 1.
    // For now: accept any credentials and return an architect-level token
    // for the qspace tenant. This powers the dev admin panel.
    //
    // NEVER ship this stub to production. The SeaORM query must:
    //   1. Find user by email
    //   2. Verify bcrypt hash
    //   3. Return actual role and tenant_id from DB record

    let user_id   = uuid::Uuid::new_v4();
    let tenant_id = uuid::Uuid::new_v4();
    let role      = UserRole::Architect; // dev stub — real DB sets this

    let expires_at = Utc::now() + chrono::Duration::seconds(TOKEN_EXPIRY_SECS);

    let claims = Claims {
        sub:       user_id.to_string(),
        email:     body.email.clone(),
        role:      role.clone(),
        tenant_id,
        exp:       expires_at.timestamp() as usize,
    };

    let token = encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(state.jwt_secret.as_bytes()),
    )
    .map_err(|_| internal_error("Token generation failed"))?;

    tracing::info!(email = %body.email, "Login successful");

    Ok(Json(LoginResponse {
        token,
        expires_at,
        user: UserSummary {
            id:    user_id,
            email: body.email,
            role,
        },
    }))
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

fn bad_request(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::BAD_REQUEST, Json(serde_json::json!({"error": msg})))
}

fn internal_error(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": msg})))
}
