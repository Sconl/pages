// frontend/lib/spaces/space_architect/architect_state/architect_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_state → architect_state.
//                  Import corrected: space_architect_model → architect_model.
//   • 2026-04-25 — Initial. Architect session, navigation, and preview state.
// ─────────────────────────────────────────────────────────────────────────────
//
// These providers live inside ArchitectRoot's own isolated ProviderScope —
// completely separate from the production app providers in AppRoot.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Session state
// ─────────────────────────────────────────────────────────────────────────────

/// Flips true after the architect submits valid credentials.
/// All navigation in the space pivots on this.
final architectIsLoggedInProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard navigation state
// ─────────────────────────────────────────────────────────────────────────────

/// Which space is selected in the dashboard sidebar.
/// Seeded with the first space so the grid is never empty on load.
final architectSelectedSpaceProvider = StateProvider<String>(
  (ref) => kArchitectSpaces.isNotEmpty ? kArchitectSpaces.first.id : '',
);

// ─────────────────────────────────────────────────────────────────────────────
// Preview state
// ─────────────────────────────────────────────────────────────────────────────

/// The device preset active in the preview portal's device bar.
final architectPreviewDeviceProvider = StateProvider<ArchitectDevice>(
  (ref) => ArchitectDevice.mobileM,
);