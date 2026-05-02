// frontend/lib/spaces/space_discovery/discovery_views/discovery_templates/template_discovery_scan.dart

import 'package:flutter/material.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_scanner.dart';

/// The QR camera layout.
/// Full-screen camera with a scanner overlay and a back button.
class TemplateDiscoveryScan extends StatelessWidget {
  const TemplateDiscoveryScan({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen camera section
        const Positioned.fill(child: SectionDiscoveryScanner()),

        // Back button top-left
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: IconButton.filled(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.scrim,
            ),
          ),
        ),

        // Instruction text at bottom
        Positioned(
          bottom: AppSpacing.xxxl,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Text(
            'Point at a QPages QR code',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}