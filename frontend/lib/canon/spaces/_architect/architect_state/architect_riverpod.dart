// frontend/lib/spaces/_architect/architect_state/architect_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Import changed from architect_screen_registry to
//                  architect_auto_registry so kArchitectSpaces resolves to the
//                  assembled list, not a missing symbol.
//   • 2026-04-26 — Path corrected: space_architect → _architect.
//   • 2026-04-25 — Initial.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the assembled list, not the types-only file
import '../architect_model/architect_auto_registry.dart';
import '../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Session state
// ─────────────────────────────────────────────────────────────────────────────

/// Flips true after the architect submits valid credentials.
final architectIsLoggedInProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard navigation state
// ─────────────────────────────────────────────────────────────────────────────

/// Which space is selected in the dashboard sidebar.
/// Seeded with the first space in the assembled registry.
final architectSelectedSpaceProvider = StateProvider<String>(
  (ref) => kArchitectSpaces.isNotEmpty ? kArchitectSpaces.first.id : '',
);

// ─────────────────────────────────────────────────────────────────────────────
// Preview state
// ─────────────────────────────────────────────────────────────────────────────

/// Active device preset in the preview portal.
final architectPreviewDeviceProvider = StateProvider<ArchitectDevice>(
  (ref) => ArchitectDevice.mobileM,
);