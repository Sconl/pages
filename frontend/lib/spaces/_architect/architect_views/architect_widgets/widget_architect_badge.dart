// frontend/lib/spaces/space_architect/architect_views/architect_widgets/widget_architect_badge.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Gradient pill badge that marks the architect space.
// ─────────────────────────────────────────────────────────────────────────────
//
// Positioned above the logo in SectionArchitectHeader. It is the first thing
// the architect sees, which establishes context before anything else renders.

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const String _kBadgeText     = 'ARCHITECT';
const double _kFontSize      = 10.0;
const double _kLetterSpacing = 3.0;
const double _kPaddingH      = 12.0;
const double _kPaddingV      = 4.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class WidgetArchitectBadge extends StatelessWidget {
  const WidgetArchitectBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _kPaddingH,
        vertical:   _kPaddingV,
      ),
      decoration: BoxDecoration(
        gradient:     AppGradients.button,
        borderRadius: AppRadius.pillBR,
      ),
      child: Text(
        _kBadgeText,
        style: AppTypography.badge.copyWith(
          fontSize:      _kFontSize,
          color:         AppColors.onPrimary,
          letterSpacing: _kLetterSpacing,
        ),
      ),
    );
  }
}