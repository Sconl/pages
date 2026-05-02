// frontend/lib/spaces/_architect/architect_model/architect_auto_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Assembles kArchitectSpaces from per-space files.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO ADD A NEW SPACE:
//   1. Create frontend/lib/spaces/_architect/space_registrations/{name}_registration.dart
//      (copy any existing registration file as a template)
//   2. Import it below and add its kRegister{Name}Space to kArchitectSpaces
//   3. Done — it appears in the architect dashboard automatically
//
// The registration file owns: space id, label, icon, accent colour, and the
// list of ArchitectScreenEntry items. This file just assembles the list.

import 'architect_screen_registry.dart';

// ── Space registration imports ────────────────────────────────────────────────
// Add one import + one list entry per new space. Nothing else needs to change.
import '../space_registrations/space_auth_registration.dart';
import '../space_registrations/space_value_registration.dart';
import '../space_registrations/space_admin_registration.dart';
import '../space_registrations/space_site_registration.dart';
import '../space_registrations/space_dev_registration.dart';

// ─────────────────────────────────────────────────────────────────────────────
// kArchitectSpaces — assembled from all registration files
// ─────────────────────────────────────────────────────────────────────────────
//
// Order here = order in the dashboard sidebar.
// Each item is the singleton exported from the corresponding registration file.

final List<ArchitectSpace> kArchitectSpaces = [
  kRegisterSpaceAuth,
  kRegisterSpaceValue,
  kRegisterSpaceAdmin,
  kRegisterSpaceSite,
  kRegisterSpaceDev,
];