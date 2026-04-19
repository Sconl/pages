// lib/core/router/app_router.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Comprehensive GoRouter with auth redirect guards.
//             Moved from lib/interface/app_router.dart per canvas v2.2.0 evolution.
//             lib/interface/app_router.dart is now a thin re-export of this file.
//   v1.1.0 — Role-aware post-login routing via QAuthConfig.postLoginRoutes.
//             QRouterConfig injection for extra routes + extra redirect.
//             AppPageTransitions applied to all route builders.
//             Named route constants consolidated here (from auth_policy.dart).
// ─────────────────────────────────────────────────────────────────────────────
//
// Route structure:
//   /login              → screen_login.dart         (unauthenticated only)
//   /signup             → screen_signup.dart         (unauthenticated only)
//   /reset-password     → screen_reset.dart          (unauthenticated only)
//   /                   → _PlaceholderHome           (public — replace Cycle 1)
//   /admin              → redirect to /admin/overview
//   /admin/overview     → placeholder                (clientAdmin+ — replace Cycle 3)
//   /admin/content      → placeholder                (clientAdmin+)
//   /admin/brand        → placeholder                (clientAdmin+)
//   /admin/assets       → placeholder                (clientAdmin+)
//   /admin/features     → placeholder                (clientAdmin+)
//   /admin/preview      → placeholder                (clientAdmin+)
//   + extraRoutes from QRouterConfig
//
// Redirect priority (top wins):
//   1. Logged in + on auth route → QAuthConfig.postLoginRoutes or defaultHomeFor(role)
//   2. Not logged in + protected route → /login?redirect=...
//   3. Logged in + admin route + role too low → /
//   4. QRouterConfig.extraRedirect (tenant-specific logic)
//   5. Allow (null)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_policy.dart';
import '../auth/auth_config.dart';
import '../../spaces/space_auth/screens/screen_login.dart';
import '../../spaces/space_auth/screens/screen_signup.dart';
import '../../spaces/space_auth/screens/screen_reset.dart';
import '../../spaces/space_auth/state/auth_riverpod.dart';
import '../../spaces/space_admin/shell_admin/q_admin_shell.dart';
import 'router_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Navigator keys ──
final _kRootNavKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final _kAdminNavKey = GlobalKey<NavigatorState>(debugLabel: 'admin');

// ─────────────────────────────────────────────────────────────────────────────
// routerProvider
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final routerConfig = ref.read(routerConfigProvider);
  final refreshNotifier = _AuthChangeNotifier();

  // Re-run redirect whenever auth state changes.
  // This handles sign-in (→ route to home/admin) and sign-out (→ route to login).
  ref.listen(authSessionProvider, (_, __) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey:      _kRootNavKey,
    initialLocation:   routerConfig.initialLocation,
    refreshListenable: refreshNotifier,
    redirect:          (context, state) => _redirect(ref, routerConfig, state),
    routes: [
      // ── Auth routes (unauthenticated only) ──────────────────────────────
      GoRoute(
        path:        kRouteLogin,
        pageBuilder: (ctx, state) => AppPageTransitions.fade(
          ctx, state, const ScreenLogin(),
        ),
      ),
      GoRoute(
        path:        kRouteSignup,
        pageBuilder: (ctx, state) => AppPageTransitions.fade(
          ctx, state, const ScreenSignup(),
        ),
      ),
      GoRoute(
        path:        kRouteResetPassword,
        pageBuilder: (ctx, state) => AppPageTransitions.fade(
          ctx, state, const ScreenReset(),
        ),
      ),

      // ── Public rendering plane ───────────────────────────────────────────
      // Placeholder until space_value screens are built (Cycle 1).
      GoRoute(
        path:        kRouteHome,
        pageBuilder: (ctx, state) => AppPageTransitions.fadeSlide(
          ctx, state, const _PlaceholderHome(),
        ),
      ),

      // ── Admin control plane ──────────────────────────────────────────────
      // ShellRoute wraps admin screens inside QAdminShell.
      ShellRoute(
        navigatorKey: _kAdminNavKey,
        builder:      (_, __, child) => QAdminShell(body: child),
        routes: [
          GoRoute(
            path:     kRouteAdmin,
            redirect: (_, __) => kRouteAdminOverview,
          ),
          GoRoute(
            path:        kRouteAdminOverview,
            pageBuilder: (ctx, state) => AppPageTransitions.fadeSlide(
              ctx, state, const _AdminPlaceholder(label: 'Overview'),
            ),
          ),
          GoRoute(
            path:        '/admin/content',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state, const _AdminPlaceholder(label: 'Content'),
            ),
          ),
          GoRoute(
            path:        '/admin/brand',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state, const _AdminPlaceholder(label: 'Brand'),
            ),
          ),
          GoRoute(
            path:        '/admin/assets',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state, const _AdminPlaceholder(label: 'Assets'),
            ),
          ),
          GoRoute(
            path:        '/admin/features',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state, const _AdminPlaceholder(label: 'Features'),
            ),
          ),
          GoRoute(
            path:        '/admin/preview',
            pageBuilder: (ctx, state) => AppPageTransitions.zoom(
              ctx, state, const _AdminPlaceholder(label: 'Preview'),
            ),
          ),
        ],
      ),

      // Extra routes injected by the client/tenant (via QRouterConfig).
      ...routerConfig.extraRoutes,
    ],

    // Dev-only error page. Replace before production.
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found: ${state.error}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    ),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// _redirect
// ─────────────────────────────────────────────────────────────────────────────

// All redirect logic lives here. Order matters — first match wins.
String? _redirect(Ref ref, QRouterConfig routerConfig, GoRouterState state) {
  final session  = ref.read(currentSessionProvider);
  final location = state.matchedLocation;
  final isLoggedIn  = session != null;
  final isAuthRoute = kAuthOnlyRoutes.contains(location);

  // 1. Logged in + on an auth route → determine post-login destination.
  //    Priority: QAuthConfig.postLoginRoutes → AuthPolicy.defaultHomeFor(role)
  if (isLoggedIn && isAuthRoute) {
    final authConfig    = ref.read(authConfigProvider);
    final selectedClassId = ref.read(selectedUserClassProvider);
    final configured    = authConfig.postLoginRouteFor(selectedClassId ?? '');
    return configured ?? AuthPolicy.defaultHomeFor(session.role);
  }

  // 2. Core structural guards (unauthenticated access, role checks).
  final coreRedirect = AuthPolicy.redirectFor(session: session, location: location);
  if (coreRedirect != null) return coreRedirect;

  // 3. Tenant/client-provided extra redirect rules (from QRouterConfig).
  return routerConfig.extraRedirect?.call(session, location);
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────

// A thin ChangeNotifier so GoRouter knows to re-run redirect on auth state change.
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder screens — remove as real screens are built
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('QSpace Pages — Home', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/admin'),
              child: const Text('Go to Admin →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPlaceholder extends StatelessWidget {
  final String label;
  const _AdminPlaceholder({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Text('Admin / $label — coming Cycle 3',
        style: const TextStyle(fontSize: 16)),
  );
}