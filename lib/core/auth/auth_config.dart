// lib/core/auth/auth_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. The single configurable location for all auth behavior:
//             user classes, UI copy, feature flags, post-login routing.
//             Zero project-specific imports. Pure Dart. Reusable across any
//             deployment or tenant. Override via authConfigProvider in ProviderScope.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO CUSTOMIZE FOR A TENANT:
//   1. Define a const QAuthConfig with the right user classes and copy.
//   2. Override authConfigProvider in ProviderScope (same pattern as authAdapterProvider).
//   3. Touch nothing else — the screens, router, and state all read from this config.
//
// WHY THIS EXISTS:
//   Without a central config, auth behavior leaks into screen logic. When a new
//   tenant wants "Owner" and "Staff" instead of "User" and "Administrator", the
//   change is one constant here — not a screen edit.

import 'auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthUserClass
// ─────────────────────────────────────────────────────────────────────────────

// One selectable user type on the login/signup role toggle.
// id     — stable identifier for analytics, routing hints, and state tracking
// label  — what the user sees (keep short — one or two words)
// role   — the QRole this class maps to (drives routing + signup role hint)
class AuthUserClass {
  final String  id;
  final String  label;
  final QRole   role;

  const AuthUserClass({
    required this.id,
    required this.label,
    required this.role,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// QAuthConfig
// ─────────────────────────────────────────────────────────────────────────────

// Everything about auth behavior and UI in one immutable config.
// Override via authConfigProvider in ProviderScope. Nothing else changes.
class QAuthConfig {
  // Which tenant owns this config — used for logging and future multi-tenant resolution.
  final String tenantId;

  // The user types shown in the role toggle. Order matters — first is the default.
  // Empty list → no toggle, plain login.
  final List<AuthUserClass> userClasses;

  // Whether to render the role toggle at all.
  // Automatically false if fewer than 2 classes are defined.
  final bool showRoleToggle;

  // Screen copy — override per tenant without touching any screen file.
  final String loginHeading;
  final String loginSubheading;
  final String signupHeading;
  final String signupSubheading;

  // Feature flags
  final bool allowSignup;          // false → login-only, signup link hidden
  final bool allowPasswordReset;   // false → forgot password link hidden

  // Post-login destination per user class id.
  // If a class id has no entry here, AuthPolicy.defaultHomeFor(role) is used.
  // Example: {'admin': '/admin', 'user': '/'}
  final Map<String, String> postLoginRoutes;

  const QAuthConfig({
    required this.tenantId,
    required this.userClasses,
    this.showRoleToggle      = true,
    this.loginHeading        = 'Welcome back',
    this.loginSubheading     = 'Sign in to continue',
    this.signupHeading       = 'Create your account',
    this.signupSubheading    = 'Join us today',
    this.allowSignup         = true,
    this.allowPasswordReset  = true,
    this.postLoginRoutes     = const {},
  });

  // Effective toggle visibility — false if explicitly disabled or fewer than 2 classes.
  bool get isToggleVisible => showRoleToggle && userClasses.length >= 2;

  // The class used when no toggle selection has been made yet.
  AuthUserClass? get defaultClass =>
      userClasses.isNotEmpty ? userClasses.first : null;

  // Resolves the post-login route for a given class id. Returns null if not configured.
  String? postLoginRouteFor(String classId) => postLoginRoutes[classId];
}

// ─────────────────────────────────────────────────────────────────────────────
// Canonical preset configs — compose from these or define your own
// ─────────────────────────────────────────────────────────────────────────────

// Standard two-tier: regular users and admins. The most common setup.
const kAuthConfigDefault = QAuthConfig(
  tenantId: 'default',
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',          role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Administrator',  role: QRole.clientAdmin),
  ],
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
  },
);

// Single-user: no toggle, plain login. Good for simple B2C products.
const kAuthConfigSingleUser = QAuthConfig(
  tenantId:       'default',
  showRoleToggle: false,
  userClasses: [
    AuthUserClass(id: 'user', label: 'User', role: QRole.user),
  ],
);

// Developer config: exposes all four permission tiers.
// Only use this for internal tooling or dev environments — don't ship it to end users.
const kAuthConfigDeveloper = QAuthConfig(
  tenantId:     'dev',
  loginHeading: 'Developer Sign In',
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',         role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Client Admin',  role: QRole.clientAdmin),
    AuthUserClass(id: 'dev',   label: 'Developer',     role: QRole.developer),
    AuthUserClass(id: 'arch',  label: 'Architect',     role: QRole.architect),
  ],
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
    'dev':   '/admin',
    'arch':  '/admin',
  },
);