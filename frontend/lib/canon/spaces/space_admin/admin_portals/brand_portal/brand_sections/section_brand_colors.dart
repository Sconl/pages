// lib/spaces/space_admin/admin_portals/brand_portal/brand_sections/section_brand_colors.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. 60-30-10 bar + three color token cards with picker.
//             Reads/writes AdminBrandDraft. Editable gate via QAdminConfigScope.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../../core/style/app_style.dart';
import '../../../../../../core/admin/admin_brand_draft.dart';
import '../../../../../../core/admin/admin_config.dart';
import '../brand_widgets/widget_sixty_thirty_ten.dart';
import '../brand_widgets/widget_color_token_card.dart';
import '../brand_widgets/widget_color_picker_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const String _kPrimaryGuidance =
    '60% — Dominant brand identity. Hero sections, primary CTAs, focus rings, '
    'navigation highlights. The most recognizable color in your brand. '
    'Use confidently across large surfaces.';
const String _kSecondaryGuidance =
    '30% — Supporting accent. Info chips, secondary CTAs, constellation lines, '
    'complementary UI elements. Should contrast with Primary without competing. '
    'Use to guide attention after Primary draws the eye.';
const String _kTertiaryGuidance =
    '10% — Warm accent. Use sparingly — live badges, notification highlights, '
    'special callouts, tertiary CTAs. Overusing it dilutes its impact. '
    'Reserve for genuinely important moments.';

// ─────────────────────────────────────────────────────────────────────────────

class SectionBrandColors extends StatelessWidget {
  const SectionBrandColors({super.key});

  Future<void> _pickColor(
    BuildContext context,
    Color current,
    void Function(Color) onPick,
  ) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => WidgetColorPickerDialog(initialColor: current),
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final draft    = AdminBrandDraftScope.of(context);
    final editable = QAdminConfigScope.of(context).accessFor('brand').editable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 60-30-10 bar
        WidgetSixtyThirtyTen(
          primary:   draft.draftPrimary,
          secondary: draft.draftSecondary,
          tertiary:  draft.draftTertiary,
        ),
        const SizedBox(height: 8),
        Text(
          editable
              ? 'Tap any color card to edit. The bar reflects proportional usage.'
              : 'Read-only view. Contact your administrator to edit brand colors.',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 20),

        WidgetColorTokenCard(
          label:    'Primary',
          role:     '60% Dominant',
          color:    draft.draftPrimary,
          guidance: _kPrimaryGuidance,
          onEdit:   editable
              ? () => _pickColor(context, draft.draftPrimary, draft.setPrimary)
              : () {},
        ),
        const SizedBox(height: 12),

        WidgetColorTokenCard(
          label:    'Secondary',
          role:     '30% Supporting',
          color:    draft.draftSecondary,
          guidance: _kSecondaryGuidance,
          onEdit:   editable
              ? () => _pickColor(context, draft.draftSecondary, draft.setSecondary)
              : () {},
        ),
        const SizedBox(height: 12),

        WidgetColorTokenCard(
          label:    'Tertiary',
          role:     '10% Accent',
          color:    draft.draftTertiary,
          guidance: _kTertiaryGuidance,
          onEdit:   editable
              ? () => _pickColor(context, draft.draftTertiary, draft.setTertiary)
              : () {},
        ),
      ],
    );
  }
}