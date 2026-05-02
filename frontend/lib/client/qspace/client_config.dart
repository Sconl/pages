// lib/client/qspace/client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Added kQSpaceAuthConfig and kQSpaceRouterConfig.
//   v1.1.1 — Fixed: QRole undefined — added import for auth_session.dart.
//             Fixed: adapter imports updated to lib/core/auth/auth_adapters/.
//   v1.2.0 — Added kQSpaceAdminConfig — QSpace admin system config.
//             Portal access rules, dev mode, and registry id mapping.
//   v1.3.0 — Merged AppClientConfig pattern (Session 3).
//             Added kQSpaceSocialConfig, kQSpaceBiometricConfig.
//             Added kQSpaceClientConfig as master composed config object.
//             Updated kQSpaceAuthConfig to three-tier (User/Admin/Developer).
//             AuthAdapterType moved to lib/core/config/app_client_config.dart.
//             kDefaultTenantId made private (_kDefaultTenantId) — consumed via
//             kQSpaceClientConfig.defaultTenantId everywhere outside this file.
//   v1.4.0 — Added 'publisher' portal access entry to kQSpaceAdminConfig.
//             Matches AdminScreenEntry id in kAdminScreenRegistry.
// ─────────────────────────────────────────────────────────────────────────────
//
// THIS IS THE SINGLE FILE TO CHANGE PER DEPLOYMENT.
//
// Everything project-specific — auth behavior, social providers, biometric
// settings, admin portal access, routing extras, and backend URLs — lives here.
// Nothing in lib/core/, lib/spaces/, or lib/interface/ needs to change per project.
//
// To add a new project:
//   1. Create lib/client/{project}/client_config.dart
//   2. Define a final k{Project}ClientConfig = AppClientConfig(...)
//   3. Create main_{project}.dart → runApp(AppRoot(config: k{Project}ClientConfig))
//   4. Done. Zero core changes.

import '../../core/auth/auth_session.dart';        // QRole enum
import '../../core/auth/auth_config.dart';          // QAuthConfig, AuthUserClass, QSocialAuthConfig, QBiometricConfig
import '../../core/auth/social_auth_port.dart';     // SocialAuthProvider enum
import '../../core/admin/admin_config.dart';        // QAdminConfig, AdminPortalAccess
import '../../core/config/app_client_config.dart';  // AppClientConfig, AuthAdapterType
import '../../core/router/router_config.dart';      // QRouterConfig

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK — change these values per deployment
// ─────────────────────────────────────────────────────────────────────────────

// Override at build time:
//   flutter build web --dart-define=API_BASE_URL=https://api.qspace.co
const _kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

// Override at build time:
//   flutter build web --dart-define=TENANT_ID=qspace-prod
const _kDefaultTenantId = String.fromEnvironment(
  'TENANT_ID',
  defaultValue: 'qspace-dev',
);

// ─────────────────────────────────────────────────────────────────────────────
// Auth config — UI behavior, role toggle, copy, post-login routing
// ─────────────────────────────────────────────────────────────────────────────

// Three-tier toggle: User / Admin / Developer.
// To hide the toggle entirely: showRoleToggle: false (or use kAuthConfigSingleUser).
// To add a fourth tier (e.g. Architect): add another AuthUserClass entry.
const kQSpaceAuthConfig = QAuthConfig(
  tenantId: _kDefaultTenantId,
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',       role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Admin',       role: QRole.clientAdmin),
    AuthUserClass(id: 'dev',   label: 'Developer',   role: QRole.developer),
  ],
  showRoleToggle:   true,
  loginHeading:     'Welcome back',
  loginSubheading:  'Sign in to your QSpace account',
  signupHeading:    'Get started',
  signupSubheading: 'Create your QSpace account',
  allowSignup:        true,
  allowPasswordReset: true,
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
    'dev':   '/admin',
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Social config — which social providers to offer
// ─────────────────────────────────────────────────────────────────────────────

// Currently disabled. To enable:
//   1. Set enabled: true
//   2. Add required packages (google_sign_in, sign_in_with_apple) to pubspec.yaml
//   3. Pass a real SocialAuthPort via kQSpaceClientConfig.socialAdapter below
//   4. Uncomment the OAuth code in the relevant firebase_social_provider.dart method
const kQSpaceSocialConfig = QSocialAuthConfig(
  enabled: false, // flip to true when social adapters are fully wired
  providers: [
    SocialAuthProvider.google,
    SocialAuthProvider.apple,
    SocialAuthProvider.github,
  ],
  dividerLabel: 'Or continue with',
  showOnLogin:  true,
  showOnSignup: true,
);

// ─────────────────────────────────────────────────────────────────────────────
// Biometric config — device biometric sign-in
// ─────────────────────────────────────────────────────────────────────────────

// Currently disabled. To enable:
//   1. Set enabled: true
//   2. Add local_auth: ^2.2.0 to pubspec.yaml
//   3. Add permissions to AndroidManifest.xml + Info.plist (see local_biometric_provider.dart)
//   4. Pass LocalBiometricProvider() via kQSpaceClientConfig.biometricAdapter below
//   5. Uncomment the LocalAuthentication code in local_biometric_provider.dart
const kQSpaceBiometricConfig = QBiometricConfig(
  enabled:       false, // flip to true when local_auth is configured
  promptMessage: 'Authenticate to sign in to QSpace',
  cancelLabel:   'Cancel',
  buttonLabel:   'Use biometrics',
);

// ─────────────────────────────────────────────────────────────────────────────
// Admin config — portal access rules, dev mode, registry key mapping
// ─────────────────────────────────────────────────────────────────────────────
//
// Portal id keys MUST match AdminScreenEntry.id values in kAdminScreenRegistry.
// Any portal id not listed here defaults to hidden (fail-safe).
//
// devModeEnabled: true — shows DEV MODE badge, uses dev* fields instead of
//   live session values. Set false before shipping to production.
//   TODO(auth): once QAuthSession is wired into the shell, set devModeEnabled=false.
const kQSpaceAdminConfig = QAdminConfig(
  tenantId:     _kDefaultTenantId,
  adminTitle:   'QSpace Admin',
  versionLabel: 'QSpace Pages v2.2.0',

  devModeEnabled: true,
  devDisplayName: 'Dev Admin',
  devEmail:       'dev@qspace.local',
  devRoleLabel:   'architect',

  portalAccess: {
    // Dashboard — always read-only. No write operations exist here.
    'dashboard': AdminPortalAccess.readOnly(),

    // Brand — fully editable. Generates brand_config.dart snippets.
    // In production (Cycle 3): AdminConfigProvider.publish() writes overlay.json.
    'brand': AdminPortalAccess(enabled: true, editable: true),

    // Content — not built yet. Registry also marks this locked=true.
    'content': AdminPortalAccess.comingSoon(
      'Content editing ships in Cycle 3 alongside the merge engine '
      'and sub-space keying support.',
    ),

    // Assets — not built yet.
    'assets': AdminPortalAccess.comingSoon(
      'Asset upload + CDN wiring + media library ship in Cycle 3.',
    ),

    // Features — fully editable. Controls space_dev screen toggles.
    'features': AdminPortalAccess(enabled: true, editable: true),

    // Publisher — fully editable. Manages web, app, and desktop publishing.
    'publisher': AdminPortalAccess(enabled: true, editable: true),

    // Settings — portal shell wired, content not built yet.
    'settings': AdminPortalAccess.comingSoon(
      'Settings management ships in Cycle 3. '
      'The portal shell is already wired — content is next.',
    ),
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Router config — extra routes and redirect rules for QSpace
// ─────────────────────────────────────────────────────────────────────────────

const kQSpaceRouterConfig = QRouterConfig(
  initialLocation: '/',
  // extraRoutes: [GoRoute(path: '/onboarding', builder: ...)],
  // extraRedirect: (session, location) { ... },
);

// ─────────────────────────────────────────────────────────────────────────────
// kQSpaceClientConfig — THE MASTER CONFIG
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the single object passed to AppRoot. Everything the QSpace deployment
// needs is captured here. main.dart and main_qspace.dart both use this.
//
// To enable social login:
//   socialAdapter: FirebaseSocialProvider(defaultTenantId: _kDefaultTenantId),
//   AND set kQSpaceSocialConfig.enabled: true above.
//
// To enable biometric:
//   biometricAdapter: LocalBiometricProvider(),
//   AND set kQSpaceBiometricConfig.enabled: true above.
//
// To switch auth backend from REST to Firebase:
//   adapterType: AuthAdapterType.firebase,
//   AND ensure firebase_core + firebase_auth are in pubspec.yaml.

final kQSpaceClientConfig = AppClientConfig(
  adapterType:     AuthAdapterType.restJwt,
  apiBaseUrl:      _kApiBaseUrl,
  defaultTenantId: _kDefaultTenantId,
  auth:            kQSpaceAuthConfig,
  social:          kQSpaceSocialConfig,
  biometric:       kQSpaceBiometricConfig,
  router:          kQSpaceRouterConfig,
  // socialAdapter:    FirebaseSocialProvider(defaultTenantId: _kDefaultTenantId),
  // biometricAdapter: LocalBiometricProvider(),
);