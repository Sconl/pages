// lib/interface/app_router.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. GoRouter with auth redirect guards.
//   v2.0.0 — Router implementation moved to lib/core/router/app_router.dart
//             per canon evolution. This file is now a thin re-export so any
//             existing consumer (QPagesApp) doesn't need to change its import.
// ─────────────────────────────────────────────────────────────────────────────
//
// Do not add logic here. The real implementation is in lib/core/router/.

export 'package:qspace_pages/core/router/app_router.dart';
export 'package:qspace_pages/core/router/router_config.dart';