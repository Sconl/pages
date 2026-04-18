// lib/experience/spaces/space_auth/screens/screen_login.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Full login screen for QSpace Pages.
//             Navigation handled by GoRouter redirect — no context.go() here.
//             Two-column layout above breakpoint, single column on mobile.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/style/app_style.dart';
import '../state/auth_riverpod.dart';
import 'auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const _kBreakpoint     = 840.0;
const _kFlexForm       = 4;
const _kFlexImage      = 5;
const _kFormMaxWidth   = 420.0;
const _kFormPaddingH   = 36.0;
const _kFormPaddingV   = 48.0;
const _kImagePaddingH  = 48.0;

// ── Copy ──
const _kHeading        = 'Welcome back';
const _kLabelEmail     = 'Email';
const _kLabelPassword  = 'Password';
const _kLabelLogin     = 'Log In';
const _kLabelForgot    = 'Forgot password?';
const _kLabelNoAccount = "Don't have an account? ";
const _kLabelSignup    = 'Sign up';

// ── Typography ──
const _kSubtitleSize   = 14.0;
const _kLinkSize       = 13.0;

// ── Assets ──
const _kImagePath      = 'assets/gifs/login_screen.gif';

// ── Feature flags ──
// Flip to false before production — shows raw exceptions in the error banner.
const _kDevMode = true;

// ─────────────────────────────────────────────────────────────────────────────
// ScreenLogin
// ─────────────────────────────────────────────────────────────────────────────

class ScreenLogin extends ConsumerStatefulWidget {
  const ScreenLogin({super.key});

  @override
  ConsumerState<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends ConsumerState<ScreenLogin> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus    = FocusNode();

  bool    _isLoading    = false;
  bool    _resetSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ref.read(authAdapterProvider).signIn(
        email:    _emailCtrl.text.trim(),
        password: _pwCtrl.text,
      );
      // No explicit navigation — GoRouter redirect fires on session emit.
    } catch (e, stack) {
      debugPrint('[ScreenLogin] signIn error: $e\n$stack');
      setState(() => _errorMessage = _mapError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage =
          'Enter your email above, then tap Forgot password.');
      return;
    }

    setState(() { _resetSending = true; _errorMessage = null; });
    try {
      await ref.read(authAdapterProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reset email sent to $email',
              style: AppTypography.helper),
        ));
      }
    } catch (e) {
      setState(() => _errorMessage = _mapError(e));
    } finally {
      if (mounted) setState(() => _resetSending = false);
    }
  }

  // Error mapping is centralized here — Dio errors, Firebase errors,
  // and the dev-mode raw exception all get handled in one place.
  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('invalid-credential') || msg.contains('user-not-found')) {
      return 'No account found with these credentials.';
    }
    if (msg.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Wait a few minutes.';
    if (msg.contains('network')) return 'Connection error. Check your internet.';
    if (msg.contains('401') || msg.contains('403')) {
      return 'Login failed. Check your credentials.';
    }
    if (_kDevMode) return 'DEBUG: $msg';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isTwoCol = MediaQuery.of(context).size.width >= _kBreakpoint;

    return Scaffold(
      body: AppCanvas(
        type:          BackgroundType.meshParticle,
        particleStyle: ParticleStyle.drift,
        gradientStyle: GradientStyle.pulse,
        child: SafeArea(
          child: isTwoCol
              ? _TwoCol(form: _buildForm(), image: _buildImage())
              : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: _kFormPaddingH,
            vertical:   _kFormPaddingV,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BrandLogoEngine.verticalColored(),
                SizedBox(height: AppSpacing.xs + 2),
                Text(
                  _kHeading,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.authSubheading.copyWith(
                    fontSize:   _kSubtitleSize,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl - AppSpacing.md),
                QAuthField(
                  controller:       _emailCtrl,
                  label:            _kLabelEmail,
                  focusNode:        _emailFocus,
                  keyboardType:     TextInputType.emailAddress,
                  textInputAction:  TextInputAction.next,
                  autofocus:        true,
                  onEditingComplete: () => _pwFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.textMuted, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                QAuthField(
                  controller:       _pwCtrl,
                  label:            _kLabelPassword,
                  obscureText:      true,
                  focusNode:        _pwFocus,
                  textInputAction:  TextInputAction.done,
                  onEditingComplete: _submit,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textMuted, size: 20),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetSending ? null : _forgotPassword,
                    style: TextButton.styleFrom(
                      padding:         const EdgeInsets.only(top: 4),
                      tapTargetSize:   MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.primary,
                    ),
                    child: _resetSending
                        ? SizedBox(
                            width:  14, height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: AppColors.primary),
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
                SizedBox(height: AppSpacing.sm),
                if (_errorMessage != null) ...[
                  QAuthErrorBanner(message: _errorMessage!),
                  SizedBox(height: AppSpacing.sm + 4),
                ],
                QAuthButton(
                  label:     _kLabelLogin,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submit,
                ),
                SizedBox(height: AppSpacing.md + AppSpacing.xs),
                const QAuthDivider(),
                SizedBox(height: AppSpacing.md + AppSpacing.xs),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/signup'),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text:  _kLabelNoAccount,
                          style: AppTextStyles.authSubheading
                              .copyWith(fontSize: _kLinkSize),
                        ),
                        TextSpan(
                          text: _kLabelSignup,
                          style: AppTextStyles.authSubheading.copyWith(
                            fontSize:   _kLinkSize,
                            color:      AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kImagePaddingH),
          child: ClipRRect(
            borderRadius: AppRadius.cardBR,
            child: Image.asset(
              _kImagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textMuted, size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout helpers (private to this screen)
// ─────────────────────────────────────────────────────────────────────────────

class _TwoCol extends StatelessWidget {
  final Widget form;
  final Widget image;
  const _TwoCol({required this.form, required this.image});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(flex: _kFlexForm,  child: form),
    Expanded(flex: _kFlexImage, child: image),
  ]);
}