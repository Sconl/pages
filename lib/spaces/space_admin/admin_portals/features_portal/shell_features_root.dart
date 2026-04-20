// lib/spaces/space_admin/admin_portals/features_portal/shell_features_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Features portal shell — renders kFeaturesSections in a
//             scrollable column. Preview button opens AdminPanelControllerScope.
//             Replaces screen_admin_features.dart.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../widgets/admin_preview_panel.dart';
import 'layout_features_config.dart';
import 'layout_features_registry.dart';

class ShellFeaturesRoot extends StatelessWidget {
  const ShellFeaturesRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kFeatPagePad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kFeatMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(kFeatTitle, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(kFeatSubtitle, style: AppTypography.bodySmall),
                const SizedBox(height: kFeatSectionGap),

                // Sections — dev screen section renders its own sub-headings
                // because it has two distinct groups inside (section vs component toggles).
                // Feature flags section renders a single block.
                ...kFeaturesSections.expand((entry) => [
                  entry.section,
                  const SizedBox(height: kFeatSectionGap),
                ]),

                // Preview panel CTA
                SizedBox(
                  width: double.infinity,
                  height: kFeatPreviewH,
                  child: DecoratedBox(
                    decoration: AppDecorations.primaryButton,
                    child: ElevatedButton.icon(
                      onPressed: () => AdminPanelControllerScope.of(context).open(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
                      ),
                      icon: const Icon(Icons.preview_outlined, size: 18, color: Colors.white),
                      label: Text(kFeatPreviewLabel, style: AppTypography.button),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}