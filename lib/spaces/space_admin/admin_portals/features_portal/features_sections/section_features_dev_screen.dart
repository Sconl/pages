// lib/spaces/space_admin/admin_portals/features_portal/features_sections/section_features_dev_screen.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Section A + B visibility toggles for space_dev screens.
//             Reads/writes DevScreenSettings via DevScreenSettingsScope.
//             Extracted from screen_admin_features.dart.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../../../../../core/admin/dev_screen_settings.dart';
import '../features_widgets/widget_toggle_row.dart';
import '../layout_features_config.dart';

class SectionFeaturesDevScreen extends StatelessWidget {
  const SectionFeaturesDevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = DevScreenSettingsScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section A — section-level gates
        Text(
          'ROADMAP SCREEN — SECTION VISIBILITY',
          style: AppTypography.overline,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: [
              WidgetToggleRow(
                label:       'Core Section',
                description: 'Identity, architecture layers, branch status',
                value:       settings.showSectionCore,
                onChanged:   settings.setSectionCore,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Context Section',
                description: 'Roadmap, phase cards, countdown, progress bar',
                value:       settings.showSectionContext,
                onChanged:   settings.setSectionContext,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Connect Section',
                description: 'Active step, commit target, distribution models',
                value:       settings.showSectionConnect,
                onChanged:   settings.setSectionConnect,
              ),
            ],
          ),
        ),
        const SizedBox(height: kFeatSectionGap),

        // Section B — component-level gates
        Text(
          'ROADMAP SCREEN — COMPONENT VISIBILITY',
          style: AppTypography.overline,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: [
              WidgetToggleRow(
                label:       'Branch Status',
                description: 'Branch name + current phase pills in section_core',
                value:       settings.showBranchStatus,
                onChanged:   settings.setBranchStatus,
                dimmed:      !settings.showSectionCore,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Architecture Layers',
                description: 'Layer badge row (canon, suite, client, etc.)',
                value:       settings.showArchLayers,
                onChanged:   settings.setArchLayers,
                dimmed:      !settings.showSectionCore,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Countdown Timer',
                description: 'Live MVP countdown badge in section_context header',
                value:       settings.showCountdown,
                onChanged:   settings.setCountdown,
                dimmed:      !settings.showSectionContext,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Progress Bar',
                description: 'Overall sprint progress bar below the ROADMAP label',
                value:       settings.showProgressBar,
                onChanged:   settings.setProgressBar,
                dimmed:      !settings.showSectionContext,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Phase Cards',
                description: 'Horizontal scrolling phase card list',
                value:       settings.showPhaseCards,
                onChanged:   settings.setPhaseCards,
                dimmed:      !settings.showSectionContext,
              ),
              Divider(height: 1, color: AppColors.border),
              WidgetToggleRow(
                label:       'Distribution Models',
                description: 'Model 1 / 2 / 3 badges in section_connect',
                value:       settings.showDistModels,
                onChanged:   settings.setDistModels,
                dimmed:      !settings.showSectionConnect,
              ),
            ],
          ),
        ),
        const SizedBox(height: kFeatSectionGap),

        // Restore defaults button
        GestureDetector(
          onTap: () {
            settings.resetToDefaults();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Dev screen settings restored to defaults.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
              backgroundColor: AppColors.surfaceLit,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: AppRadius.cardBR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restore_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(kFeatRestoreLabel, style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}