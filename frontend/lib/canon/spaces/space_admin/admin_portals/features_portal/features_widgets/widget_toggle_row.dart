// lib/spaces/space_admin/admin_portals/features_portal/features_widgets/widget_toggle_row.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Reusable admin toggle row with label, description, dimming,
//             and Switch. Extracted from screen_admin_features into a shared widget.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../../core/style/app_style.dart';

class WidgetToggleRow extends StatelessWidget {
  final String  label;
  final String? description;
  final bool    value;
  final ValueChanged<bool> onChanged;
  final bool    dimmed;   // parent section is hidden — still toggleable, visually muted

  const WidgetToggleRow({
    super.key,
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.body.copyWith(
                  fontSize: 13,
                  color: dimmed ? AppColors.textMuted : AppColors.textPrimary,
                )),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(description!, style: AppTypography.caption.copyWith(
                    color: dimmed ? AppColors.textMuted : AppColors.textSecondary,
                  )),
                ],
              ],
            ),
          ),
          Switch(
            value:            value,
            onChanged:        onChanged,
            activeColor:      AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            inactiveThumbColor: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}