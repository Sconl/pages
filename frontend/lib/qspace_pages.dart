// frontend/lib/qspace_pages.dart
// Public API of the qspace_pages package.
// Clients import ONLY this file. Never import internal paths directly.

// ── Bootstrap ─────────────────────────────────────────────────────────────────
export 'app/app_root.dart';
export 'app/app_shell.dart';

// ── Client Configuration ───────────────────────────────────────────────────────
export 'core/config/app_client_config.dart';

// ── Style System (already a barrel — re-export it wholesale) ──────────────────
export 'core/style/app_style.dart';

// ── Navigation (already a barrel — re-export it wholesale) ───────────────────
// export 'core/nav/app_nav.dart';

// ── Auth Contracts ────────────────────────────────────────────────────────────
export 'core/auth/auth_port.dart';
export 'core/auth/auth_session.dart';
export 'core/auth/auth_policy.dart';
export 'core/auth/auth_config.dart';

// ── Auth Adapters (clients choose one and pass it via AppClientConfig) ─────────
export 'core/auth/auth_adapters/rest_jwt_auth_provider.dart';
export 'core/auth/auth_adapters/firebase_auth_provider.dart';

// ── Admin Layer ───────────────────────────────────────────────────────────────
export 'core/admin/admin_config.dart';
export 'core/admin/admin_brand_draft.dart';
export 'core/admin/admin_screen_registry.dart';
export 'core/admin/dev_screen_settings.dart';

// ── Canon Identifiers ──────────────────────────────────────────────────────────
// export 'canon/canon_ids.dart';

// ── Merge Engine (export when stubs are implemented — comment out until then) ──
// export 'core/merge/merge_engine.dart';

// ── NOT exported (internal implementation — clients never touch these) ─────────
// lib/canon/spaces/        universal space implementations
// lib/suite/               suite implementations
// lib/infrastructure/      adapter implementations
// lib/client/              qspace's own tenant config
// lib/main.dart            qspace's own entry point