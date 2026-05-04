// lib/spaces/space_admin/admin_portals/brand_portal/brand_widgets/widget_color_token_card.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Large swatch card with hex copy, role badge, guidance
//             copy, and a Pick Color button. Used by section_brand_colors.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────
const double _kSwatchSize = 88.0;
const double _kCardR      = 12.0;
// ─────────────────────────────────────────────────────────────────────────────

class WidgetColorTokenCard extends StatelessWidget {
  final String label;
  final String role;       // e.g. '60% Dominant'
  final Color  color;
  final String guidance;
  final VoidCallback onEdit;

  const WidgetColorTokenCard({
    super.key,
    required this.label,
    required this.role,
    required this.color,
    required this.guidance,
    required this.onEdit,
  });

  String get _hexString {
    final argb = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${argb.substring(2)}';
  }

  void _copyHex(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _hexString));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$_hexString copied',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.surfaceLit,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kCardR),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large swatch — tap to edit
          GestureDetector(
            onTap: onEdit,
            child: Tooltip(
              message: 'Click to edit color',
              child: Container(
                width: _kSwatchSize, height: _kSwatchSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                  boxShadow: [BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12, offset: const Offset(0, 4),
                  )],
                ),
                child: const Center(child: Icon(Icons.edit_outlined, size: 20, color: Colors.white70)),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label + role badge
                Row(
                  children: [
                    Text(label, style: AppTypography.h5.copyWith(fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                      ),
                      child: Text(role, style: AppTypography.caption.copyWith(
                        color: color, fontSize: 9, fontWeight: FontWeight.w700,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Hex + copy
                Row(
                  children: [
                    Text(_hexString, style: AppTypography.caption.copyWith(
                      color: color, fontWeight: FontWeight.w700,
                      fontFamily: BrandCopy.fontAccent, fontSize: 13,
                    )),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _copyHex(context),
                      child: Tooltip(
                        message: 'Copy hex',
                        child: Icon(Icons.copy_outlined, size: 13, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Guidance
                Text(guidance, style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary, height: 1.5, fontSize: 11,
                )),
                const SizedBox(height: 12),

                // Pick color button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.colorize_outlined, size: 13, color: color),
                        const SizedBox(width: 6),
                        Text('Pick Color', style: AppTypography.caption.copyWith(
                          color: color, fontWeight: FontWeight.w600, fontSize: 11,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}