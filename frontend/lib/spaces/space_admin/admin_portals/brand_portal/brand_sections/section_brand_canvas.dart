// lib/spaces/space_admin/admin_portals/brand_portal/brand_sections/section_brand_canvas.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. CanvasPersonality + MotionIntensity dropdown rows with
//             guidance copy explaining each option. Writes to AdminBrandDraft.
//             Editable gate via QAdminConfigScope.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../../../../../core/admin/admin_brand_draft.dart';
import '../../../../../core/admin/admin_config.dart';
import '../../../../../core/style/brand_config.dart';

class SectionBrandCanvas extends StatelessWidget {
  const SectionBrandCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final draft    = AdminBrandDraftScope.of(context);
    final editable = QAdminConfigScope.of(context).accessFor('brand').editable;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _DropdownRow<CanvasPersonality>(
            label: 'Canvas Personality',
            guidance:
                'energetic = constellation particles. calm = aurora, no particles. '
                'minimal = solid background. corporate = dot grid + mesh gradient. '
                'dramatic = aurora with sweep gradient. custom = explicit override.',
            value:       draft.draftCanvasPersonality,
            items:       CanvasPersonality.values,
            displayName: (v) => v.name,
            enabled:     editable,
            onChanged:   draft.setCanvasPersonality,
          ),
          Divider(height: 24, color: AppColors.border),
          _DropdownRow<MotionIntensity>(
            label: 'Motion Intensity',
            guidance:
                'full = animated canvas with particles (default). '
                'subtle = gentle gradient transitions only, no particles. '
                'none = completely static — best for accessibility (prefers-reduced-motion).',
            value:       draft.draftMotionIntensity,
            items:       MotionIntensity.values,
            displayName: (v) => v.name,
            enabled:     editable,
            onChanged:   draft.setMotionIntensity,
          ),
        ],
      ),
    );
  }
}


class _DropdownRow<T> extends StatelessWidget {
  final String           label;
  final String           guidance;
  final T                value;
  final List<T>          items;
  final String Function(T) displayName;
  final bool             enabled;
  final ValueChanged<T>  onChanged;

  const _DropdownRow({
    required this.label,
    required this.guidance,
    required this.value,
    required this.items,
    required this.displayName,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.body.copyWith(fontSize: 13)),
              const SizedBox(height: 4),
              Text(guidance, style: AppTypography.caption.copyWith(
                color: AppColors.textMuted, height: 1.4, fontSize: 10,
              )),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: DropdownButton<T>(
              value: value,
              dropdownColor: AppColors.surfaceLit,
              style: AppTypography.bodySmall.copyWith(fontSize: 12),
              underline: Container(height: 1, color: AppColors.border),
              items: items.map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(displayName(item)),
              )).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ],
    );
  }
}