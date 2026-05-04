// frontend/lib/spaces/space_architect/architect_views/architect_sections/section_architect_actions.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Submit button + inline error banner.
// ─────────────────────────────────────────────────────────────────────────────
//
// No state here — receives isLoading, errorMessage, and onSubmit from shell.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../space_auth/auth_views/auth_widgets/widget_auth_button.dart';
import '../../../space_auth/auth_views/auth_widgets/widget_auth_toggle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const String _kSubmitLabel = 'Enter Architect Space';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionArchitectActions extends StatelessWidget {
  final bool         isLoading;
  final String?      errorMessage;
  final VoidCallback onSubmit;

  const SectionArchitectActions({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null) ...[
          WidgetAuthErrorBanner(message: errorMessage!),
          SizedBox(height: AppSpacing.sm),
        ],
        WidgetAuthButton(
          label:     _kSubmitLabel,
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
      ],
    );
  }
}