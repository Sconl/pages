// lib/spaces/space_auth/auth_views/auth_sections/section_auth_actions.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Submit button with mode-appropriate label.
//   v2.0.0 — Added optional biometric button below the main CTA.
//             Biometric button is subtle: small icon + text link, not a full button.
//             Only rendered when showBiometric = true (passed from ShellAuthRoot).
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: submit button + optional biometric shortcut.
// What does NOT live here: navigation links, field inputs, auth backend logic.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../layout_auth_config.dart';
import '../auth_widgets/widget_auth_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kLabelLogin    = 'Log In';
const _kLabelSignup   = 'Create Account';
const _kLabelReset    = 'Send Reset Link';
const _kBiometricIcon = 20.0;
const _kBiometricSpinner = 14.0;

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthActions
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthActions extends StatelessWidget {
  final AuthMode     mode;
  final bool         isLoading;
  final VoidCallback onSubmit;

  // Biometric — only relevant on AuthMode.login, ignored otherwise.
  final bool         showBiometric;
  final String       biometricLabel;
  final VoidCallback? onBiometricTap;

  const SectionAuthActions({
    super.key,
    required this.mode,
    required this.isLoading,
    required this.onSubmit,
    this.showBiometric   = false,
    this.biometricLabel  = 'Use biometrics',
    this.onBiometricTap,
  });

  String get _label {
    switch (mode) {
      case AuthMode.login:  return _kLabelLogin;
      case AuthMode.signup: return _kLabelSignup;
      case AuthMode.reset:  return _kLabelReset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WidgetAuthButton(
          label:     _label,
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
        // Biometric: subtle text+icon link below the primary CTA.
        // Shown only on login, only when device is ready and config is on.
        if (showBiometric && mode == AuthMode.login) ...[
          SizedBox(height: AppSpacing.md),
          _BiometricLink(
            label:     biometricLabel,
            isLoading: isLoading,
            onTap:     onBiometricTap,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BiometricLink — subtle fingerprint shortcut
// ─────────────────────────────────────────────────────────────────────────────

class _BiometricLink extends StatelessWidget {
  final String       label;
  final bool         isLoading;
  final VoidCallback? onTap;

  const _BiometricLink({
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: isLoading ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical:   AppSpacing.xs,
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width:  _kBiometricSpinner,
                height: _kBiometricSpinner,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color:       AppColors.textSecondary,
                ),
              )
            : Icon(
                Icons.fingerprint,
                size:  _kBiometricIcon,
                color: AppColors.textSecondary,
              ),
        label: Text(
          label,
          style: AppTypography.helper.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}