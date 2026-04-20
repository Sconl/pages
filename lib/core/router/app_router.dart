// lib/core/router/app_router.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Moved from lib/interface/.
//   v1.1.0 — Role-aware post-login routing. QRouterConfig injection.
//             AppPageTransitions applied to all route builders.
//   v1.1.1 — Fixed: missing app_style.dart import. (_, __) → (_, _) lint.
//             Import paths updated.
//   v1.1.2 — Fixed: QAdminShell(body: child) → const QAdminShell().
//             QAdminShell manages its own screen stack via kAdminScreenRegistry
//             and IndexedStack — it does not accept an external body widget.
//             GoRouter's ShellRoute child is intentionally unused here.
//   v1.1.3 — Fixed: QAdminShell now requires config: parameter.
//             Import added for client_config.dart to supply kQSpaceAdminConfig.
//             ShellRoute builder updated accordingly.
//             Added '/admin/dashboard' and '/admin/settings' routes to match
//             the updated kAdminScreenRegistry portal ids.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../style/app_style.dart';
import '../auth/auth_policy.dart';
import '../../spaces/space_auth/screens/screen_login.dart';
import '../../spaces/space_auth/screens/screen_signup.dart';
import '../../spaces/space_auth/screens/screen_reset.dart';
import '../../spaces/space_auth/state/auth_riverpod.dart';
import '../../spaces/space_admin/shell_admin/q_admin_shell.dart';
import 'router_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

final _kRootNavKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final _kAdminNavKey = GlobalKey<NavigatorState>(debugLabel: 'admin');

// ─────────────────────────────────────────────────────────────────────────────
// routerProvider
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final routerConfig    = ref.read(routerConfigProvider);
  final refreshNotifier = _AuthChangeNotifier();

  ref.listen(authSessionProvider, (_, _) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey:      _kRootNavKey,
    initialLocation:   routerConfig.initialLocation,
    refreshListenable: refreshNotifier,
    redirect:          (context, state) => _redirect(ref, routerConfig, state),
    routes: [
      // ── Auth routes (unauthenticated only) ──────────────────────────────
      // All three auth flows resolve to ShellAuthRoot with the appropriate mode.
      // ShellAuthRoot reads QAuthConfig + AuthLayoutConfig and orchestrates
      // the correct template + sections for each mode.
      GoRoute(
        path:        kRouteLogin,
        pageBuilder: (ctx, state) => AppPageTransitions.fade(
          ctx, state,
          const ShellAuthRoot(mode: AuthMode.login),
        ),
      ),
      GoRoute(
        path:        kRouteSignup,
        pageBuilder: (ctx, state) => AppPageTransitions.fade(
          ctx, state,
          const ShellAuthRoot(mode: AuthMode.signup),
        ),
      ),
      GoRoute(
        path:        kRouteResetPassword,
        pageBuilder: (ctx, state) => AppPageTransitions.fade(
          ctx, state,
          const ShellAuthRoot(mode: AuthMode.reset),
        ),
      ),

      // ── Public rendering plane ───────────────────────────────────────────
      GoRoute(
        path:        kRouteHome,
        pageBuilder: (ctx, state) => AppPageTransitions.fadeSlide(
          ctx, state,
          const _PlaceholderHome(),
        ),
      ),

      // ── Admin control plane ──────────────────────────────────────────────
      // QAdminShell owns its own IndexedStack via kAdminScreenRegistry.
      // GoRouter's child is unused — the shell handles internal navigation itself.
      // The ShellRoute still provides the auth guard boundary and the separate
      // navigator key, which is what matters here.
      ShellRoute(
        navigatorKey: _kAdminNavKey,
        builder:      (_, __, ___) => QAdminShell(config: kQSpaceAdminConfig),
        routes: [
          GoRoute(
            path:     kRouteAdmin,
            redirect: (_, __) => kRouteAdminOverview,
          ),
          // Dashboard (was 'overview' — portal id updated to 'dashboard')
          GoRoute(
            path:        kRouteAdminOverview,
            pageBuilder: (ctx, state) => AppPageTransitions.fadeSlide(ctx, state, const _AdminPlaceholder(label: 'Overview')),
          ),
          GoRoute(
            path:        '/admin/content',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(ctx, state, const _AdminPlaceholder(label: 'Content')),
          ),
          GoRoute(
            path:        '/admin/brand',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(ctx, state, const _AdminPlaceholder(label: 'Brand')),
          ),
          GoRoute(
            path:        '/admin/assets',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(ctx, state, const _AdminPlaceholder(label: 'Assets')),
          ),
          GoRoute(
            path:        '/admin/features',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(ctx, state, const _AdminPlaceholder(label: 'Features')),
          ),
          GoRoute(
            path:        '/admin/preview',
            pageBuilder: (ctx, state) => AppPageTransitions.zoom(ctx, state, const _AdminPlaceholder(label: 'Preview')),
          ),
        ],
      ),

      ...routerConfig.extraRoutes,
    ],

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

String? _redirect(Ref ref, QRouterConfig routerConfig, GoRouterState state) {
  final session     = ref.read(currentSessionProvider);
  final location    = state.matchedLocation;
  final isLoggedIn  = session != null;
  final isAuthRoute = kAuthOnlyRoutes.contains(location);

  if (isLoggedIn && isAuthRoute) {
    final authConfig      = ref.read(authConfigProvider);
    final selectedClassId = ref.read(selectedUserClassProvider);
    final configured      = authConfig.postLoginRouteFor(selectedClassId ?? '');
    return configured ?? AuthPolicy.defaultHomeFor(session.role);
  }

  final coreRedirect = AuthPolicy.redirectFor(session: session, location: location);
  if (coreRedirect != null) return coreRedirect;

  return routerConfig.extraRedirect?.call(session, location);
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────

class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholders — replace as real screens are built
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
    child: Text(
      'Admin / $label — coming Cycle 3',
      style: const TextStyle(fontSize: 16),
    ),
  );
}