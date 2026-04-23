// lib/core/router/router_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Injectable router configuration.
//             QRouterConfig lets any main_*.dart or ProviderScope override
//             inject extra routes and redirect logic without touching app_router.dart.
//             routerConfigProvider must be overridden in ProviderScope if defaults
//             aren't sufficient — same pattern as authAdapterProvider.
// ─────────────────────────────────────────────────────────────────────────────
//
// Why this exists:
//   The core router handles canon routes (auth, home, admin). But a tenant might
//   need /onboarding, /checkout, or a custom redirect rule. Rather than forking
//   app_router.dart, they inject a QRouterConfig with the extras here.
//   app_router.dart reads routerConfigProvider and merges the extras in.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QRouterRedirectFn
// ─────────────────────────────────────────────────────────────────────────────

// Signature for tenant/client-provided extra redirect logic.
// Called after the core auth guards pass. Return null to allow navigation.
// Return a path string to redirect.
typedef QRouterRedirectFn = String? Function(
  QAuthSession? session,
  String location,
);

// ─────────────────────────────────────────────────────────────────────────────
// QRouterConfig
// ─────────────────────────────────────────────────────────────────────────────

class QRouterConfig {
  // Where the app starts when the user hasn't navigated anywhere yet.
  final String initialLocation;

  // Extra routes to append after the canon routes (auth, home, admin).
  // Use this to add tenant-specific pages (/onboarding, /checkout, etc.)
  // without forking app_router.dart.
  final List<RouteBase> extraRoutes;

  // Optional extra redirect logic that runs after core auth guards pass.
  // Return null to allow. Return a path to redirect.
  // This is the right place for tenant-specific access rules.
  final QRouterRedirectFn? extraRedirect;

  const QRouterConfig({
    this.initialLocation = '/',
    this.extraRoutes     = const [],
    this.extraRedirect,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// routerConfigProvider
// ─────────────────────────────────────────────────────────────────────────────

// Default is the empty config — all canon routes, no extras.
// Override in ProviderScope to inject tenant-specific routes or redirect rules.
final routerConfigProvider = Provider<QRouterConfig>(
  (ref) => const QRouterConfig(),
);