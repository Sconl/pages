// lib/client/qspace/client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Added kQSpaceAuthConfig and kQSpaceRouterConfig.
//   v1.1.1 — Fixed: QRole was undefined — added import for auth_session.dart.
//             QRole is not re-exported by auth_config.dart so it needs its
//             own import here for the const AuthUserClass(role: QRole.*) literals.
//             Fixed: adapter imports updated to lib/core/auth/auth_adapters/.
// ─────────────────────────────────────────────────────────────────────────────

import '../../core/auth/auth_session.dart';   // QRole enum
import '../../core/auth/auth_config.dart';     // QAuthConfig, AuthUserClass
import '../../core/router/router_config.dart'; // QRouterConfig

// ─────────────────────────────────────────────────────────────────────────────
// Adapter selection
// ─────────────────────────────────────────────────────────────────────────────

enum AuthAdapterType { restJwt, firebase }

const kAuthAdapterType = AuthAdapterType.restJwt;

// ─────────────────────────────────────────────────────────────────────────────
// API / Tenant
// ─────────────────────────────────────────────────────────────────────────────

const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

const kDefaultTenantId = String.fromEnvironment(
  'TENANT_ID',
  defaultValue: 'qspace-dev',
);

// ─────────────────────────────────────────────────────────────────────────────
// Auth config (QSpace client)
// ─────────────────────────────────────────────────────────────────────────────

// QRole.user and QRole.clientAdmin are enum values — compile-time constants.
// The missing import was the only thing causing the invalid_constant errors.
const kQSpaceAuthConfig = QAuthConfig(
  tenantId: kDefaultTenantId,
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',          role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Administrator',  role: QRole.clientAdmin),
  ],
  loginHeading:     'Welcome back',
  loginSubheading:  'Sign in to your QSpace account',
  signupHeading:    'Get started',
  signupSubheading: 'Create your QSpace account',
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Router config (QSpace client)
// ─────────────────────────────────────────────────────────────────────────────

const kQSpaceRouterConfig = QRouterConfig(
  initialLocation: '/',
  // extraRoutes: [GoRoute(path: '/onboarding', builder: ...)],
);