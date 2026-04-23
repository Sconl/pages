// lib/core/auth/auth_policy.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Route guards and access checks. Pure Dart. Zero I/O.
//             Follows canvas admin permissions model from Appendix I.
//   v1.1.0 — Added defaultHomeFor(QRole) — role-aware post-login destination.
//             Moved post-auth routing out of the hardcoded kRouteHome redirect
//             so admins land on /admin instead of / after login.
// ─────────────────────────────────────────────────────────────────────────────
//
// Keeping security logic out of the UI is the rule.
// The backend enforces these same rules server-side — this is the client-side
// expression of them, used for routing and conditional rendering only.
// Never use this as the source of truth for what a user CAN do.

import 'auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Routes ──
const kRouteLogin         = '/login';
const kRouteSignup        = '/signup';
const kRouteResetPassword = '/reset-password';
const kRouteHome          = '/';
const kRouteAdmin         = '/admin';
const kRouteAdminOverview = '/admin/overview';

// ── Auth-only routes (no session → redirect to login) ──
const kProtectedPrefixes = ['/admin', '/account', '/dashboard'];

// ── Auth routes (session present → redirect away from these) ──
const kAuthOnlyRoutes = [kRouteLogin, kRouteSignup, kRouteResetPassword];

// ─────────────────────────────────────────────────────────────────────────────
// AuthPolicy
// ─────────────────────────────────────────────────────────────────────────────

class AuthPolicy {
  // Not instantiable — pure static logic
  const AuthPolicy._();

  // Can this role access any admin screen?
  static bool canAccessAdmin(QRole role) =>
      role.index >= QRole.clientAdmin.index;

  // Can this role access developer-tier admin features (rollback, mappings)?
  static bool canAccessDeveloperTools(QRole role) =>
      role.index >= QRole.developer.index;

  // Can this role touch schema-level canonical defaults?
  static bool canAccessArchitectTools(QRole role) =>
      role == QRole.architect;

  // Where should a freshly-authenticated user land by default?
  // The router calls this when no QAuthConfig.postLoginRoute is configured.
  // Admins go to the control plane. Everyone else goes home.
  static String defaultHomeFor(QRole role) {
    if (role.index >= QRole.clientAdmin.index) return kRouteAdmin;
    return kRouteHome;
  }

  // Determines the correct redirect for a given session + attempted route.
  // Returns null if no redirect is needed (allow navigation).
  //
  // Called by the GoRouter redirect callback. If this returns a path,
  // GoRouter sends the user there instead.
  //
  // NOTE: Post-login routing (auth route → where to go after login) is handled
  // in app_router.dart, not here, because it needs QAuthConfig context.
  // This method only handles the structural guards.
  static String? redirectFor({
    required QAuthSession? session,
    required String location,
  }) {
    final isLoggedIn  = session != null;
    final isAuthRoute = kAuthOnlyRoutes.contains(location);
    final isAdminRoute = location.startsWith('/admin');
    final isProtected = kProtectedPrefixes.any(location.startsWith);

    // Not logged in, trying to access a protected route → go to login
    if (!isLoggedIn && isProtected) {
      return '$kRouteLogin?redirect=${Uri.encodeComponent(location)}';
    }

    // Not logged in, on a public auth route → allow it
    if (!isLoggedIn && isAuthRoute) return null;

    // Logged in, on an auth route → handled upstream in the router
    // (this case intentionally falls through to null — app_router.dart intercepts first)
    if (isLoggedIn && isAuthRoute) return null;

    // Logged in, trying admin, but role is too low → back to home
    if (isLoggedIn && isAdminRoute && !canAccessAdmin(session.role)) {
      return kRouteHome;
    }

    // Everything else → allow
    return null;
  }
}