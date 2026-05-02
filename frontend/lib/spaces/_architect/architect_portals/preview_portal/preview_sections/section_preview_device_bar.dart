// frontend/lib/spaces/_architect/architect_portals/preview_portal/preview_sections/section_preview_device_bar.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Chips now show device icon + label only (no resolution text
//                  inside the chip). Resolution moved to the info strip below.
//                  closestDevice param added — chip matching the current custom
//                  width is highlighted in the active style even if not selected
//                  via tap, giving real-time feedback while dragging.
//   • 2026-04-26 — Initial.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kBarHeight     = 44.0;
const double _kChipMinWidth  = 76.0;
const double _kChipHeight    = 32.0;
const double _kChipLabelSize = 11.5;
const double _kChipIconSize  = 13.0;
const double _kChipSpacing   = 6.0;
const double _kIconLabelGap  = 5.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionPreviewDeviceBar extends StatelessWidget {
  final ArchitectDevice  current;
  // closestDevice can differ from current when the user is drag-resizing —
  // the closest chip gets a highlighted (but not full active) treatment
  final ArchitectDevice? closestDevice;
  final ValueChanged<ArchitectDevice> onSelected;

  const SectionPreviewDeviceBar({
    super.key,
    required this.current,
    required this.onSelected,
    this.closestDevice,
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
              device:    d,
              isActive:  d == current,
              isClosest: closestDevice != null &&
                         d == closestDevice &&
                         d != current,
              onTap:     () => onSelected(d),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final ArchitectDevice device;
  final bool            isActive;
  // isClosest = matches the drag-resize width but wasn't tapped — show a
  // subtle highlight so the architect knows what breakpoint they're near
  final bool            isClosest;
  final VoidCallback    onTap;

  const _DeviceChip({
    required this.device,
    required this.isActive,
    required this.isClosest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${device.width.toInt()}×${device.height.toInt()}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          constraints: BoxConstraints(
            minWidth:  _kChipMinWidth,
            minHeight: _kChipHeight,
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            gradient:     isActive ? AppGradients.button : null,
            color:        isActive
                ? null
                : isClosest
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
            borderRadius: AppRadius.pillBR,
            border:       Border.all(
              color: isActive
                  ? Colors.transparent
                  : isClosest
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.border,
              width: isClosest ? 1.2 : 1.0,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  device.icon,
                  size:  _kChipIconSize,
                  color: isActive
                      ? AppColors.onPrimary
                      : isClosest
                          ? AppColors.primary
                          : AppColors.textMuted,
                ),
                SizedBox(width: _kIconLabelGap),
                Text(
                  device.label,
                  style: AppTypography.badge.copyWith(
                    fontSize:   _kChipLabelSize,
                    color:      isActive
                        ? AppColors.onPrimary
                        : isClosest
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    fontWeight: (isActive || isClosest)
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}