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
//   v1.1.3 — Fixed: QAdminShell now requires config: parameter.
//             Added '/admin/dashboard' and '/admin/settings' routes.
//   v1.2.0 — Updated to ShellAuthRoot(mode: AuthMode.*) replacing individual
//             screen_*.dart files.
//   v1.2.1 — Fixed admin shell import path: shell/ → shell_admin/.
//   v1.2.2 — Fixed all broken imports after auth space refactor.
//             Added import for kQSpaceAdminConfig from client_config.dart.
//             Fixed (_, __) / (_, _, ___) → (_, _) unnecessary_underscores lint.
//   v1.3.0 — Added '/admin/publisher' route (ShellPublisherRoot).
//             Added '/discovery' and '/discovery/scan' routes (mobile-only).
//             Added mobile initial location: reads isMobileAppProvider —
//               native mobile starts at /discovery, web starts at routerConfig default.
//   v1.3.1 — Fixed: replaced ScreenDiscoveryHome/Scan/Loading (wrong class names
//               and paths) with ShellDiscoveryRoot and TemplateDiscoveryScan.
//             Fixed: discovery imports now point to discovery_views/ not
//               discovery_screens/ (the old flat structure no longer exists).
//             Fixed: /discovery/loading route removed — loading state is managed
//               internally by ShellDiscoveryRoot via discoveryLayoutProvider.
//             Fixed: added import for app_mobile_config.dart for isMobileAppProvider.
//   v1.3.2 — Fixed: isMobileAppProvider is defined in app_client_config.dart,
//               not app_mobile_config.dart. Import corrected. Both files are
//               now imported: app_mobile_config.dart is kept because
//               app_router.dart does not directly use AppMobileConfig or its
//               constant — it can be removed if no other symbol from that file
//               is needed here.
// ─────────────────────────────────────────────────────────────────────────────
//
// All auth routes resolve to ShellAuthRoot with the appropriate AuthMode.
// QAdminShell manages its own IndexedStack — GoRouter child is unused.
// ShellRoute still provides the auth guard boundary + separate navigator key.
//
// Discovery routes are mobile-only: if kIsWeb is true the redirect fires and
// sends the user to '/'. On native builds the screens render normally.
//
// The /discovery route is handled entirely by ShellDiscoveryRoot.
// ShellDiscoveryRoot reads discoveryLayoutProvider and swaps between
// TemplateDiscoveryHome and TemplateDiscoveryLoading in place.
// /discovery/scan is a separate full-page route for the QR camera.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../style/app_style.dart';
import '../auth/auth_policy.dart';
import '../config/app_client_config.dart';
import '../../spaces/space_auth/auth_views/shell_auth_root.dart';
import '../../spaces/space_auth/auth_views/layout_auth_config.dart';
import '../../spaces/space_auth/auth_state/auth_riverpod.dart';
import '../../spaces/space_admin/space_admin_shell.dart';
import '../../spaces/space_admin/admin_portals/publisher_portal/shell_publisher_root.dart';
import '../../spaces/space_discovery/discovery_views/shell_discovery_root.dart';
import '../../spaces/space_discovery/discovery_views/discovery_templates/template_discovery_scan.dart';
import '../../client/qspace/client_config.dart';
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

  // Determine initial location based on runtime mode.
  // Mobile native (QPages app) starts at /discovery so tenants can be selected.
  // Web and package mode start at the configured default (usually '/').
  final isMobile        = !kIsWeb && ref.read(isMobileAppProvider);
  final initialLocation = isMobile ? '/discovery' : routerConfig.initialLocation;

  ref.listen(authSessionProvider, (_, _) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey:      _kRootNavKey,
    initialLocation:   initialLocation,
    refreshListenable: refreshNotifier,
    redirect:          (context, state) => _redirect(ref, routerConfig, state),
    routes: [
      // ── Auth routes (unauthenticated only) ──────────────────────────────
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
      // The GoRouter child is intentionally unused — the shell handles
      // internal screen switching itself. ShellRoute is here for the auth
      // guard boundary (role check in _redirect) and the separate nav key.
      ShellRoute(
        navigatorKey: _kAdminNavKey,
        builder:      (_, _, _) => QAdminShell(config: kQSpaceAdminConfig),
        routes: [
          GoRoute(
            path:     kRouteAdmin,
            redirect: (_, _) => kRouteAdminOverview,
          ),
          GoRoute(
            path:        kRouteAdminOverview,
            pageBuilder: (ctx, state) => AppPageTransitions.fadeSlide(
              ctx, state,
              const _AdminPlaceholder(label: 'Overview'),
            ),
          ),
          GoRoute(
            path:        '/admin/content',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state,
              const _AdminPlaceholder(label: 'Content'),
            ),
          ),
          GoRoute(
            path:        '/admin/brand',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state,
              const _AdminPlaceholder(label: 'Brand'),
            ),
          ),
          GoRoute(
            path:        '/admin/assets',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state,
              const _AdminPlaceholder(label: 'Assets'),
            ),
          ),
          GoRoute(
            path:        '/admin/features',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state,
              const _AdminPlaceholder(label: 'Features'),
            ),
          ),
          GoRoute(
            path:        '/admin/preview',
            pageBuilder: (ctx, state) => AppPageTransitions.zoom(
              ctx, state,
              const _AdminPlaceholder(label: 'Preview'),
            ),
          ),
          GoRoute(
            path:        '/admin/dashboard',
            pageBuilder: (ctx, state) => AppPageTransitions.fadeSlide(
              ctx, state,
              const _AdminPlaceholder(label: 'Dashboard'),
            ),
          ),
          GoRoute(
            path:        '/admin/settings',
            pageBuilder: (ctx, state) => AppPageTransitions.slide(
              ctx, state,
              const _AdminPlaceholder(label: 'Settings'),
            ),
          ),
          GoRoute(
            path:    '/admin/publisher',
            builder: (_, _) => const ShellPublisherRoot(),
          ),
        ],
      ),

      // ── Discovery routes (mobile-only) ───────────────────────────────────
      // Redirect to '/' on web — these routes only exist for the QPages app.
      //
      // /discovery       → ShellDiscoveryRoot
      //                    Manages home and loading layouts internally via
      //                    discoveryLayoutProvider. No sub-routes for these
      //                    states — the shell swaps templates in place.
      //
      // /discovery/scan  → TemplateDiscoveryScan
      //                    Full-page QR camera. Separate route so the system
      //                    back gesture works correctly on Android.
      GoRoute(
        path:     '/discovery',
        redirect: (context, state) => kIsWeb ? '/' : null,
        builder:  (_, _) => const ShellDiscoveryRoot(),
        routes: [
          GoRoute(
            path:    'scan',
            builder: (_, _) => const TemplateDiscoveryScan(),
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