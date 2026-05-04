// frontend/lib/spaces/space_architect/architect_portals/preview_portal/preview_sections/section_preview_toolbar.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Preview toolbar — back, screen label, zoom, rotate.
// ─────────────────────────────────────────────────────────────────────────────
//
// Stateless — receives all values and callbacks from the shell.
// No business logic lives here.

import 'package:flutter/material.dart';

import '../../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kToolbarHeight = 52.0;
const double _kSliderWidth   = 110.0;
const double _kSliderMin     = 0.3;
const double _kSliderMax     = 1.0;
const int    _kSliderDivisions = 14;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionPreviewToolbar extends StatelessWidget {
  final ArchitectScreenEntry entry;
  final bool                 isPortrait;
  final double               scaleFactor;
  final VoidCallback         onOrientationToggle;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback         onClose;

  const SectionPreviewToolbar({
    super.key,
    required this.entry,
    required this.isPortrait,
    required this.scaleFactor,
    required this.onOrientationToggle,
    required this.onScaleChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  _kToolbarHeight,
      color:   AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Back to dashboard
          Tooltip(
            message: 'Close Preview',
            child: IconButton(
              icon:      const Icon(Icons.arrow_back_ios_rounded, size: 16),
              color:     AppColors.textSecondary,
              onPressed: onClose,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Screen label + ID
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: AppTypography.h5.copyWith(fontSize: 13),
                ),
                Text(
                  entry.id,
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          // Zoom control
          Icon(Icons.zoom_out_rounded, size: 14, color: AppColors.textMuted),
          SizedBox(
            width: _kSliderWidth,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value:         scaleFactor.clamp(_kSliderMin, _kSliderMax),
                min:           _kSliderMin,
                max:           _kSliderMax,
                divisions:     _kSliderDivisions,
                activeColor:   AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged:     onScaleChanged,
              ),
            ),
          ),
          Icon(Icons.zoom_in_rounded, size: 14, color: AppColors.textMuted),
          SizedBox(width: AppSpacing.xs),

          // Orientation toggle
          Tooltip(
            message: 'Rotate device',
            child: IconButton(
              icon: AnimatedRotation(
                turns:    isPortrait ? 0 : 0.25,
                duration: AppDurations.fast,
                child: const Icon(Icons.screen_rotation_rounded, size: 18),
              ),
              color:     AppColors.textSecondary,
              onPressed: onOrientationToggle,
            ),
          ),
        ],
      ),
    );
  }
}