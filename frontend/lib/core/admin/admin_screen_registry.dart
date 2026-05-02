// lib/core/admin/admin_screen_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AdminScreenEntry + kAdminScreenRegistry flat list.
//   v1.1.0 — Refactored to portal architecture. Imports point to portal shells.
//             screen_admin/ folder replaced by admin_portals/. Registry entries
//             carry ids matching QAdminConfig.portalAccess keys.
//   v1.2.0 — Added 'publisher' portal entry (ShellPublisherRoot).
//             AdminScreenEntry extended with optional activeIcon, route,
//             and description fields to support publisher portal metadata.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO ADD A NEW PORTAL:
//   1. mkdir lib/spaces/space_admin/admin_portals/<n>_portal/
//   2. Build: shell_<n>_root.dart + layout_<n>_config/registry + sections + widgets
//   3. Import shell below (add a new import line)
//   4. Add AdminScreenEntry to kAdminScreenRegistry
//   5. Add AdminPortalAccess entry to QAdminConfig presets in admin_config.dart
//   6. Add the QSpace config entry in client_config.dart
//   Done — shell, nav, IndexedStack, config access all update automatically.

import 'package:flutter/material.dart';
import '../../spaces/space_admin/admin_portals/dashboard_portal/shell_dashboard_root.dart';
import '../../spaces/space_admin/admin_portals/brand_portal/shell_brand_root.dart';
import '../../spaces/space_admin/admin_portals/features_portal/shell_features_root.dart';
import '../../spaces/space_admin/admin_portals/settings_portal/shell_settings_root.dart';
import '../../spaces/space_admin/admin_portals/publisher_portal/shell_publisher_root.dart';
// Add portal shells as they're built:
// import '../../spaces/space_admin/admin_portals/content_portal/shell_content_root.dart';
// import '../../spaces/space_admin/admin_portals/assets_portal/shell_assets_root.dart';
// import '../../spaces/space_admin/admin_portals/pricing_portal/shell_pricing_root.dart';
// import '../../spaces/space_admin/admin_portals/profile_portal/shell_profile_root.dart';


// ─────────────────────────────────────────────────────────────────────────────
// AdminScreenEntry — top-level nav item + portal shell
// ─────────────────────────────────────────────────────────────────────────────
//
// id must match the key in QAdminConfig.portalAccess.
// The shell merges the registry list with the runtime config at build time.

@immutable
class AdminScreenEntry {
  final String    id;          // matches QAdminConfig.portalAccess key
  final IconData  icon;
  final IconData? activeIcon;  // optional filled/rounded variant for selected state
  final String    label;
  final String?   description; // optional tooltip / subtitle copy
  final String?   route;       // optional explicit route path (used by publisher etc.)
  final Widget    screen;      // the portal shell widget
  final bool      locked;      // registry-level lock (not built yet)
  final String?   lockNote;

  const AdminScreenEntry({
    required this.id,
    required this.icon,
    required this.label,
    required this.screen,
    this.activeIcon,
    this.description,
    this.route,
    this.locked   = false,
    this.lockNote,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// kAdminScreenRegistry
// ─────────────────────────────────────────────────────────────────────────────
//
// Order = sidebar order. The shell merges this with QAdminConfig at build time.
// Registry locked=true always wins — config cannot unlock what isn't implemented.

final List<AdminScreenEntry> kAdminScreenRegistry = const [

  AdminScreenEntry(
    id:     'dashboard',
    icon:   Icons.space_dashboard_outlined,
    label:  'Dashboard',
    screen: ShellDashboardRoot(),
  ),

  AdminScreenEntry(
    id:     'brand',
    icon:   Icons.palette_outlined,
    label:  'Brand',
    screen: ShellBrandRoot(),
  ),

  AdminScreenEntry(
    id:       'content',
    icon:     Icons.edit_note_outlined,
    label:    'Content',
    locked:   true,
    lockNote: 'Content editing ships in Cycle 3 alongside the merge engine '
              'and sub-space keying support.',
    screen:   SizedBox.shrink(),
  ),

  AdminScreenEntry(
    id:       'assets',
    icon:     Icons.photo_library_outlined,
    label:    'Assets',
    locked:   true,
    lockNote: 'Asset upload + CDN wiring + media library ship in Cycle 3.',
    screen:   SizedBox.shrink(),
  ),

  AdminScreenEntry(
    id:     'features',
    icon:   Icons.tune_outlined,
    label:  'Features',
    screen: ShellFeaturesRoot(),
  ),

  AdminScreenEntry(
    id:          'publisher',
    icon:        Icons.rocket_launch_outlined,
    activeIcon:  Icons.rocket_launch_rounded,
    label:       'Publishing',
    description: 'Manage your web, app, and desktop publishing',
    route:       '/admin/publisher',
    screen:      ShellPublisherRoot(),
  ),

  AdminScreenEntry(
    id:     'settings',
    icon:   Icons.settings_outlined,
    label:  'Settings',
    screen: ShellSettingsRoot(),
    // Not registry-locked — ShellSettingsRoot handles its own stub state
    // based on QAdminConfig.accessFor('settings').locked at runtime.
  ),

  // ── Template ─────────────────────────────────────────────────────────────
  // AdminScreenEntry(
  //   id:          '<n>',
  //   icon:        Icons.<icon>,
  //   activeIcon:  Icons.<icon_filled>,
  //   label:       '<Label>',
  //   description: '<Short description>',
  //   route:       '/admin/<n>',
  //   screen:      Shell<N>Root(),
  // ),

];