// frontend/lib/spaces/space_discovery/discovery_views/discovery_widgets/widget_discovery_qr_overlay.dart

import 'package:flutter/material.dart';
// import 'package:qspace_pages/core/style/app_style.dart';

/// QR scan viewfinder overlay — the visual guide drawn on top of the camera.
/// A translucent border with a transparent centred square.
/// Pure visual — no logic.
class WidgetDiscoveryQrOverlay extends StatelessWidget {
  const WidgetDiscoveryQrOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _QrOverlayPainter());
  }
}

class _QrOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 250.0;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width:  cutoutSize,
      height: cutoutSize,
    );

    // Dark overlay outside the cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0xAA000000),
    );

    // Corner brackets in brand primary colour
    final bracketPaint = Paint()
      ..color       = const Color(0xFF9933FF) // AppColors.primary — const safe here
      ..strokeWidth = 3
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    const bracketLen = 24.0;
    final r = cutoutRect;

    // Top-left
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(bracketLen, 0), bracketPaint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, bracketLen), bracketPaint);
    // Top-right
    canvas.drawLine(r.topRight, r.topRight + const Offset(-bracketLen, 0), bracketPaint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, bracketLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(bracketLen, 0), bracketPaint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -bracketLen), bracketPaint);
    // Bottom-right
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-bracketLen, 0), bracketPaint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -bracketLen), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}