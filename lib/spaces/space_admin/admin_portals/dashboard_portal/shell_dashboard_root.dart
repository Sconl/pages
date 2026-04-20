// lib/spaces/space_admin/admin_portals/dashboard_portal/shell_dashboard_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Dashboard portal shell — reads kDashboardSections from
//             layout_dashboard_registry.dart and renders them in a scrollable
//             column with consistent section headers. Replaces screen_admin_overview.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import 'layout_dashboard_config.dart';
import 'layout_dashboard_registry.dart';

class ShellDashboardRoot extends StatelessWidget {
  const ShellDashboardRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDashPagePad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kDashMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(kDashTitle, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(kDashSubtitle, style: AppTypography.bodySmall),
                const SizedBox(height: kDashSectionGap),

                // Sections from registry — each gets a labelled heading
                ...kDashboardSections.expand((entry) => [
                  Text(entry.label.toUpperCase(), style: AppTypography.overline),
                  const SizedBox(height: 12),
                  entry.section,
                  const SizedBox(height: kDashSectionGap),
                ]),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}