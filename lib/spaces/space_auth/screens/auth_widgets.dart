// lib/experience/spaces/space_auth/screens/auth_widgets.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Shared auth-space UI components.
//             QAuthField, QAuthButton, QAuthDivider, QAuthErrorBanner.
//   v1.1.0 — Added QRoleToggle + _TogglePill.
//             Role toggle is a segmented pill selector that maps user-class
//             labels to QRole values for post-login routing and signup hints.
// ─────────────────────────────────────────────────────────────────────────────
//
// These widgets are internal to space_auth. When lib/interface/components/
// q_text_field.dart and q_button.dart are built (Cycle 1), migrate to those
// and delete the field/button widgets from this file. Keep QRoleToggle here.

import 'package:flutter/material.dart';

import '../../../core/style/app_style.dart';
import '../../../core/auth/auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const _kButtonHeight     = 50.0;
const _kIconSize         = 20.0;
const _kSpinnerSize      = 22.0;
const _kSpinnerWidth     = 2.5;
const _kDividerThick     = 1.0;
const _kBorderWidth      = 1.5;
const _kToggleInnerPad   = 3.0;   // padding inside the toggle container
const _kTogglePillVPad   = 11.0;  // vertical padding inside each pill
const _kToggleFontSize   = 13.0;

// ── Error banner ──
const _kErrorIconSize    = 16.0;

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

// ─────────────────────────────────────────────────────────────────────────────
// QRoleToggle
// ─────────────────────────────────────────────────────────────────────────────

// Segmented pill selector for choosing a user class at login/signup.
// Only rendered when QAuthConfig.isToggleVisible is true.
// The selected class id gets written to selectedUserClassProvider at submit time.
class QRoleToggle extends StatelessWidget {
  final List<AuthUserClass> userClasses;
  final AuthUserClass       selected;
  final ValueChanged<AuthUserClass> onSelected;

  const QRoleToggle({
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