// frontend/lib/spaces/_architect/architect_portals/preview_portal/preview_sections/section_preview_info_strip.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Info strip between device bar and preview canvas.
//                  Shows: exact resolution, closest device name, orientation,
//                  responsive breakpoint label, scale percentage.
// ─────────────────────────────────────────────────────────────────────────────
//
// Sits between the device chip bar and the dark preview canvas.
// Updates in real time as the user drags the width handle.
// All data comes from the shell — this section is fully stateless.

import 'package:flutter/material.dart';

import '../../../../../../core/style/app_style.dart';
import '../../../../../../core/style/app_theme.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kStripHeight   = 28.0;
const double _kFontSize      = 10.5;
const double _kIconSize      = 11.0;
const double _kDividerHeight = 10.0;
const double _kDividerWidth  = 1.0;
const double _kPillPadH      = 6.0;
const double _kPillPadV      = 2.0;
const double _kPillRadius    = 4.0;
const double _kItemSpacing   = 16.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// Converts a pixel width to the Flutter / Bootstrap-style breakpoint label.
// Matches AppBreakpoints thresholds from app_theme.dart.
String _breakpointLabel(double width) {
  if (width >= AppBreakpoints.xxl) return 'xxl ≥1536';
  if (width >= AppBreakpoints.xl)  return 'xl ≥1280';
  if (width >= AppBreakpoints.lg)  return 'lg ≥1024';
  if (width >= AppBreakpoints.md)  return 'md ≥768';
  if (width >= AppBreakpoints.sm)  return 'sm ≥480';
  return 'xs <480';
}

Color _breakpointColor(double width) {
  if (width >= AppBreakpoints.xl)  return AppColors.success;
  if (width >= AppBreakpoints.lg)  return AppColors.info;
  if (width >= AppBreakpoints.md)  return AppColors.warning;
  return AppColors.tertiary;
}

class SectionPreviewInfoStrip extends StatelessWidget {
  final double          displayWidth;   // actual pixel width being rendered
  final double          displayHeight;
  final ArchitectDevice closestDevice;
  final bool            isPortrait;
  final double          scaleFactor;    // 0.0–1.0, multiply by 100 for %

  const SectionPreviewInfoStrip({
    super.key,
    required this.displayWidth,
    required this.displayHeight,
    required this.closestDevice,
    required this.isPortrait,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final bpLabel = _breakpointLabel(displayWidth);
    final bpColor = _breakpointColor(displayWidth);
    final scalePercent = (scaleFactor * 100).round();

    return Container(
      height:  _kStripHeight,
      color:   AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Resolution — exact px dimensions
          _StripItem(
            icon:  Icons.aspect_ratio_rounded,
            label: '${displayWidth.round()} × ${displayHeight.round()} px',
          ),

          _StripDivider(),

          // Closest device
          _StripItem(
            icon:  closestDevice.icon,
            label: closestDevice.label,
          ),

          _StripDivider(),

          // Orientation
          _StripItem(
            icon:  isPortrait
                ? Icons.stay_current_portrait_rounded
                : Icons.stay_current_landscape_rounded,
            label: isPortrait ? 'Portrait' : 'Landscape',
          ),

          _StripDivider(),

          // Responsive breakpoint pill
          _BreakpointPill(label: bpLabel, color: bpColor),

          const Spacer(),

          // Scale percentage — right-aligned
          _StripItem(
            icon:  Icons.zoom_in_rounded,
            label: '$scalePercent%',
            muted: scalePercent >= 100,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal primitives
// ─────────────────────────────────────────────────────────────────────────────

class _StripItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     muted;

  const _StripItem({
    required this.icon,
    required this.label,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.textMuted : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _kIconSize, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: _kFontSize,
            color:    color,
          ),
        ),
        SizedBox(width: _kItemSpacing),
      ],
    );
  }
}

class _StripDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:  _kDividerWidth,
      height: _kDividerHeight,
      color:  AppColors.border,
      margin: EdgeInsets.only(right: _kItemSpacing),
    );
  }
}

class _BreakpointPill extends StatelessWidget {
  final String label;
  final Color  color;

  const _BreakpointPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _kPillPadH,
        vertical:   _kPillPadV,
      ),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_kPillRadius),
        border:       Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: _kFontSize,
          color:    color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}