// frontend/lib/canon/spaces/_architect/architect_views/architect_sections/section_architect_header.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-05-04 — Logo width set to fill the form container. The login form
//                  sits in a 400px max-width column with 32px horizontal
//                  padding on each side, giving 336px of usable width.
//                  BrandLogo now stretches to that full width so it aligns
//                  flush with the input fields below it.
//                  Switched from verticalColored to horizontalColored so the
//                  wordmark uses the available width rather than stacking.
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Login header. Badge above logo per design.
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual order: badge → logo → heading → subheading.
// The logo is constrained to match the form width so the header feels
// anchored to the form below rather than floating as a smaller independent unit.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../architect_widgets/widget_architect_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Copy ───────────────────────────────────────────────────────────────────────
const String _kHeading       = 'Architect Access';
const String _kSubheading    = 'QSpace internal development system';

// ── Typography ─────────────────────────────────────────────────────────────────
const double _kHeadingSize    = 22.0;
const double _kSubheadingSize = 13.5;

// ── Logo ────────────────────────────────────────────────────────────────────────
// The login form column is 400px max-width with 32px horizontal padding on
// each side → 400 - 64 = 336px usable. We use double.infinity so the logo
// fills whatever the parent provides (always ≤ 336px inside the form column).
// Height is left null so the SVG scales proportionally.
const double? _kLogoWidth  = double.infinity;  // fills the form container width
const double? _kLogoHeight = null;             // proportional — no fixed height

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionArchitectHeader extends StatelessWidget {
  const SectionArchitectHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Badge — centred, sits above the logo
        const Center(child: WidgetArchitectBadge()),

        SizedBox(height: AppSpacing.md),

        // Logo — stretched to the full form width so it aligns with inputs
        // below. BrandLogo reads the asset path from BrandScope and falls
        // back to the typographic wordmark if the asset isn't available.
        BrandLogo(
          shape:        LogoShape.horizontal,
          variant:      LogoVariant.colored,
          width:        _kLogoWidth,
          height:       _kLogoHeight,
          fallbackSize: LogoSize.lg,
        ),

        SizedBox(height: AppSpacing.sm),

        // Heading
        Text(
          _kHeading,
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(
            fontSize:   _kHeadingSize,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: AppSpacing.xs),

        // Subheading
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