// frontend/lib/spaces/space_architect/architect_portals/preview_portal/preview_sections/section_preview_device_bar.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Horizontal scrollable device preset selector bar.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kBarHeight      = 44.0;
const double _kChipMinWidth   = 88.0;
const double _kChipHeight     = 32.0;
const double _kChipLabelSize  = 11.5;
const double _kChipDimsSize   = 9.0;
const double _kChipSpacing    = 6.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionPreviewDeviceBar extends StatelessWidget {
  final ArchitectDevice               current;
  final ValueChanged<ArchitectDevice> onSelected;

  const SectionPreviewDeviceBar({
    super.key,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kBarHeight,
      color:  AppColors.backgroundAlt,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.xs,
        ),
        child: Row(
          children: ArchitectDevice.values.map((d) => Padding(
            padding: EdgeInsets.only(right: _kChipSpacing),
            child: _DeviceChip(
              device:     d,
              isSelected: d == current,
              onTap:      () => onSelected(d),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeviceChip
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceChip extends StatelessWidget {
  final ArchitectDevice device;
  final bool            isSelected;
  final VoidCallback    onTap;

  const _DeviceChip({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        constraints: BoxConstraints(
          minWidth:  _kChipMinWidth,
          minHeight: _kChipHeight,
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient:     isSelected ? AppGradients.button : null,
          color:        isSelected ? null : AppColors.surface,
          borderRadius: AppRadius.pillBR,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                device.label,
                style: AppTypography.badge.copyWith(
                  fontSize:   _kChipLabelSize,
                  color:      isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              Text(
                '${device.width.toInt()}×${device.height.toInt()}',
                style: AppTypography.caption.copyWith(
                  fontSize: _kChipDimsSize,
                  color:    isSelected
                      ? AppColors.onPrimary.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}