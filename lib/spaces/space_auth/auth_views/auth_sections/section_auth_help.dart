// lib/spaces/space_auth/auth_views/auth_sections/section_auth_help.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Support layer — reduces friction. Forgot password link
//             and inline error message. No form controls. No auth backend.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: guidance, help text, error feedback, forgot password link.
// What does NOT live here: form fields, submit logic, template arrangement.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../auth_widgets/widget_auth_toggle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kLabelForgot = 'Forgot password?';

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthHelp
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthHelp extends StatelessWidget {
  final String?      errorMessage;
  final bool         allowPasswordReset;
  final bool         isResetting;
  final VoidCallback onForgotPassword;

  const SectionAuthHelp({
    super.key,
    this.errorMessage,
    required this.allowPasswordReset,
    required this.isResetting,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (allowPasswordReset)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isResetting ? null : onForgotPassword,
              style: TextButton.styleFrom(
                padding:         const EdgeInsets.only(top: 4),
                tapTargetSize:   MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: isResetting
                  ? SizedBox(
                      width:  14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color:       AppColors.primary,
                      ),
                    )
                  : Text(
                      _kLabelForgot,
                      style: AppTypography.helper.copyWith(
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),
        if (errorMessage != null) ...[
          SizedBox(height: AppSpacing.sm),
          WidgetAuthErrorBanner(message: errorMessage!),
        ],
      ],
    );
  }
}