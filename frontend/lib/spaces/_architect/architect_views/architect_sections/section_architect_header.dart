// frontend/lib/spaces/space_architect/architect_views/architect_sections/section_architect_header.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Login header. Badge above the logo per design.
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual order: badge → logo → heading → subheading.
// Badge is first — it establishes "you are in the architect space" before
// anything else renders. This is intentional, not cosmetic.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../architect_widgets/widget_architect_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const String _kHeading       = 'Architect Access';
const String _kSubheading    = 'QSpace internal development system';
const double _kHeadingSize   = 22.0;
const double _kSubheadingSize = 13.5;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionArchitectHeader extends StatelessWidget {
  const SectionArchitectHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Badge first — context before identity
        const WidgetArchitectBadge(),
        SizedBox(height: AppSpacing.md),
        BrandLogoEngine.verticalColored(),
        SizedBox(height: AppSpacing.sm),
        Text(
          _kHeading,
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(
            fontSize:   _kHeadingSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          _kSubheading,
          textAlign: TextAlign.center,
          style: AppTypography.helper.copyWith(
            fontSize: _kSubheadingSize,
            color:    AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}