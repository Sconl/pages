// lib/spaces/space_auth/auth_views/auth_widgets/widget_auth_social_button.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Circular social login button. 52×52px. Brand color
//             background. Asset image with graceful fallback to initials.
//             Hover + loading states. Tooltip for accessibility.
// ─────────────────────────────────────────────────────────────────────────────
//
// ASSET SETUP:
//   Place provider logos at assets/logos/social/{provider}.png (24×24, transparent bg).
//   The button gracefully falls back to styled initials if assets are missing.
//   Register paths in pubspec.yaml: assets/logos/social/

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../../../core/auth/social_auth_port.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kButtonSize   = 52.0;
const _kIconSize     = 22.0;
const _kSpinnerSize  = 20.0;
const _kSpinnerWidth = 1.8;
const _kBorderWidth  = 1.0;
const _kInitialSize  = 15.0;

// Provider brand colors — backgrounds
const _kBgColors = {
  SocialAuthProvider.google: Color(0xFFFFFFFF),
  SocialAuthProvider.apple:  Color(0xFF000000),
  SocialAuthProvider.github: Color(0xFF24292F),
};

// Provider foreground colors — initials + spinner
const _kFgColors = {
  SocialAuthProvider.google: Color(0xFF4285F4),
  SocialAuthProvider.apple:  Color(0xFFFFFFFF),
  SocialAuthProvider.github: Color(0xFFFFFFFF),
};

// Fallback initials — used when logo asset is missing
const _kInitials = {
  SocialAuthProvider.google: 'G',
  SocialAuthProvider.apple:  'A',
  SocialAuthProvider.github: 'GH',
};

// ─────────────────────────────────────────────────────────────────────────────
// WidgetAuthSocialButton
// ─────────────────────────────────────────────────────────────────────────────

class WidgetAuthSocialButton extends StatefulWidget {
  final SocialAuthProvider provider;
  final VoidCallback?      onTap;
  final bool               isLoading;

  const WidgetAuthSocialButton({
    super.key,
    required this.provider,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<WidgetAuthSocialButton> createState() => _WidgetAuthSocialButtonState();
}

class _WidgetAuthSocialButtonState extends State<WidgetAuthSocialButton> {
  bool _hovered = false;

  Color get _bg => _kBgColors[widget.provider] ?? AppColors.surface;
  Color get _fg => _kFgColors[widget.provider] ?? AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Continue with ${widget.provider.displayName}',
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.isLoading ? null : widget.onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            width:     _kButtonSize,
            height:    _kButtonSize,
            decoration: BoxDecoration(
              color:  _bg,
              shape:  BoxShape.circle,
              border: Border.all(
                color: _hovered
                    ? AppColors.borderStrong
                    : AppColors.border,
                width: _kBorderWidth,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.20),
                        blurRadius: 8,
                        offset:     const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Center(child: _buildIcon()),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.isLoading) {
      return SizedBox(
        width:  _kSpinnerSize,
        height: _kSpinnerSize,
        child: CircularProgressIndicator(
          color:       _fg,
          strokeWidth: _kSpinnerWidth,
        ),
      );
    }

    // Try asset first — fall back to styled initials.
    return Image.asset(
      widget.provider.assetPath,
      width:  _kIconSize,
      height: _kIconSize,
      color:  widget.provider == SocialAuthProvider.google ? null : _fg,
      errorBuilder: (_, __, ___) => Text(
        _kInitials[widget.provider] ?? '?',
        style: TextStyle(
          color:      _fg,
          fontSize:   _kInitialSize,
          fontWeight: FontWeight.w700,
          height:     1.0,
        ),
      ),
    );
  }
}