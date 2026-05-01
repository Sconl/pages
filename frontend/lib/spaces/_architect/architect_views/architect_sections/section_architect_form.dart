// frontend/lib/spaces/space_architect/architect_views/architect_sections/section_architect_form.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Username + password credential fields.
// ─────────────────────────────────────────────────────────────────────────────
//
// Stateless — controllers and focus nodes owned by the shell.
// Reuses WidgetAuthField so this matches the production auth flow visually.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../../../space_auth/auth_views/auth_widgets/widget_auth_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const String _kLabelUsername = 'Username';
const String _kLabelPassword = 'Password';
const double _kIconSize      = 20.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionArchitectForm extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode             usernameFocus;
  final FocusNode             passwordFocus;
  final VoidCallback          onSubmit;

  const SectionArchitectForm({
    super.key,
    required this.formKey,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.usernameFocus,
    required this.passwordFocus,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WidgetAuthField(
            controller:        usernameCtrl,
            label:             _kLabelUsername,
            focusNode:         usernameFocus,
            autofocus:         true,
            textInputAction:   TextInputAction.next,
            onEditingComplete: () => passwordFocus.requestFocus(),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: AppColors.textMuted,
              size:  _kIconSize,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Username is required';
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          WidgetAuthField(
            controller:        passwordCtrl,
            label:             _kLabelPassword,
            focusNode:         passwordFocus,
            obscureText:       true,
            textInputAction:   TextInputAction.done,
            onEditingComplete: onSubmit,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textMuted,
              size:  _kIconSize,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              return null;
            },
          ),
        ],
      ),
    );
  }
}