// frontend/lib/spaces/space_admin/admin_portals/publisher_portal/shell_publisher_root.dart

import 'package:flutter/material.dart';
import 'package:qspace_pages/core/style/app_style.dart';

/// Publisher portal root — SCRTSC Shell.
/// Manages all publishing surfaces for a tenant:
///   web status, QPages App (Model 0), Android (Model A/B), Desktop.
///
/// Section implementation schedule:
///   section_publisher_web        → Cycle 1
///   section_publisher_qpages_app → Cycle 1
///   section_publisher_android    → Cycle 2
///   section_publisher_desktop    → Cycle 3
class ShellPublisherRoot extends StatelessWidget {
  const ShellPublisherRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch_outlined, size: 48, color: AppColors.primary),
            SizedBox(height: AppSpacing.md),
            Text('Publishing', style: AppTypography.h3),
            SizedBox(height: AppSpacing.sm),
            Text('Publishing portal — Cycle 1', style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}