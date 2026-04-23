// lib/core/admin/admin_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Modeled after auth_config.dart — the single configurable
//             location for all admin behavior: which portals are exposed, what's
//             editable, dev mode, header copy. Zero project-specific imports.
//             Pure Dart. Override via QAdminConfigScope per tenant.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO CUSTOMIZE FOR A TENANT:
//   1. Define a const QAdminConfig with the right portal access rules.
//   2. Wrap QAdminShell with QAdminConfigScope(config: yourConfig, child: shell).
//   3. Touch nothing else — portals, the shell, and nav all read from this config.
//
// WHY THIS EXISTS:
//   Without a central config, portal visibility and edit rights leak into screen
//   logic. When a new tenant needs read-only brand access but full feature flag
//   control, that's one change here — not a portal edit.
//
// DEPENDENCY CHAIN:
//   admin_config.dart  ←  client_config.dart (kQSpaceAdminConfig)
//   admin_config.dart  →  admin_screen_registry.dart (registry merge)
//   admin_config.dart  →  q_admin_shell.dart (QAdminConfigScope)
//   admin_config.dart  →  portal shells (editability gate)

import 'package:flutter/material.dart';


// ─────────────────────────────────────────────────────────────────────────────
// AdminPortalAccess — per-portal access rules
// ─────────────────────────────────────────────────────────────────────────────
//
// enabled:  show the portal in the sidebar nav at all
// editable: allow write operations (vs read-only display)
// locked:   render as a coming-soon stub instead of the real portal
// lockNote: message shown on the stub screen — explain when it ships

class AdminPortalAccess {
  final bool enabled;
  final bool editable;
  final bool locked;
  final String? lockNote;

  const AdminPortalAccess({
    this.enabled  = true,
    this.editable = false,
    this.locked   = false,
    this.lockNote,
  });

  // Convenience constructors — keep client configs readable.

  const AdminPortalAccess.active({bool editable = false})
      : enabled  = true,
        this.editable = editable,
        locked   = false,
        lockNote = null;

  const AdminPortalAccess.readOnly()
      : enabled  = true,
        editable = false,
        locked   = false,
        lockNote = null;

  const AdminPortalAccess.comingSoon(String note)
      : enabled  = true,
        editable = false,
        locked   = true,
        lockNote = note;

  const AdminPortalAccess.hidden()
      : enabled  = false,
        editable = false,
        locked   = false,
        lockNote = null;

  // Merged view — a registry entry's locked flag is an additional gate.
  // If the registry says locked=true AND the config says locked=false, the
  // registry wins (the feature literally isn't built yet).
  AdminPortalAccess mergeWithRegistryLocked(bool registryLocked, String? registryNote) {
    if (registryLocked) {
      return AdminPortalAccess.comingSoon(registryNote ?? lockNote ?? 'Coming soon.');
    }
    return this;
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// QAdminConfig — everything about this admin instance in one place
// ─────────────────────────────────────────────────────────────────────────────

class QAdminConfig {
  // Which tenant this config belongs to — used in logs and future multi-tenant work.
  final String tenantId;

  // Displayed in the sidebar header.
  final String adminTitle;
  final String versionLabel;

  // In dev mode the shell shows a warning badge and uses devDisplayName/devRole
  // instead of the live session values. Set false before production deployment.
  // TODO(auth): set devModeEnabled = false when auth is wired and session is live.
  final bool   devModeEnabled;
  final String devDisplayName;
  final String devEmail;
  final String devRoleLabel;

  // Portal access map — keyed by portal id (must match AdminScreenEntry.id).
  // Portals not in this map default to hidden.
  final Map<String, AdminPortalAccess> portalAccess;

  const QAdminConfig({
    required this.tenantId,
    this.adminTitle     = 'Admin Panel',
    this.versionLabel   = 'QSpace Pages v2.2.0',
    this.devModeEnabled = false,
    this.devDisplayName = 'Dev Admin',
    this.devEmail       = 'dev@local',
    this.devRoleLabel   = 'developer',
    required this.portalAccess,
  });

  // Returns the access rules for a given portal id.
  // Portals not in the map are hidden — fail safe, never accidental exposure.
  AdminPortalAccess accessFor(String portalId) {
    return portalAccess[portalId] ?? const AdminPortalAccess.hidden();
  }

  // Merges this config with the registry-level locked flag for a portal.
  // The registry is the ground truth for "not built yet" — config can't
  // unlock what isn't implemented.
  AdminPortalAccess effectiveAccessFor(
    String portalId, {
    required bool registryLocked,
    String? registryLockNote,
  }) {
    final access = accessFor(portalId);
    if (!access.enabled) return const AdminPortalAccess.hidden();
    return access.mergeWithRegistryLocked(registryLocked, registryLockNote);
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Canonical preset configs — compose from these or define your own
// ─────────────────────────────────────────────────────────────────────────────

// Full access — for architect-level development use only.
// devModeEnabled intentionally left true so the dev badge shows.
const kAdminConfigDeveloper = QAdminConfig(
  tenantId:     'dev',
  adminTitle:   'Admin Panel',
  devModeEnabled: true,
  devDisplayName: 'Dev Admin',
  devEmail:       'dev@local',
  devRoleLabel:   'architect',
  portalAccess: {
    'dashboard': AdminPortalAccess.readOnly(),
    'brand':     AdminPortalAccess(enabled: true, editable: true),
    'content':   AdminPortalAccess.comingSoon('Content editing ships in Cycle 3.'),
    'assets':    AdminPortalAccess.comingSoon('Asset management ships in Cycle 3.'),
    'features':  AdminPortalAccess(enabled: true, editable: true),
    'settings':  AdminPortalAccess.comingSoon('Settings management ships in Cycle 3.'),
  },
);

// Production client admin — edits brand + features, content is read-only.
// devModeEnabled = false — no dev badge in production.
const kAdminConfigClientAdmin = QAdminConfig(
  tenantId:     'default',
  adminTitle:   'Admin Panel',
  devModeEnabled: false,
  devDisplayName: '',
  devEmail:       '',
  devRoleLabel:   'clientAdmin',
  portalAccess: {
    'dashboard': AdminPortalAccess.readOnly(),
    'brand':     AdminPortalAccess(enabled: true, editable: true),
    'content':   AdminPortalAccess.comingSoon('Content editing ships in Cycle 3.'),
    'assets':    AdminPortalAccess.comingSoon('Asset management ships in Cycle 3.'),
    'features':  AdminPortalAccess(enabled: true, editable: true),
    'settings':  AdminPortalAccess.hidden(),
  },
);


// ─────────────────────────────────────────────────────────────────────────────
// QAdminConfigScope — InheritedWidget wrapper
// ─────────────────────────────────────────────────────────────────────────────
//
// USAGE:
//   QAdminConfigScope(
//     config: kQSpaceAdminConfig,  // from client_config.dart
//     child: QAdminShell(),
//   )
//
//   // Reading in any descendant:
//   final cfg = QAdminConfigScope.of(context);
//   if (cfg.accessFor('brand').editable) { ... }

class QAdminConfigScope extends InheritedWidget {
  final QAdminConfig config;

  const QAdminConfigScope({
    super.key,
    required this.config,
    required super.child,
  });

  // Never null — falls back to kAdminConfigDeveloper if no scope exists.
  // This keeps portals functional in isolated widget tests.
  static QAdminConfig of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<QAdminConfigScope>()
            ?.config ??
        kAdminConfigDeveloper;
  }

  @override
  bool updateShouldNotify(QAdminConfigScope old) => config != old.config;
}