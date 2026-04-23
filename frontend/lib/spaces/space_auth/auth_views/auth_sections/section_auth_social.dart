// lib/spaces/space_auth/auth_views/auth_sections/section_auth_social.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Social login section. Row of circular provider buttons
//             with a divider above. Config-driven — shows only enabled providers.
//             ShellAuthRoot passes config and handles the tap callbacks.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: the social button row arrangement + divider.
// What does NOT live here: OAuth flow, session creation, tap routing.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../../../../core/auth/auth_config.dart';
import '../../../../core/auth/social_auth_port.dart';
import '../auth_widgets/widget_auth_social_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kButtonSpacing   = 16.0;
const _kDividerFontSize = 11.5;

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthSocial
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthSocial extends StatelessWidget {
  final QSocialAuthConfig               config;
  final void Function(SocialAuthProvider) onProviderTap;
  final bool                            isLoading;

  const SectionAuthSocial({
    super.key,
    required this.config,
    required this.onProviderTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.isVisible) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.lg),
        _SocialDivider(label: config.dividerLabel),
        SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: config.providers.map((p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kButtonSpacing / 2),
            child: WidgetAuthSocialButton(
              provider:  p,
              isLoading: isLoading,
              onTap:     () => onProviderTap(p),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SocialDivider — "Or continue with" label between horizontal lines
// ─────────────────────────────────────────────────────────────────────────────

class _SocialDivider extends StatelessWidget {
  final String label;
  const _SocialDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1.0)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label,
            style: AppTypography.helper.copyWith(
              fontSize: _kDividerFontSize,
              color:    AppColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1.0)),
      ],
    );
  }
}