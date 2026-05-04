// lib/spaces/space_auth/auth_views/auth_widgets/widget_auth_toggle.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Extracted from screens/auth_widgets.dart (QRoleToggle +
//             QAuthErrorBanner). Renamed per auth_widgets/ naming convention.
//             WidgetAuthToggle — segmented role/class selector pill.
//             WidgetAuthErrorBanner — inline error feedback display.
// ─────────────────────────────────────────────────────────────────────────────
//
// Small interactive control primitives. No auth logic. No backend. No routing.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../../../core/auth/auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kToggleInnerPad   = 3.0;
const _kTogglePillVPad   = 11.0;
const _kToggleFontSize   = 13.0;
const _kErrorIconSize    = 16.0;

// ─────────────────────────────────────────────────────────────────────────────
// WidgetAuthToggle — segmented pill selector for user class / role selection
// ─────────────────────────────────────────────────────────────────────────────

class WidgetAuthToggle extends StatelessWidget {
  final List<AuthUserClass>         userClasses;
  final AuthUserClass               selected;
  final ValueChanged<AuthUserClass> onSelected;

  const WidgetAuthToggle({
    super.key,
    required this.userClasses,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kToggleInnerPad),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadius.pillBR,
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        children: userClasses.map((uc) => Expanded(
          child: _TogglePill(
            userClass:  uc,
            isSelected: uc.id == selected.id,
            onTap:      () => onSelected(uc),
          ),
        )).toList(),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final AuthUserClass userClass;
  final bool          isSelected;
  final VoidCallback  onTap;

  const _TogglePill({
    required this.userClass,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:  AppDurations.fast,
        padding:   const EdgeInsets.symmetric(vertical: _kTogglePillVPad),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient:     isSelected ? AppGradients.button : null,
          borderRadius: AppRadius.pillBR,
          boxShadow:    isSelected ? AppShadows.buttonGlow : null,
        ),
        child: Text(
          userClass.label,
          style: AppTypography.helper.copyWith(
            fontSize:   _kToggleFontSize,
            fontWeight: FontWeight.w600,
            color:      isSelected ? AppColors.onPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WidgetAuthErrorBanner — inline error feedback
// ─────────────────────────────────────────────────────────────────────────────

class WidgetAuthErrorBanner extends StatelessWidget {
  final String message;
  const WidgetAuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 6,
        vertical:   AppSpacing.sm + 2,
      ),
      decoration: AppDecorations.errorBanner,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline,
              color: AppColors.error,
              size:  _kErrorIconSize,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.helper.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}