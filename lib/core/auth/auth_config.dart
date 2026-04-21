// lib/core/auth/auth_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QAuthConfig, AuthUserClass, preset configs.
//   v2.0.0 — Added QSocialAuthConfig — which social providers to show and
//             how. Added QBiometricConfig — biometric behavior settings.
//             Both are now imported by AppClientConfig.
//             Moved AuthAdapterType → lib/core/config/app_client_config.dart
//             (adapter type is not auth UI config — it's deployment config).
//             3-role example updated in kAuthConfigDeveloper.
//             showRoleToggle: false pattern documented with kAuthConfigSingleUser.
// ─────────────────────────────────────────────────────────────────────────────
//
// Everything here is brand/project-agnostic. QSpace-specific values are in
// lib/client/qspace/client_config.dart — never in this file.

import 'auth_session.dart';
import 'social_auth_port.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthUserClass
// ─────────────────────────────────────────────────────────────────────────────

class AuthUserClass {
  final String id;
  final String label;
  final QRole  role;

  const AuthUserClass({
    required this.id,
    required this.label,
    required this.role,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// QAuthConfig — auth UI behavior
// ─────────────────────────────────────────────────────────────────────────────

class QAuthConfig {
  final String tenantId;

  // Ordered list of selectable user types shown on the role toggle.
  // 0 or 1 items → toggle not shown (regardless of showRoleToggle).
  // 2+ items → segmented pill toggle.
  // Supports any number of roles — QSpace uses 3 (User / Admin / Developer).
  final List<AuthUserClass> userClasses;

  // Master switch for the role toggle section.
  // false → section hidden even if userClasses has 2+ items.
  // Some apps don't need role selection — set false for plain login.
  final bool showRoleToggle;

  // Copy — override per tenant/brand without touching any screen file.
  final String loginHeading;
  final String loginSubheading;
  final String signupHeading;
  final String signupSubheading;

  // Feature flags
  final bool allowSignup;         // false → signup link hidden
  final bool allowPasswordReset;  // false → forgot password link hidden

  // Post-login route per user class id.
  // Unmatched ids fall back to AuthPolicy.defaultHomeFor(role).
  final Map<String, String> postLoginRoutes;

  const QAuthConfig({
    required this.tenantId,
    required this.userClasses,
    this.showRoleToggle     = true,
    this.loginHeading       = 'Welcome back',
    this.loginSubheading    = 'Sign in to continue',
    this.signupHeading      = 'Create your account',
    this.signupSubheading   = 'Join us today',
    this.allowSignup        = true,
    this.allowPasswordReset = true,
    this.postLoginRoutes    = const {},
  });

  bool get isToggleVisible => showRoleToggle && userClasses.length >= 2;

  AuthUserClass? get defaultClass =>
      userClasses.isNotEmpty ? userClasses.first : null;

  String? postLoginRouteFor(String classId) => postLoginRoutes[classId];
}

// ─────────────────────────────────────────────────────────────────────────────
// QSocialAuthConfig — social login behavior
// ─────────────────────────────────────────────────────────────────────────────

class QSocialAuthConfig {
  // Master switch. false → entire social section hidden, no buttons rendered.
  // Also requires a configured SocialAuthPort in AppClientConfig — if the
  // port returns isConfigured = false, buttons are hidden regardless of this flag.
  final bool enabled;

  // Which providers to show and in what order.
  // Remove a provider from the list to hide its button without disabling all social.
  final List<SocialAuthProvider> providers;

  // Divider label above the social button row.
  final String dividerLabel;

  // Which auth modes show the social section.
  // Typically login + signup. Reset never shows social.
  final bool showOnLogin;
  final bool showOnSignup;

  const QSocialAuthConfig({
    this.enabled       = false,
    this.providers     = const [
      SocialAuthProvider.google,
      SocialAuthProvider.apple,
      SocialAuthProvider.github,
    ],
    this.dividerLabel  = 'Or continue with',
    this.showOnLogin   = true,
    this.showOnSignup  = true,
  });

  bool get isVisible => enabled && providers.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// QBiometricConfig — biometric sign-in behavior
// ─────────────────────────────────────────────────────────────────────────────

class QBiometricConfig {
  // Master switch. false → biometric button never shown.
  // Also requires a configured BiometricAuthPort (non-stub) in AppClientConfig.
  final bool enabled;

  // The reason string shown in the system biometric dialog.
  final String promptMessage;

  // The cancel/fallback label in the system dialog.
  final String cancelLabel;

  // The small label shown next to the fingerprint icon button.
  final String buttonLabel;

  const QBiometricConfig({
    this.enabled       = false,
    this.promptMessage = 'Authenticate to sign in',
    this.cancelLabel   = 'Cancel',
    this.buttonLabel   = 'Use biometrics',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Canonical preset configs
// ─────────────────────────────────────────────────────────────────────────────

// Standard two-tier. Most B2B products.
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

// Three-tier: the QSpace default — User / Admin / Developer.
const kAuthConfigThreeTier = QAuthConfig(
  tenantId: 'default',
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',        role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Admin',        role: QRole.clientAdmin),
    AuthUserClass(id: 'dev',   label: 'Developer',    role: QRole.developer),
  ],
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
    'dev':   '/admin',
  },
);

// No toggle. Plain login. B2C products where all users are the same tier.
const kAuthConfigSingleUser = QAuthConfig(
  tenantId:       'default',
  showRoleToggle: false,
  userClasses: [
    AuthUserClass(id: 'user', label: 'User', role: QRole.user),
  ],
);

// Developer config: all four permission tiers visible.
// Internal tooling only — never ship to end users.
const kAuthConfigDeveloper = QAuthConfig(
  tenantId:     'dev',
  loginHeading: 'Developer Sign In',
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',       role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Admin',       role: QRole.clientAdmin),
    AuthUserClass(id: 'dev',   label: 'Developer',   role: QRole.developer),
    AuthUserClass(id: 'arch',  label: 'Architect',   role: QRole.architect),
  ],
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
    'dev':   '/admin',
    'arch':  '/admin',
  },
);