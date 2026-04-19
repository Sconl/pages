// lib/core/admin/admin_screen_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — AdminScreenEntry model + kAdminScreenRegistry list.
//     This is the single place to register admin screens. The shell reads
//     this list and builds its nav automatically — no shell changes needed
//     when adding a new admin screen. Ever.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO ADD A NEW ADMIN SCREEN:
//   1. Create your screen file in space_admin/screens/screen_admin_<name>.dart
//   2. Add the import below (uncomment or add a new line)
//   3. Add an AdminScreenEntry to kAdminScreenRegistry
//   4. Done. The shell, nav, IndexedStack — all update automatically.
//
// locked: true = renders a stub instead of the real screen.
// Use it for screens that are spec'd but not implemented yet.

import 'package:flutter/material.dart';
import '../../spaces/space_admin/screen_admin/screen_admin_overview.dart';
import '../../spaces/space_admin/screen_admin/screen_admin_features.dart';
import '../../spaces/space_admin/screen_admin/screen_admin_brand.dart';
// Uncomment these as each screen is built:
// import '../../experience/spaces/space_admin/screens/screen_admin_content.dart';
// import '../../experience/spaces/space_admin/screens/screen_admin_assets.dart';
// import '../../experience/spaces/space_admin/screens/screen_admin_preview.dart';
// import '../../experience/spaces/space_admin/screens/screen_admin_dev.dart';


// ─────────────────────────────────────────────────────────────────────────────
// AdminScreenEntry — the data model for a single nav item + screen
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class AdminScreenEntry {
  /// Short machine-readable id — used for analytics, deeplinks, etc.
  final String id;

  /// Sidebar icon.
  final IconData icon;

  /// Sidebar label — also used as the screen title in mobile AppBar.
  final String label;

  /// The actual screen widget. Ignored (replaced by stub) when locked=true.
  /// Use const constructors here — they're essentially free.
  final Widget screen;

  /// When true the nav item shows a lock icon and tapping is a no-op.
  /// The screen slot shows _LockedScreenStub(note: lockNote) instead.
  final bool locked;

  /// Shown below the lock icon on the stub screen. Explain when it ships.
  final String? lockNote;

  const AdminScreenEntry({
    required this.id,
    required this.icon,
    required this.label,
    required this.screen,
    this.locked = false,
    this.lockNote,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// kAdminScreenRegistry — THE LIST
// ─────────────────────────────────────────────────────────────────────────────
//
// Order here = order in the sidebar. Group logically.
// The shell reads this at build time — it's const so there's zero overhead.

final List<AdminScreenEntry> kAdminScreenRegistry = const [

  AdminScreenEntry(
    id:     'overview',
    icon:   Icons.space_dashboard_outlined,
    label:  'Overview',
    screen: ScreenAdminOverview(),
  ),

  AdminScreenEntry(
    id:     'brand',
    icon:   Icons.palette_outlined,
    label:  'Brand',
    screen: ScreenAdminBrand(),
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
    screen: ScreenAdminFeatures(),
  ),

  AdminScreenEntry(
    id:       'preview',
    icon:     Icons.preview_outlined,
    label:    'Full Preview',
    locked:   true,
    lockNote: 'Full render preview (merge engine + live manifest) ships in Cycle 3.',
    screen:   SizedBox.shrink(),
  ),

  // ── Template for adding a new screen ─────────────────────────────────────
  // 1. Create: space_admin/screens/screen_admin_<name>.dart
  // 2. Import it above
  // 3. Add an entry like this:
  //
  // AdminScreenEntry(
  //   id:    '<name>',
  //   icon:  Icons.<relevant_icon>,
  //   label: '<Label>',
  //   screen: ScreenAdmin<Name>(),
  // ),

];