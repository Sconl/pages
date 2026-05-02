// lib/core/config/app_publishing_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Publishing model enums + PublishJobSummary +
//             TenantPublishingStatus. Flutter-side mirror of publish_jobs
//             and TenantPublishConfig DB tables.
//   v1.0.1 — Fixed: [this.id] markdown artifact → this.id.
// ─────────────────────────────────────────────────────────────────────────────
//
// These types are populated from two API endpoints:
//   GET /api/publish/config/{tenantId}  → TenantPublishingStatus
//   GET /api/publish/jobs/{tenantId}    → List<PublishJobSummary>

// ─────────────────────────────────────────────────────────────────────────────
// AppPublishingModel
// ─────────────────────────────────────────────────────────────────────────────

/// Which publishing model this tenant uses.
/// Resolved from TenantPublishConfig stored in the database.
/// The Flutter app receives this from GET /api/publish/config/{tenantId}.
enum AppPublishingModel {
  /// Model 0 — tenant's brand served inside the QPages app at runtime.
  /// Default for all tiers. No per-tenant build.
  qpagesApp,

  /// Model A — standalone app on Play Store, published under QPages'
  /// developer account. Per-tenant build pipeline. Business+ tier.
  qpagesPublisher,

  /// Model B — standalone app published to tenant's own developer account.
  /// Enterprise tier only.
  tenantPublisher,
}

// ─────────────────────────────────────────────────────────────────────────────
// PublishPlatform
// ─────────────────────────────────────────────────────────────────────────────

/// Which platform a publish job targets.
enum PublishPlatform {
  web,
  android,
  windows,
  linux,
  ios, // Future — Cycle 5+
}

// ─────────────────────────────────────────────────────────────────────────────
// PublishJobStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Status of a single publish job run.
enum PublishJobStatus {
  queued,
  building,
  signing,
  uploading,
  submitted,
  live,
  failed,
}

// ─────────────────────────────────────────────────────────────────────────────
// PublishJobSummary
// ─────────────────────────────────────────────────────────────────────────────

/// Flutter-side summary of a single publish job.
/// Maps from the publish_jobs database table via GET /api/publish/jobs/{tenantId}.
class PublishJobSummary {
  final String           id;
  final PublishPlatform  platform;
  final PublishJobStatus status;
  final String           versionName;
  final DateTime         createdAt;
  final DateTime?        completedAt;
  final String?          errorMessage;

  /// CDN download URL (desktop) or Play Store URL (Android).
  final String? outputUrl;

  /// Link to the GitHub Actions run log — useful for debugging.
  final String? githubRunUrl;

  const PublishJobSummary({
    required this.id,
    required this.platform,
    required this.status,
    required this.versionName,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.outputUrl,
    this.githubRunUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TenantPublishingStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Flutter-side representation of a tenant's full publishing status.
/// Returned by GET /api/publish/config/{tenantId}.
class TenantPublishingStatus {
  final AppPublishingModel model;

  // ── Web ───────────────────────────────────────────────────────────────────
  final bool      webLive;
  final String?   webUrl;
  final DateTime? webLastPublishedAt;

  // ── QPages App (Model 0) — always present ─────────────────────────────────
  /// https://qpages.io/app/{tenantId}
  final String deepLinkUrl;

  /// qpages://t/{tenantId}
  final String deepLinkScheme;

  // ── Android (Model A / B) ─────────────────────────────────────────────────
  final bool      androidEnabled;
  final String?   androidPackageName;
  final String?   androidPlayStoreUrl;
  final String?   androidCurrentVersion;
  final DateTime? androidLastPublishedAt;

  // ── Desktop ───────────────────────────────────────────────────────────────
  final bool    windowsEnabled;
  final String? windowsDownloadUrl;
  final String? windowsCurrentVersion;

  final bool    linuxEnabled;
  final String? linuxDownloadUrl;
  final String? linuxCurrentVersion;

  // ── Recent jobs across all platforms ─────────────────────────────────────
  final List<PublishJobSummary> recentJobs;

  const TenantPublishingStatus({
    required this.model,
    required this.webLive,
    this.webUrl,
    this.webLastPublishedAt,
    required this.deepLinkUrl,
    required this.deepLinkScheme,
    this.androidEnabled          = false,
    this.androidPackageName,
    this.androidPlayStoreUrl,
    this.androidCurrentVersion,
    this.androidLastPublishedAt,
    this.windowsEnabled          = false,
    this.windowsDownloadUrl,
    this.windowsCurrentVersion,
    this.linuxEnabled            = false,
    this.linuxDownloadUrl,
    this.linuxCurrentVersion,
    this.recentJobs              = const [],
  });
}