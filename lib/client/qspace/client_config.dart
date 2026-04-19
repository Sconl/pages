// lib/client/qspace/client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. kAuthAdapterType, kApiBaseUrl, kDefaultTenantId.
//             Zero-touch adapter switching.
//   v1.1.0 — Added kQSpaceAuthConfig and kQSpaceRouterConfig.
//             These are the QSpace-specific overrides passed to AppRoot.
//             All auth behavior and routing customization for the QSpace client
//             lives here — no other file needs to change for client-specific tuning.
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the ONLY file that changes between deployments.
// To switch tenants or adapters: change values here. Touch nothing else.
//
// To add a new client (e.g., Acme Corp):
//   1. Create lib/client/acme/client_config.dart with the right constants.
//   2. Create main_acme.dart that passes acme's configs to AppRoot.
//   3. Done. Zero changes to any core file.

import '../../core/auth/auth_config.dart';
import '../../core/router/router_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Adapter selection
// ─────────────────────────────────────────────────────────────────────────────

enum AuthAdapterType { restJwt, firebase }

// Change this line to switch adapters. That's it.
const kAuthAdapterType = AuthAdapterType.restJwt;

// ─────────────────────────────────────────────────────────────────────────────
// API / Tenant
// ─────────────────────────────────────────────────────────────────────────────

// Override at build time: --dart-define=API_BASE_URL=https://api.qspace.co
const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

// Override at build time: --dart-define=TENANT_ID=acme-prod
const kDefaultTenantId = String.fromEnvironment(
  'TENANT_ID',
  defaultValue: 'qspace-dev',
);

// ─────────────────────────────────────────────────────────────────────────────
// Auth config (QSpace client)
// ─────────────────────────────────────────────────────────────────────────────

// QSpace shows a User / Administrator toggle.
// Admins land on /admin after login. Users land on /.
// Flip to kAuthConfigSingleUser for a B2C product with no admin access.
// Flip to kAuthConfigDeveloper for internal tooling during dev.
const kQSpaceAuthConfig = QAuthConfig(
  tenantId: kDefaultTenantId,
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',          role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Administrator',  role: QRole.clientAdmin),
  ],
  loginHeading:    'Welcome back',
  loginSubheading: 'Sign in to your QSpace account',
  signupHeading:   'Get started',
  signupSubheading: 'Create your QSpace account',
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Router config (QSpace client)
// ─────────────────────────────────────────────────────────────────────────────

// Add client-specific routes here (e.g., /onboarding, /checkout) without
// touching lib/core/router/app_router.dart.
const kQSpaceRouterConfig = QRouterConfig(
  initialLocation: '/',
  // extraRoutes: [GoRoute(path: '/onboarding', builder: ...)],
);