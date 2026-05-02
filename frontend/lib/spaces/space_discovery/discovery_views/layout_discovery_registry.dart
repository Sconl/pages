// frontend/lib/spaces/space_discovery/discovery_views/layout_discovery_registry.dart

import 'package:flutter/widgets.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_state/state_discovery_providers.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_templates/template_discovery_home.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_templates/template_discovery_scan.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_templates/template_discovery_loading.dart';

/// Maps a DiscoveryLayout variant to its template builder.
/// shell_discovery_root uses this to stay decoupled from template internals.
///
/// This is the factory layer — it answers: which template should be built?
class LayoutDiscoveryRegistry {
  static Widget buildFor(DiscoveryLayout layout) {
    return switch (layout) {
      DiscoveryLayout.home    => const TemplateDiscoveryHome(),
      DiscoveryLayout.scan    => const TemplateDiscoveryScan(),
      DiscoveryLayout.loading => const TemplateDiscoveryLoading(),
    };
  }
}