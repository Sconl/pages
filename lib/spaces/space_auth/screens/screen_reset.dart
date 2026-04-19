// lib/experience/spaces/space_auth/screens/screen_reset.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Password reset screen.
//   v1.0.1 — Fixed: removed const from Icon(color: AppColors.primary) in
//             _buildSuccess() — AppColors.primary is not a compile-time const.
//             Removed unused _kDevMode constant.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/style/app_style.dart';
import '../state/auth_riverpod.dart';
import 'auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const _kFormMaxWidth  = 400.0;
const _kFormPaddingH  = 36.0;
const _kFormPaddingV  = 64.0;

// ── Copy ──
const _kHeading       = 'Reset your password';
const _kSubheading    = "Enter your email and we'll send you a reset link.";
const _kLabelEmail    = 'Email';
const _kLabelSubmit   = 'Send Reset Link';
const _kLabelBack     = '← Back to login';
const _kSuccessTitle  = 'Email sent!';
const _kSuccessBody   = "Check your inbox. If the account exists, you'll receive a reset link shortly.";

// ── Typography ──
const _kSubtitleSize     = 14.0;
const _kSuccessTitleSize = 20.0;

// ─────────────────────────────────────────────────────────────────────────────
// ScreenReset
// ─────────────────────────────────────────────────────────────────────────────

class ScreenReset extends ConsumerStatefulWidget {
  const ScreenReset({super.key});

  @override
  ConsumerState<ScreenReset> createState() => _ScreenResetState();
}

class _ScreenResetState extends ConsumerState<ScreenReset> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool    _isLoading = false;
  bool    _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ref.read(authAdapterProvider).sendPasswordReset(
        _emailCtrl.text.trim(),
      );
      if (mounted) setState(() => _emailSent = true);
    } catch (e) {
      // Don't reveal whether the email exists — security best practice.
      // Show success state regardless; log real error for diagnostics.
      debugPrint('[ScreenReset] sendPasswordReset error: $e');
      if (mounted) setState(() => _emailSent = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppCanvas(
        type:          BackgroundType.meshParticle,
        particleStyle: ParticleStyle.drift,
        gradientStyle: GradientStyle.pulse,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kFormPaddingH,
                  vertical:   _kFormPaddingV,
                ),
                child: _emailSent ? _buildSuccess() : _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandLogoEngine.verticalColored(),
          SizedBox(height: AppSpacing.xl),
          Text(
            _kHeading,
            textAlign: TextAlign.center,
            style: AppTextStyles.authSubheading.copyWith(
              fontSize:   _kSubtitleSize + 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            _kSubheading,
            textAlign: TextAlign.center,
            style: AppTypography.helper.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: AppSpacing.xl),
          QAuthField(
            controller:      _emailCtrl,
            label:           _kLabelEmail,
            keyboardType:    TextInputType.emailAddress,
            autofocus:       true,
            textInputAction: TextInputAction.done,
            onEditingComplete: _submit,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          if (_errorMessage != null) ...[
            QAuthErrorBanner(message: _errorMessage!),
            SizedBox(height: AppSpacing.sm + 4),
          ],
          QAuthButton(
            label:     _kLabelSubmit,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
          SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                _kLabelBack,
                style: AppTypography.helper.copyWith(
                  color:      AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BrandLogoEngine.verticalColored(),
        SizedBox(height: AppSpacing.xxl),
        // NOT const — AppColors.primary is not a compile-time constant
        Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 56),
        SizedBox(height: AppSpacing.lg),
        Text(
          _kSuccessTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubheading.copyWith(
            fontSize:   _kSuccessTitleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          _kSuccessBody,
          textAlign: TextAlign.center,
          style: AppTypography.helper.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: AppSpacing.xl),
        QAuthButton(
          label:     'Back to Login',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}