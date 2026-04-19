// lib/spaces/space_auth/auth_views/auth_sections/section_auth_actions.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Decision/action block — submit button. Label is driven
//             by AuthMode. No routing. No backend calls.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: submit button, mode-appropriate label.
// What does NOT live here: navigation links, input fields, auth backend logic.

import 'package:flutter/material.dart';

import '../layout_auth_config.dart';
import '../auth_widgets/widget_auth_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kLabelLogin  = 'Log In';
const _kLabelSignup = 'Create Account';
const _kLabelReset  = 'Send Reset Link';

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthActions
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthActions extends StatelessWidget {
  final AuthMode     mode;
  final bool         isLoading;
  final VoidCallback onSubmit;

  const SectionAuthActions({
    super.key,
    required this.mode,
    required this.isLoading,
    required this.onSubmit,
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
    return WidgetAuthButton(
      label:     _label,
      isLoading: isLoading,
      onPressed: isLoading ? null : onSubmit,
    );
  }
}