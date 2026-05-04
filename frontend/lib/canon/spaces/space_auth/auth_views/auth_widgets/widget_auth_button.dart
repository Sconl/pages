// lib/spaces/space_auth/auth_views/auth_widgets/widget_auth_button.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Extracted from screens/auth_widgets.dart (QAuthButton).
//             Renamed to WidgetAuthButton per auth_widgets/ naming convention.
// ─────────────────────────────────────────────────────────────────────────────
//
// Atomic button primitive. No auth logic. No navigation. No state except hover.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kButtonHeight = 50.0;
const _kSpinnerSize  = 22.0;
const _kSpinnerWidth = 2.5;

// ─────────────────────────────────────────────────────────────────────────────
// WidgetAuthButton
// ─────────────────────────────────────────────────────────────────────────────

class WidgetAuthButton extends StatefulWidget {
  final String        label;
  final VoidCallback? onPressed;
  final bool          isLoading;
  final double        height;

  const WidgetAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height    = _kButtonHeight,
  });

  @override
  State<WidgetAuthButton> createState() => _WidgetAuthButtonState();
}

class _WidgetAuthButtonState extends State<WidgetAuthButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration:  AppDurations.fast,
          height:    widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient:     _hovered ? AppGradients.buttonHover : AppGradients.button,
            borderRadius: AppRadius.pillBR,
            boxShadow:    _hovered ? AppShadows.buttonGlowHover : AppShadows.buttonGlow,
          ),
          child: widget.isLoading
              ? SizedBox(
                  width:  _kSpinnerSize,
                  height: _kSpinnerSize,
                  child: CircularProgressIndicator(
                    color:       AppColors.onPrimary,
                    strokeWidth: _kSpinnerWidth,
                  ),
                )
              : Text(widget.label, style: AppTypography.button),
        ),
      ),
    );
  }
}