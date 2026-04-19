// backend/src/models/mod.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — Tenant, ManifestVersion, ContentRecord, Asset, AuthUser models.
//     These map to PostgreSQL tables via SeaORM.
// ─────────────────────────────────────────────────────────────────────────────

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

// ─────────────────────────────────────────────────────────────────────────────
// TENANT
// ─────────────────────────────────────────────────────────────────────────────

/// A single QSpace Pages tenant (one site deployment).
/// The clientId here matches the 'clientId' key in overlay.json.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Tenant {
    pub id:              Uuid,
    pub client_id:       String,   // 'qspace', 'acme', etc.
    pub name:            String,
    pub domain:          String,   // 'qspace.io', 'acme.qspace.io'
    pub suite_id:        String,   // 'saas', 'corporate', etc.
    pub status:          TenantStatus,
    pub created_at:      DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum TenantStatus {
    Active,
    Suspended,
    Provisioning,
}

// ─────────────────────────────────────────────────────────────────────────────
// MANIFEST VERSION
// ─────────────────────────────────────────────────────────────────────────────

/// One published version of a tenant's manifest overlay.
/// Every publish creates a new record — this is the audit trail and rollback source.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ManifestVersion {
    pub id:              Uuid,
    pub tenant_id:       Uuid,
    pub version_tag:     String,         // 'v1.0.1', 'v1.0.2', etc.
    pub manifest_json:   serde_json::Value,  // the full overlay at publish time
    pub published_by:    String,         // user email
    pub publish_note:    Option<String>,
    pub created_at:      DateTime<Utc>,
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT RECORD
// ─────────────────────────────────────────────────────────────────────────────

/// A single content entry keyed by the canonical 5-part key.
/// Matches AdminMapper.contentPath() — never store a partial key.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContentRecord {
    pub id:          Uuid,
    pub tenant_id:   Uuid,
    pub space_id:    String,    // 'space_value'
    pub screen_id:   String,    // 'screen_entry'
    pub section_id:  String,    // 'core'
    pub block_id:    String,    // 'hero'
    pub property:    String,    // 'headline'
    pub value:       String,
    pub updated_at:  DateTime<Utc>,
    pub updated_by:  String,
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSET
// ─────────────────────────────────────────────────────────────────────────────

/// A tenant-scoped uploaded asset.
/// url is the persistent CDN URL written to overlay content fields.
/// Never store a local file path — always a fully-qualified CDN URL.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Asset {
    pub asset_id:    Uuid,
    pub tenant_id:   Uuid,
    pub url:         String,     // https://cdn.qspace.io/…
    pub filename:    String,
    pub size:        i64,        // bytes
    pub mime_type:   String,
    pub uploaded_at: DateTime<Utc>,
    pub uploaded_by: String,
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH USER
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthUser {
    pub id:        Uuid,
    pub email:     String,
    pub role:      UserRole,
    pub tenant_id: Uuid,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum UserRole {
    ClientAdmin,
    Developer,
    Architect,
}

// ─────────────────────────────────────────────────────────────────────────────
// API REQUEST / RESPONSE TYPES
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub email:    String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub token:      String,
    pub expires_at: DateTime<Utc>,
    pub user:       UserSummary,
}

#[derive(Debug, Serialize)]
pub struct UserSummary {
    pub id:    Uuid,
    pub email: String,
    pub role:  UserRole,
}

#[derive(Debug, Deserialize)]
pub struct SaveDraftRequest {
    pub overrides: serde_json::Value,
    pub content:   Option<serde_json::Value>,
}

#[derive(Debug, Deserialize)]
pub struct PublishDraftRequest {
    pub draft_version: String,
    pub publish_note:  Option<String>,
}

#[derive(Debug, Serialize)]
pub struct PublishResponse {
    pub published_version: String,
    pub published_at:      DateTime<Utc>,
    pub published_by:      String,
}

#[derive(Debug, Serialize)]
pub struct DraftResponse {
    pub tenant_id:     Uuid,
    pub draft_version: String,
    pub overrides:     serde_json::Value,
    pub content:       serde_json::Value,
    pub last_modified: DateTime<Utc>,
    pub modified_by:   String,
}
