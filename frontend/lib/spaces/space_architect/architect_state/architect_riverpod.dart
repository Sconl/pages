// frontend/lib/spaces/space_architect/architect_state/architect_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. All Riverpod state for the architect space.
//                  Kept minimal — architect session is local only.
// ─────────────────────────────────────────────────────────────────────────────
//
// These providers only exist inside ArchitectRoot's ProviderScope.
// They're completely separate from the app's auth providers.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../architect_registry/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Session state
// ─────────────────────────────────────────────────────────────────────────────

/// True after the architect enters the correct credentials.
/// Everything pivots on this — login screen vs. dashboard.
final architectIsLoggedInProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Navigation state
// ─────────────────────────────────────────────────────────────────────────────

/// Which space tab is active in the dashboard sidebar.
/// Starts on the first space in the registry.
final architectSelectedSpaceProvider = StateProvider<String>(
  (ref) => kArchitectSpaces.isNotEmpty ? kArchitectSpaces.first.id : '',
);

/// The screen currently open in the preview, or null if no preview is showing.
final architectPreviewScreenProvider =
    StateProvider<ArchitectScreenEntry?>((ref) => null);

/// The device preset currently selected inside the preview window.
final architectPreviewDeviceProvider = StateProvider<ArchitectDevice>(
  (ref) => ArchitectDevice.mobileM,
);