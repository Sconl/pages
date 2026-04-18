// lib/core/auth/auth_policy.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Route guards and access checks. Pure Dart. Zero I/O.
//             Follows canvas admin permissions model from Appendix I.
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

  // Determines the correct redirect for a given session + attempted route.
  // Returns null if no redirect is needed (allow navigation).
  //
  // Called by GoRouter's redirect callback. If this returns a path,
  // GoRouter sends the user there instead.
  static String? redirectFor({
    required QAuthSession? session,
    required String location,
  }) {
    final isLoggedIn = session != null;
    final isAuthRoute = kAuthOnlyRoutes.contains(location);
    final isAdminRoute = location.startsWith('/admin');
    final isProtected = kProtectedPrefixes.any(location.startsWith);

    // Not logged in, trying to access a protected route → go login
    if (!isLoggedIn && isProtected) {
      return '$kRouteLogin?redirect=${Uri.encodeComponent(location)}';
    }

    // Not logged in, trying to access an auth route → allow it
    if (!isLoggedIn && isAuthRoute) return null;

    // Logged in, on an auth route → go home
    if (isLoggedIn && isAuthRoute) return kRouteHome;

    // Logged in, trying admin, but role is too low → back to home
    if (isLoggedIn && isAdminRoute && !canAccessAdmin(session.role)) {
      return kRouteHome;
    }

    // Everything else → allow
    return null;
  }
}