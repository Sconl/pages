// frontend/lib/spaces/_architect/architect_views/architect_widgets/widget_architect_badge.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Restyled: glowing pill badge. Dark semi-transparent fill,
//                  gradient border via gradient Container + inner Container,
//                  gradient dot bullet on the left, glow box-shadow. Matches
//                  the reference image visual language with brand colours.
//   • 2026-04-26 — Initial: solid gradient pill.
// ─────────────────────────────────────────────────────────────────────────────
//
// The badge sits above the logo in the architect login header — first thing
// rendered, establishes "you are in the architect space" before anything else.
//
// Visual anatomy:
//   [gradient border container]
//     → [dark fill inner container with glow shadows]
//         → [Row: gradient dot • "ARCHITECT" text]

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Copy ───────────────────────────────────────────────────────────────────────
const String _kBadgeText     = 'ARCHITECT';

// ── Typography ─────────────────────────────────────────────────────────────────
const double _kFontSize      = 10.0;
const double _kLetterSpacing = 2.5;

// ── Pill sizing ────────────────────────────────────────────────────────────────
const double _kPaddingH      = 14.0;
const double _kPaddingV      = 6.0;
const double _kBorderRadius  = 50.0;   // fully pill-shaped
const double _kBorderWidth   = 1.0;    // gradient border thickness

// ── Dot bullet ─────────────────────────────────────────────────────────────────
const double _kDotSize       = 7.0;
const double _kDotSpacing    = 7.0;

// ── Glow ───────────────────────────────────────────────────────────────────────
// Three layered shadows give the "neon glow" effect from the reference image.
// Outer glow is wide and soft; inner is tight and bright.
const double _kGlowBlurOuter  = 18.0;
const double _kGlowBlurMid    = 8.0;
const double _kGlowBlurInner  = 3.0;
const double _kGlowAlphaOuter = 0.30;
const double _kGlowAlphaMid   = 0.45;
const double _kGlowAlphaInner = 0.55;

// ── Fill ───────────────────────────────────────────────────────────────────────
// Near-black with a very subtle primary tint — matches dark pill in image
const double _kFillAlpha = 0.10;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class WidgetArchitectBadge extends StatelessWidget {
  const WidgetArchitectBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    // Outer container: gradient border + glow shadows
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kBorderRadius),
        gradient:     AppGradients.button,   // gradient border
        boxShadow: [
          // Wide outer glow
          BoxShadow(
            color:      primary.withValues(alpha: _kGlowAlphaOuter),
            blurRadius: _kGlowBlurOuter,
            spreadRadius: 1,
          ),
          // Mid glow
          BoxShadow(
            color:      primary.withValues(alpha: _kGlowAlphaMid),
            blurRadius: _kGlowBlurMid,
          ),
          // Tight inner glow — makes the border appear to emit light
          BoxShadow(
            color:      primary.withValues(alpha: _kGlowAlphaInner),
            blurRadius: _kGlowBlurInner,
          ),
        ],
      ),
      // Inner container: the dark pill fill, inset by border width
      child: Container(
        margin: EdgeInsets.all(_kBorderWidth),
        padding: const EdgeInsets.symmetric(
          horizontal: _kPaddingH,
          vertical:   _kPaddingV,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kBorderRadius - _kBorderWidth),
          // Very dark fill with just a hint of the brand colour
          color: AppColors.background.withValues(alpha: 0.92),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient bullet dot — matches the circular indicator in the image
            Container(
              width:  _kDotSize,
              height: _kDotSize,
              decoration: BoxDecoration(
                shape:    BoxShape.circle,
                gradient: AppGradients.button,
                boxShadow: [
                  BoxShadow(
                    color:      primary.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            SizedBox(width: _kDotSpacing),
            Text(
              _kBadgeText,
              style: AppTypography.badge.copyWith(
                fontSize:      _kFontSize,
                color:         primary,
                letterSpacing: _kLetterSpacing,
                fontWeight:    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}