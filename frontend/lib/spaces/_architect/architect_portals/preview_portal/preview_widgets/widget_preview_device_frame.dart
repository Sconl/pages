// frontend/lib/spaces/space_architect/architect_portals/preview_portal/preview_widgets/widget_preview_device_frame.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Rounded bezel around the live preview screen.
// ─────────────────────────────────────────────────────────────────────────────
//
// Pure layout widget — no state, no logic. Wraps its child in a rounded
// container that simulates a physical device bezel with a shadow.

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kBorderWidth  = 1.5;
const double _kRadius       = 12.0;
const double _kShadowBlur   = 40.0;
const Color  _kFrameColor   = Color(0xFF2A2A3A);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class WidgetPreviewDeviceFrame extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const WidgetPreviewDeviceFrame({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width  + _kBorderWidth * 2,
      height: height + _kBorderWidth * 2,
      decoration: BoxDecoration(
        color:        _kFrameColor,
        borderRadius: BorderRadius.circular(_kRadius),
        border:       Border.all(color: AppColors.border, width: _kBorderWidth),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.55),
            blurRadius: _kShadowBlur,
            offset:     const Offset(0, 16),
          ),
          BoxShadow(
            color:        AppColors.primary.withValues(alpha: 0.08),
            blurRadius:   _kShadowBlur * 1.5,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kRadius - _kBorderWidth),
        child: SizedBox(width: width, height: height, child: child),
      ),
    );
  }
}