// frontend/lib/spaces/space_architect/architect_portals/preview_portal/preview_sections/section_preview_canvas.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Preview canvas — auto-scale, device frame, live screen.
// ─────────────────────────────────────────────────────────────────────────────
//
// Receives the scaled device size and the current entry from the shell.
// Computes the effective scale that fits the device into the available canvas,
// then applies the architect's manual zoom factor on top.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';
import '../preview_widgets/widget_preview_device_frame.dart';
import '../preview_widgets/widget_preview_live_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kCanvasPad = 32.0;   // breathing room around the device frame
const double _kScaleMin  = 0.3;
const double _kScaleMax  = 1.0;
const Color  _kCanvasBg  = Color(0xFF0A0A14);  // near-black so the frame pops

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionPreviewCanvas extends StatelessWidget {
  final ArchitectScreenEntry entry;
  final ArchitectDevice      device;
  final bool                 isPortrait;
  final double               scaleFactor;

  const SectionPreviewCanvas({
    super.key,
    required this.entry,
    required this.device,
    required this.isPortrait,
    required this.scaleFactor,
  });

  Size get _rawSize => isPortrait
      ? device.size
      : Size(device.size.height, device.size.width);

  double _computeAutoScale(BoxConstraints constraints) {
    final availW = constraints.maxWidth  - _kCanvasPad * 2;
    final availH = constraints.maxHeight - _kCanvasPad * 2;
    final fitW   = availW / _rawSize.width;
    final fitH   = availH / _rawSize.height;
    return (fitW < fitH ? fitW : fitH).clamp(_kScaleMin, _kScaleMax);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kCanvasBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final auto          = _computeAutoScale(constraints);
          final effective     = (scaleFactor * auto).clamp(_kScaleMin, _kScaleMax);
          final scaledW       = _rawSize.width  * effective;
          final scaledH       = _rawSize.height * effective;

          return Center(
            child: WidgetPreviewDeviceFrame(
              width:  scaledW,
              height: scaledH,
              child: WidgetPreviewLiveScreen(
                entry:  entry,
                size:   _rawSize,
                device: device,
              ),
            ),
          );
        },
      ),
    );
  }
}