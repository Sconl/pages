// backend/src/main.rs

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — Axum server: health, tenant, manifest, admin API routes.
//     CORS configured for Flutter web client. State injected via Extension.
// ─────────────────────────────────────────────────────────────────────────────

use axum::{
    extract::Extension,
    http::{HeaderValue, Method},
    routing::{delete, get, post, put},
    Router,
};
use sea_orm::DatabaseConnection;
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod handlers;
mod middleware;
mod models;

use handlers::{admin, auth, manifest, tenant};

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const DEFAULT_PORT: u16 = 8080;

// ─────────────────────────────────────────────────────────────────────────────
// APP STATE
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Clone)]
pub struct AppState {
    pub db:    DatabaseConnection,
    pub redis: redis::aio::ConnectionManager,
    pub jwt_secret: String,
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Load .env (never commit .env — use .env.example for documentation)
    dotenvy::dotenv().ok();

    // Tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "info".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Database
    let db_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");
    let db = sea_orm::Database::connect(&db_url).await?;
    tracing::info!("Database connected");

    // Redis
    let redis_url = std::env::var("REDIS_URL")
        .unwrap_or_else(|_| "redis://127.0.0.1:6379".to_string());
    let redis_client = redis::Client::open(redis_url)?;
    let redis = redis::aio::ConnectionManager::new(redis_client).await?;
    tracing::info!("Redis connected");

    let jwt_secret = std::env::var("JWT_SECRET")
        .expect("JWT_SECRET must be set — min 32 chars");

    let state = Arc::new(AppState { db, redis, jwt_secret });

    // CORS — allow Flutter web client origin
    let cors = CorsLayer::new()
        .allow_origin(
            std::env::var("ALLOWED_ORIGIN")
                .unwrap_or_else(|_| "http://localhost:5000".into())
                .parse::<HeaderValue>()
                .unwrap(),
        )
        .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
        .allow_headers(Any);

    let app = Router::new()
        // ── Health ─────────────────────────────────────────────────────────
        .route("/health", get(health))

        // ── Auth ───────────────────────────────────────────────────────────
        .route("/api/auth/register", post(auth::register))
        .route("/api/auth/login",    post(auth::login))

        // ── Tenants ────────────────────────────────────────────────────────
        .route("/api/tenants",     post(tenant::create))
        .route("/api/tenants/:id", get(tenant::get))

        // ── Manifest (public rendering plane) ──────────────────────────────
        .route("/manifest",          get(manifest::get_effective))
        .route("/manifest/validate", post(manifest::validate))

        // ── Admin API (control plane) ───────────────────────────────────────
        // All /api/admin/* routes validated by auth middleware (JWT + role + tenant)
        .route("/api/admin/draft/:tenant_id",
            get(admin::load_draft).put(admin::save_draft))
        .route("/api/admin/draft/:tenant_id/validate",
            post(admin::validate_draft))
        .route("/api/admin/draft/:tenant_id/publish",
            post(admin::publish_draft))
        .route("/api/admin/versions/:tenant_id",
            get(admin::list_versions))
        .route("/api/admin/rollback/:tenant_id/:version",
            post(admin::rollback))
        .route("/api/admin/content/:tenant_id",
            get(admin::get_content).put(admin::save_content))
        .route("/api/admin/assets/:tenant_id",
            get(admin::list_assets).post(admin::upload_asset))
        .route("/api/admin/assets/:tenant_id/:asset_id",
            delete(admin::delete_asset))

        // ── Waitlist ────────────────────────────────────────────────────────
        .route("/api/waitlist", post(manifest::waitlist_signup))

        .layer(cors)
        .layer(Extension(state));

    let port = std::env::var("PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(DEFAULT_PORT);

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{port}")).await?;
    tracing::info!("QSpace backend listening on port {port}");
    axum::serve(listener, app).await?;
    Ok(())
}

async fn health() -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!({ "status": "ok", "service": "qspace-backend" }))
}
