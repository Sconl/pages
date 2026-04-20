// lib/spaces/space_admin/admin_portals/brand_portal/brand_widgets/widget_sixty_thirty_ten.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Proportional 60-30-10 color bar visualization.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────
const double _kBarH = 64.0;
const double _kBarR = 10.0;
// ─────────────────────────────────────────────────────────────────────────────

class WidgetSixtyThirtyTen extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const WidgetSixtyThirtyTen({
    super.key,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kBarH,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kBarR),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Flexible(flex: 6, child: _Segment(color: primary,   label: '60%\nPrimary')),
          Flexible(flex: 3, child: _Segment(color: secondary, label: '30%\nSecondary')),
          Flexible(flex: 1, child: _Segment(color: tertiary,  label: '10%')),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final Color color;
  final String label;
  const _Segment({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
      ),
    );
  }
}