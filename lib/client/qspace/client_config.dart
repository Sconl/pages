// lib/client/qspace/client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Added kQSpaceAuthConfig and kQSpaceRouterConfig.
//   v1.1.1 — Fixed: QRole undefined — added import for auth_session.dart.
//             Fixed: adapter imports updated to lib/core/auth/auth_adapters/.
//   v1.2.0 — Added kQSpaceAdminConfig — the QSpace admin system config.
//             Renders the admin system with QSpace-specific portal access rules,
//             dev mode enabled (architect tier, all built portals editable),
//             and matching portal ids to kAdminScreenRegistry entries.
// ─────────────────────────────────────────────────────────────────────────────
//
// WIRING:
//   In main.dart (or AppRoot):
//     QAdminShell(config: kQSpaceAdminConfig)
//
//   The shell wraps QAdminConfigScope internally, so all portals automatically
//   read the right access rules without any further prop drilling.

import '../../core/auth/auth_session.dart';      // QRole enum
import '../../core/auth/auth_config.dart';        // QAuthConfig, AuthUserClass
import '../../core/router/router_config.dart';    // QRouterConfig
import '../../core/admin/admin_config.dart';      // QAdminConfig, AdminPortalAccess

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
// Auth config — QSpace client
// ─────────────────────────────────────────────────────────────────────────────

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
// Router config — QSpace client
// ─────────────────────────────────────────────────────────────────────────────

const kQSpaceRouterConfig = QRouterConfig(
  initialLocation: '/',
  // extraRoutes: [GoRoute(path: '/onboarding', builder: ...)],
);

// ─────────────────────────────────────────────────────────────────────────────
// Admin config — QSpace client
// ─────────────────────────────────────────────────────────────────────────────
//
// Portal id keys MUST match AdminScreenEntry.id values in kAdminScreenRegistry.
// Any portal id not listed here is hidden by default (fail-safe).
//
// devModeEnabled = true → shows DEV MODE badge in sidebar, uses devDisplayName/
//   devEmail/devRoleLabel instead of live session values.
//   Set to false (or switch to kAdminConfigClientAdmin) before production deploy.
//
// TODO(auth): once QAuthSession is wired into the shell, set devModeEnabled=false
// and let the shell read displayName/email/role from the session directly.

const kQSpaceAdminConfig = QAdminConfig(
  tenantId:     kDefaultTenantId,
  adminTitle:   'QSpace Admin',
  versionLabel: 'QSpace Pages v2.2.0',

  // Dev mode — architect tier has full write access to all implemented portals.
  devModeEnabled: true,
  devDisplayName: 'Dev Admin',
  devEmail:       'dev@qspace.local',
  devRoleLabel:   'architect',

  portalAccess: {

    // Dashboard — always read-only. No write ops exist here.
    'dashboard': AdminPortalAccess.readOnly(),

    // Brand — fully editable in dev. Generates brand_config.dart snippets.
    // In production (Cycle 3): AdminConfigProvider.publish() writes overlay.json.
    'brand': AdminPortalAccess(enabled: true, editable: true),

    // Content — not built yet. Registry also marks this locked=true.
    // Both gates must be false for the portal to be accessible.
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

    // Settings — portal is wired but content not built. Config-level lock
    // so individual tenants can unlock it independently of the registry.
    'settings': AdminPortalAccess.comingSoon(
      'Settings management ships in Cycle 3. '
      'The portal shell is already wired — content is next.',
    ),

  },
);