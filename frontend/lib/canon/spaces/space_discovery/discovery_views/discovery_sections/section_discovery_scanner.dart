// frontend/lib/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_scanner.dart

import 'package:flutter/material.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/canon/spaces/space_discovery/discovery_views/discovery_widgets/widget_discovery_qr_overlay.dart';

/// QR camera surface.
/// Stub for Pre-Cycle 0 / Cycle 1 start.
/// Full implementation uses mobile_scanner package — add in Cycle 1.
///
/// When implemented:
///   - MobileScannerController detects QR codes in camera feed
///   - On detection: calls DeepLinkResolver.resolveUri() on the QR content
///   - On valid tenantId: sets pendingTenantIdProvider + switches to loading layout
///   - On invalid content: shows brief error toast, continues scanning
class SectionDiscoveryScanner extends StatelessWidget {
  const SectionDiscoveryScanner({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO (Cycle 1): Replace container with MobileScanner widget
    return Stack(
      children: [
        // Placeholder camera view
        Container(
          color: AppColors.background,
          child: Center(
            child: Text(
              'Camera — implement with mobile_scanner in Cycle 1',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // QR viewfinder overlay (visual guide)
        const Positioned.fill(child: WidgetDiscoveryQrOverlay()),
      ],
    );
  }
}