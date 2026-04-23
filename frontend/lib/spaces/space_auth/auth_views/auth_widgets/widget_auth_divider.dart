// lib/spaces/space_auth/auth_views/auth_widgets/widget_auth_divider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Extracted from screens/auth_widgets.dart (QAuthDivider).
//             Renamed to WidgetAuthDivider per auth_widgets/ naming convention.
// ─────────────────────────────────────────────────────────────────────────────
//
// Visual separator primitive. No behavior. No state.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kDividerThick = 1.0;

// ─────────────────────────────────────────────────────────────────────────────
// WidgetAuthDivider
// ─────────────────────────────────────────────────────────────────────────────

class WidgetAuthDivider extends StatelessWidget {
  final String label;
  const WidgetAuthDivider({super.key, this.label = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.border, thickness: _kDividerThick),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child:   Text(label, style: AppTypography.helper),
        ),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: _kDividerThick),
        ),
      ],
    );
  }
}