// frontend/lib/spaces/_architect/architect_views/architect_widgets/widget_architect_badge.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Restyled to match section_core_hero.dart reference exactly:
//                  tint10 fill, tint20 border, primary dot, primary text.
//                  No glow, no gradient border, no shadow. Clean pill.
//   • 2026-04-27 — Glowing pill with gradient border (reverted this session).
//   • 2026-04-26 — Initial solid gradient pill.
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual anatomy — identical to the badge pill in SectionCoreHero:
//   Container(color: tint10, border: tint20, borderRadius: pill)
//     → Row: primary circle dot  •  "ARCHITECT" in primary colour
//
// No glow. No gradient border. No shadows. Just the clean pill from the canon.

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Copy ───────────────────────────────────────────────────────────────────────
const String _kBadgeText = 'ARCHITECT';

// ── Typography — matches caption.copyWith used in SectionCoreHero badge ───────
const double _kFontSize      = 12.0;
const double _kLetterSpacing = 0.0;   // caption default — no extra spacing needed

// ── Pill sizing ────────────────────────────────────────────────────────────────
// Mirrors AppSpacing.md / AppSpacing.xs from the hero section
const double _kPaddingH = 16.0;   // AppSpacing.md
const double _kPaddingV = 4.0;    // AppSpacing.xs

// ── Dot ────────────────────────────────────────────────────────────────────────
const double _kDotSize    = 6.0;
const double _kDotSpacing = 6.0;   // AppSpacing.xs

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class WidgetArchitectBadge extends StatelessWidget {
  const WidgetArchitectBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _kPaddingH,
        vertical:   _kPaddingV,
      ),
      decoration: BoxDecoration(
        // Exact pattern from SectionCoreHero badge pill
        color:        AppColors.tint10(AppColors.primary),
        borderRadius: AppRadius.pillBR,
        border:       Border.all(color: AppColors.tint20(AppColors.primary)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary circle dot — identical to the hero badge dot
          Container(
            width:  _kDotSize,
            height: _kDotSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: _kDotSpacing),
          Text(
            _kBadgeText,
            style: AppTypography.caption.copyWith(
              color:       AppColors.primary,
              fontWeight:  FontWeight.w600,
              fontSize:    _kFontSize,
              letterSpacing: _kLetterSpacing,
            ),
          ),
        ],
      ),
    );
  }
}