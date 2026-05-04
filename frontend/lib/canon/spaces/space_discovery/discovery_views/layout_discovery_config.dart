// frontend/lib/spaces/space_discovery/discovery_views/layout_discovery_config.dart

import 'package:qspace_pages/canon/spaces/space_discovery/discovery_state/state_discovery_providers.dart';

/// Defines which layout variant is active for the discovery space.
/// Read by shell_discovery_root to select the correct template from the registry.
///
/// This is the decision layer — it answers: what should exist in this layout?
class LayoutDiscoveryConfig {
  final DiscoveryLayout activeLayout;

  const LayoutDiscoveryConfig({required this.activeLayout});

  /// Whether the search section should be visible in the current layout.
  bool get showSearch => activeLayout == DiscoveryLayout.home;

  /// Whether the recent spaces section should be visible.
  bool get showRecent => activeLayout == DiscoveryLayout.home;

  /// Whether the QR scanner surface should be visible.
  bool get showScanner => activeLayout == DiscoveryLayout.scan;

  /// Whether the loading/status section should be visible.
  bool get showStatus => activeLayout == DiscoveryLayout.loading;
}