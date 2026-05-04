// lib/spaces/space_auth/auth_views/auth_sections/section_auth_form.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Primary interaction block — credential input fields.
//             Reads AuthFormController (owned by ShellAuthRoot). Knows which
//             fields to render per AuthMode. Manages no controllers itself.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: field grouping, validation structure, focus chain.
// What does NOT live here: submit calls, backend logic, template arrangement.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../auth_model/auth_form_state.dart';
import '../layout_auth_config.dart';
import '../auth_widgets/widget_auth_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kIconSize      = 20.0;
const _kLabelName     = 'Display Name';
const _kLabelEmail    = 'Email';
const _kLabelPassword = 'Password';
const _kLabelConfirm  = 'Confirm Password';

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthForm
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthForm extends StatelessWidget {
  final AuthMode           mode;
  final AuthFormController formController;
  final VoidCallback       onSubmit;

  const SectionAuthForm({
    super.key,
    required this.mode,
    required this.formController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFields(),
      ),
    );
  }

  List<Widget> _buildFields() {
    switch (mode) {
      case AuthMode.login:
        return _loginFields();
      case AuthMode.signup:
        return _signupFields();
      case AuthMode.reset:
        return _resetFields();
    }
  }

  // ── Login: email → password → submit ────────────────────────────────────

  List<Widget> _loginFields() => [
    WidgetAuthField(
      controller:        formController.emailCtrl,
      label:             _kLabelEmail,
      focusNode:         formController.emailFocus,
      keyboardType:      TextInputType.emailAddress,
      textInputAction:   TextInputAction.next,
      autofocus:         true,
      onEditingComplete: () => formController.passwordFocus.requestFocus(),
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        return null;
      },
    ),
    SizedBox(height: AppSpacing.md),
    WidgetAuthField(
      controller:        formController.passwordCtrl,
      label:             _kLabelPassword,
      obscureText:       true,
      focusNode:         formController.passwordFocus,
      textInputAction:   TextInputAction.done,
      onEditingComplete: onSubmit,
      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        return null;
      },
    ),
  ];

  // ── Signup: displayName → email → password → confirmPassword → submit ───

  List<Widget> _signupFields() => [
    WidgetAuthField(
      controller:        formController.displayNameCtrl,
      label:             _kLabelName,
      focusNode:         formController.displayNameFocus,
      autofocus:         true,
      textInputAction:   TextInputAction.next,
      onEditingComplete: () => formController.emailFocus.requestFocus(),
      prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v == null || v.trim().length < kDisplayNameMinLength) {
          return 'Name must be at least $kDisplayNameMinLength characters';
        }
        if (v.trim().length > kDisplayNameMaxLength) {
          return 'Name must be under $kDisplayNameMaxLength characters';
        }
        return null;
      },
    ),
    SizedBox(height: AppSpacing.sm),
    WidgetAuthField(
      controller:        formController.emailCtrl,
      label:             _kLabelEmail,
      focusNode:         formController.emailFocus,
      keyboardType:      TextInputType.emailAddress,
      textInputAction:   TextInputAction.next,
      onEditingComplete: () => formController.passwordFocus.requestFocus(),
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
          return 'Enter a valid email address';
        }
        return null;
      },
    ),
    SizedBox(height: AppSpacing.sm),
    WidgetAuthField(
      controller:        formController.passwordCtrl,
      label:             _kLabelPassword,
      obscureText:       true,
      focusNode:         formController.passwordFocus,
      textInputAction:   TextInputAction.next,
      onEditingComplete: () => formController.confirmPasswordFocus.requestFocus(),
      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v == null || v.length < kPasswordMinLength) {
          return 'Password must be at least $kPasswordMinLength characters';
        }
        return null;
      },
    ),
    SizedBox(height: AppSpacing.sm),
    WidgetAuthField(
      controller:        formController.confirmPasswordCtrl,
      label:             _kLabelConfirm,
      obscureText:       true,
      focusNode:         formController.confirmPasswordFocus,
      textInputAction:   TextInputAction.done,
      onEditingComplete: onSubmit,
      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v != formController.passwordCtrl.text) return 'Passwords do not match';
        return null;
      },
    ),
  ];

  // ── Reset: email → submit ────────────────────────────────────────────────

  List<Widget> _resetFields() => [
    WidgetAuthField(
      controller:        formController.emailCtrl,
      label:             _kLabelEmail,
      focusNode:         formController.emailFocus,
      keyboardType:      TextInputType.emailAddress,
      textInputAction:   TextInputAction.done,
      autofocus:         true,
      onEditingComplete: onSubmit,
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: _kIconSize),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        return null;
      },
    ),
  ];
}