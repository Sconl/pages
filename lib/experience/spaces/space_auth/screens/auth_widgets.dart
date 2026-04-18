// lib/experience/spaces/space_auth/screens/auth_widgets.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Shared auth-space UI components.
//             QAuthField, QAuthButton, QAuthDivider.
//             Uses lib/core/style/ tokens exclusively — no hardcoded values.
//             Adapted from WellPath auth_widgets.dart v1.1.0.
//             Renamed to Q-prefix per QSpace component convention.
// ─────────────────────────────────────────────────────────────────────────────
//
// These widgets are internal to space_auth. When lib/interface/components/
// q_text_field.dart and q_button.dart are built (Cycle 1), migrate to those
// and delete this file. For now, auth needs to work without waiting on
// the full component library.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const _kButtonHeight   = 50.0;
const _kIconSize       = 20.0;
const _kSpinnerSize    = 22.0;
const _kSpinnerWidth   = 2.5;
const _kDividerThick   = 1.0;
const _kBorderWidth    = 1.5; // focused border width

// ── Error banner ──
const _kErrorIconSize  = 16.0;

// ─────────────────────────────────────────────────────────────────────────────
// QAuthField
// ─────────────────────────────────────────────────────────────────────────────

class QAuthField extends StatefulWidget {
  final TextEditingController controller;
  final String                label;
  final bool                  obscureText;
  final TextInputType?        keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction?      textInputAction;
  final VoidCallback?         onEditingComplete;
  final Widget?               prefixIcon;
  final bool                  autofocus;
  final FocusNode?            focusNode;

  const QAuthField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText       = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
    this.prefixIcon,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<QAuthField> createState() => _QAuthFieldState();
}

class _QAuthFieldState extends State<QAuthField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:        widget.controller,
      focusNode:         widget.focusNode,
      obscureText:       _obscured,
      keyboardType:      widget.keyboardType,
      validator:         widget.validator,
      textInputAction:   widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      autofocus:         widget.autofocus,
      style:             AppTypography.input,
      decoration: InputDecoration(
        labelText:   widget.label,
        labelStyle:  AppTypography.inputLabel,
        filled:      true,
        fillColor:   AppColors.surface,
        prefixIcon:  widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size:  _kIconSize,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: AppColors.borderFocused, width: _kBorderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: AppColors.error, width: _kBorderWidth),
        ),
        errorStyle:     AppTypography.helper.copyWith(color: AppColors.error),
        contentPadding: AppSpacing.inputPadding,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QAuthButton
// ─────────────────────────────────────────────────────────────────────────────

class QAuthButton extends StatefulWidget {
  final String       label;
  final VoidCallback? onPressed;
  final bool         isLoading;
  final double       height;

  const QAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height    = _kButtonHeight,
  });

  @override
  State<QAuthButton> createState() => _QAuthButtonState();
}

class _QAuthButtonState extends State<QAuthButton> {
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

// ─────────────────────────────────────────────────────────────────────────────
// QAuthDivider
// ─────────────────────────────────────────────────────────────────────────────

class QAuthDivider extends StatelessWidget {
  final String label;
  const QAuthDivider({super.key, this.label = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: _kDividerThick)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child:   Text(label, style: AppTypography.helper),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: _kDividerThick)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QAuthErrorBanner
// ─────────────────────────────────────────────────────────────────────────────

// Pulled out of each screen to avoid duplicating the banner markup everywhere.
class QAuthErrorBanner extends StatelessWidget {
  final String message;
  const QAuthErrorBanner({super.key, required this.message});

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
            child: Icon(Icons.error_outline, color: AppColors.error, size: _kErrorIconSize),
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