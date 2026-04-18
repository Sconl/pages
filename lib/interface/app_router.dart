// lib/interface/app_router.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. GoRouter with auth redirect guards.
//             Public routes, auth routes, admin route group.
//             Redirect logic delegates to AuthPolicy — zero policy logic here.
// ─────────────────────────────────────────────────────────────────────────────
//
// Route structure:
//   /login              → ScreenLogin         (unauthenticated only)
//   /signup             → ScreenSignup        (unauthenticated only)
//   /reset-password     → ScreenReset         (unauthenticated only)
//   /                   → ScreenEntry         (space_value entry — public)
//   /admin              → redirect to /admin/overview
//   /admin/overview     → ScreenAdminOverview (clientAdmin+)
//   /admin/content      → ScreenAdminContent  (clientAdmin+)
//   /admin/brand        → ScreenAdminBrand    (clientAdmin+)
//   /admin/assets       → ScreenAdminAssets   (clientAdmin+)
//   /admin/features     → ScreenAdminFeatures (clientAdmin+)
//   /admin/preview      → ScreenAdminPreview  (clientAdmin+)
//
// Admin screens are stubbed as placeholders until Cycle 3 builds them out.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_policy.dart';
import '../experience/spaces/space_auth/screens/screen_login.dart';
import '../experience/spaces/space_auth/screens/screen_signup.dart';
import '../experience/spaces/space_auth/screens/screen_reset.dart';
import '../experience/spaces/space_auth/state/auth_riverpod.dart';
import '../experience/spaces/space_admin/shell_admin/qspace_admin_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Navigator keys ──
// Separate keys for root and admin shell so GoRouter nests them correctly.
final _kRootNavKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final _kAdminNavKey = GlobalKey<NavigatorState>(debugLabel: 'admin');

// ─────────────────────────────────────────────────────────────────────────────
// routerProvider
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  // This notifier fires when auth state changes — GoRouter re-evaluates
  // the redirect on every emit, which handles sign-in and sign-out nav.
  final refreshNotifier = _AuthChangeNotifier();

  ref.listen(authSessionProvider, (_, __) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey:      _kRootNavKey,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session  = ref.read(currentSessionProvider);
      final location = state.matchedLocation;
      return AuthPolicy.redirectFor(session: session, location: location);
    },
    routes: [
      // ── Auth routes ──────────────────────────────────────────────────────
      GoRoute(
        path:    '/login',
        builder: (_, __) => const ScreenLogin(),
      ),
      GoRoute(
        path:    '/signup',
        builder: (_, __) => const ScreenSignup(),
      ),
      GoRoute(
        path:    '/reset-password',
        builder: (_, __) => const ScreenReset(),
      ),

      // ── Public rendering plane ───────────────────────────────────────────
      // Placeholder until space_value screens are built (Cycle 1).
      GoRoute(
        path:    '/',
        builder: (_, __) => const _PlaceholderHome(),
      ),

      // ── Admin control plane ──────────────────────────────────────────────
      // Separate ShellRoute so admin screens nest inside QAdminShell.
      ShellRoute(
        navigatorKey: _kAdminNavKey,
        builder: (_, __, child) => QAdminShell(body: child),
        routes: [
          GoRoute(
            path:     '/admin',
            redirect: (_, __) => '/admin/overview',
          ),
          GoRoute(
            path:    '/admin/overview',
            builder: (_, __) => const _AdminPlaceholder(label: 'Overview'),
          ),
          GoRoute(
            path:    '/admin/content',
            builder: (_, __) => const _AdminPlaceholder(label: 'Content'),
          ),
          GoRoute(
            path:    '/admin/brand',
            builder: (_, __) => const _AdminPlaceholder(label: 'Brand'),
          ),
          GoRoute(
            path:    '/admin/assets',
            builder: (_, __) => const _AdminPlaceholder(label: 'Assets'),
          ),
          GoRoute(
            path:    '/admin/features',
            builder: (_, __) => const _AdminPlaceholder(label: 'Features'),
          ),
          GoRoute(
            path:    '/admin/preview',
            builder: (_, __) => const _AdminPlaceholder(label: 'Preview'),
          ),
        ],
      ),
    ],

    // Dev-only error page — shows the route that failed.
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// _AuthChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────

// A thin ChangeNotifier that GoRouter uses as its refreshListenable.
// When auth state changes, we call notify() → GoRouter re-runs redirect.
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder screens (remove as real screens are built)
// ─────────────────────────────────────────────────────────────────────────────

// Holds the "/" route until space_value is wired. Replace with ScreenEntry.
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

// Holds admin screen slots until Cycle 3 builds them.
class _AdminPlaceholder extends StatelessWidget {
  final String label;
  const _AdminPlaceholder({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Text('Admin / $label — coming Cycle 3',
        style: const TextStyle(fontSize: 16)),
  );
}