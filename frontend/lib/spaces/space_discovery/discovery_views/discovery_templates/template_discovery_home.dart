// frontend/lib/spaces/space_discovery/discovery_views/discovery_templates/template_discovery_home.dart

import 'package:flutter/material.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_search.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_recent.dart';

/// The "find your space" layout — the default home state of space_discovery.
///
/// Arranges:
///   ↳ QPages logo (top)
///   ↳ Heading + sub-heading
///   ↳ section_discovery_search (URL input + buttons)
///   ↳ section_discovery_recent (recently visited spaces — hidden when empty)
class TemplateDiscoveryHome extends StatelessWidget {
  const TemplateDiscoveryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical:   AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QPages wordmark
          BrandLogoEngine.horizontalColored(height: 26),

          SizedBox(height: AppSpacing.xxxl),

          // Heading
          Text('Find your space', style: AppTypography.h2),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Enter your organisation\'s URL, or scan a QR code.',
            style: AppTypography.bodyLarge,
          ),

          SizedBox(height: AppSpacing.xl),

          // Search input + action buttons
          const SectionDiscoverySearch(),

          SizedBox(height: AppSpacing.xl),

          // Recently visited spaces (hidden when list is empty)
          const SectionDiscoveryRecent(),
        ],
      ),
    );
  }
}