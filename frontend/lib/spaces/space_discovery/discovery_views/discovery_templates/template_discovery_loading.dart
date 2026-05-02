// frontend/lib/spaces/space_discovery/discovery_views/discovery_templates/template_discovery_loading.dart

import 'package:flutter/material.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_status.dart';

/// The resolving/loading layout.
/// Shown while GET /api/app/resolve/{tenantId} is in flight.
/// Centred loader + status message — full screen.
class TemplateDiscoveryLoading extends StatelessWidget {
  const TemplateDiscoveryLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: const SectionDiscoveryStatus(),
      ),
    );
  }
}