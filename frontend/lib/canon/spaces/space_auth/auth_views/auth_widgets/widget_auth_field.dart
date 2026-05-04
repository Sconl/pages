// lib/spaces/space_auth/auth_views/auth_widgets/widget_auth_field.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Extracted from screens/auth_widgets.dart (QAuthField).
//             Renamed to WidgetAuthField per auth_widgets/ naming convention.
// ─────────────────────────────────────────────────────────────────────────────
//
// Atomic input primitive. No auth logic. No layout decisions. No state except
// the internal _obscured toggle for password fields.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kIconSize       = 20.0;
const _kBorderWidth    = 1.5;

// ─────────────────────────────────────────────────────────────────────────────
// WidgetAuthField
// ─────────────────────────────────────────────────────────────────────────────

class WidgetAuthField extends StatefulWidget {
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

  const WidgetAuthField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText       = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
    this.prefixIcon,
    this.autofocus         = false,
    this.focusNode,
  });

  @override
  State<WidgetAuthField> createState() => _WidgetAuthFieldState();
}

class _WidgetAuthFieldState extends State<WidgetAuthField> {
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