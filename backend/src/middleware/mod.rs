// backend/src/middleware/mod.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — JWT extractor, role check, tenant scope validation.
//     Every admin route goes through this. Server-side is the authority —
//     client-side PermissionGuard is UX only.
// ─────────────────────────────────────────────────────────────────────────────

use axum::{
    extract::{FromRequestParts, Path},
    http::{request::Parts, StatusCode},
    Json,
};
use jsonwebtoken::{decode, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::models::UserRole;

// ─────────────────────────────────────────────────────────────────────────────
// JWT CLAIMS
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub:       String,          // user id
    pub email:     String,
    pub role:      UserRole,
    pub tenant_id: Uuid,
    pub exp:       usize,           // unix timestamp
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH EXTRACTOR
// ─────────────────────────────────────────────────────────────────────────────

/// Extracts and validates the JWT from Authorization: Bearer <token>.
/// Fails with 401 if missing, expired, or invalid.
/// Never passes sensitive details to the client in the error body.
pub struct AuthClaims(pub Claims);

#[axum::async_trait]
impl<S> FromRequestParts<S> for AuthClaims
where
    S: Send + Sync,
{
    type Rejection = (StatusCode, Json<serde_json::Value>);

    async fn from_request_parts(
        parts: &mut Parts,
        _state: &S,
    ) -> Result<Self, Self::Rejection> {
        let auth_header = parts
            .headers
            .get("Authorization")
            .and_then(|v| v.to_str().ok())
            .ok_or_else(|| unauthorized("Missing Authorization header"))?;

        let token = auth_header
            .strip_prefix("Bearer ")
            .ok_or_else(|| unauthorized("Invalid Authorization format"))?;

        // JWT_SECRET comes from AppState — we read it from request extensions
        let secret = parts
            .extensions
            .get::<std::sync::Arc<crate::AppState>>()
            .map(|s| s.jwt_secret.clone())
            .ok_or_else(|| internal_error("Auth config missing"))?;

        let claims = decode::<Claims>(
            token,
            &DecodingKey::from_secret(secret.as_bytes()),
            &Validation::default(),
        )
        .map_err(|_| unauthorized("Invalid or expired token"))?
        .claims;

        Ok(AuthClaims(claims))
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE GUARD
// ─────────────────────────────────────────────────────────────────────────────

/// Verify that [claims] has at least [required] role AND is scoped to [tenant_id].
/// Call this at the top of every admin handler.
pub fn require_role_and_tenant(
    claims: &Claims,
    required: &UserRole,
    tenant_id: &Uuid,
) -> Result<(), (StatusCode, Json<serde_json::Value>)> {
    // Tenant scope — a developer from tenant A must never touch tenant B
    if &claims.tenant_id != tenant_id {
        return Err(forbidden("Tenant scope mismatch"));
    }

    let ok = match required {
        UserRole::ClientAdmin => true, // any role is >= clientAdmin
        UserRole::Developer   => matches!(claims.role, UserRole::Developer | UserRole::Architect),
        UserRole::Architect   => matches!(claims.role, UserRole::Architect),
    };

    if !ok {
        return Err(forbidden("Insufficient role"));
    }

    Ok(())
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR HELPERS — generic messages only, no internals leaked to client
// ─────────────────────────────────────────────────────────────────────────────

fn unauthorized(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::UNAUTHORIZED, Json(serde_json::json!({"error": msg})))
}

fn forbidden(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::FORBIDDEN, Json(serde_json::json!({"error": msg})))
}

fn internal_error(msg: &'static str) -> (StatusCode, Json<serde_json::Value>) {
    (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": msg})))
}
