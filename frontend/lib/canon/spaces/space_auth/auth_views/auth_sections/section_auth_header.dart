// lib/spaces/space_auth/auth_views/auth_sections/section_auth_header.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Entry message block — logo, heading, subheading.
//             Copy driven by QAuthConfig so tenants never touch this file.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: the intro/header block — title, subtitle, logo.
// What does NOT live here: form fields, buttons, auth logic, layout choice.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../../../core/auth/auth_config.dart';
import '../layout_auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kHeadingSize    = 22.0;
const _kSubheadingSize = 13.5;

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthHeader
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthHeader extends StatelessWidget {
  final AuthMode    mode;
  final QAuthConfig config;

  const SectionAuthHeader({
    super.key,
    required this.mode,
    required this.config,
  });

  String get _heading {
    switch (mode) {
      case AuthMode.login:  return config.loginHeading;
      case AuthMode.signup: return config.signupHeading;
      case AuthMode.reset:  return 'Reset your password';
    }
  }

  String get _subheading {
    switch (mode) {
      case AuthMode.login:  return config.loginSubheading;
      case AuthMode.signup: return config.signupSubheading;
      case AuthMode.reset:  return "Enter your email and we'll send a reset link.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BrandLogoEngine.verticalColored(),
        SizedBox(height: AppSpacing.sm),
        Text(
          _heading,
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubheading.copyWith(
            fontSize:   _kHeadingSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          _subheading,
          textAlign: TextAlign.center,
          style: AppTypography.helper.copyWith(
            fontSize: _kSubheadingSize,
            color:    AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}