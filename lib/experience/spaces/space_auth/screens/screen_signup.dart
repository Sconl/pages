// lib/experience/spaces/space_auth/screens/screen_signup.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Full signup screen.
//             tenantId pulled from client config — multitenant aware.
//             GoRouter redirect handles post-signup navigation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/style/app_style.dart';
import '../../../../client/qspace/client_config.dart';
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
const _kFormPaddingV   = 40.0;
const _kImagePaddingH  = 48.0;

// ── Copy ──
const _kHeading        = 'Create your account';
const _kLabelName      = 'Display Name';
const _kLabelEmail     = 'Email';
const _kLabelPassword  = 'Password';
const _kLabelConfirm   = 'Confirm Password';
const _kLabelCreate    = 'Create Account';
const _kLabelHasAccount = 'Already have an account? ';
const _kLabelLogin     = 'Log in';

// ── Typography ──
const _kSubtitleSize   = 14.0;
const _kLinkSize       = 13.0;

// ── Assets ──
const _kImagePath      = 'assets/gifs/signup_screen.gif';

// ── Feature flags ──
const _kDevMode = true; // flip false before production

// ─────────────────────────────────────────────────────────────────────────────
// ScreenSignup
// ─────────────────────────────────────────────────────────────────────────────

class ScreenSignup extends ConsumerStatefulWidget {
  const ScreenSignup({super.key});

  @override
  ConsumerState<ScreenSignup> createState() => _ScreenSignupState();
}

class _ScreenSignupState extends ConsumerState<ScreenSignup> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _pwCtrl     = TextEditingController();
  final _cpwCtrl    = TextEditingController();
  final _nameFocus  = FocusNode();
  final _emailFocus = FocusNode();
  final _pwFocus    = FocusNode();
  final _cpwFocus   = FocusNode();

  bool    _isLoading    = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _pwCtrl.dispose();   _cpwCtrl.dispose();
    _nameFocus.dispose(); _emailFocus.dispose();
    _pwFocus.dispose();   _cpwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ref.read(authAdapterProvider).signUp(
        email:       _emailCtrl.text.trim(),
        password:    _pwCtrl.text,
        displayName: _nameCtrl.text.trim(),
        tenantId:    kDefaultTenantId, // from client_config.dart
      );
      // GoRouter redirect fires automatically on session emit.
    } catch (e, stack) {
      debugPrint('[ScreenSignup] signUp error: $e\n$stack');
      setState(() => _errorMessage = _mapError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use') || msg.contains('409')) {
      return 'An account with this email already exists. Try logging in.';
    }
    if (msg.contains('weak-password')) return 'Password must be at least 8 characters.';
    if (msg.contains('invalid-email')) return 'Please enter a valid email address.';
    if (msg.contains('network')) return 'Connection error. Check your internet.';
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
                SizedBox(height: AppSpacing.xl),
                QAuthField(
                  controller:       _nameCtrl,
                  label:            _kLabelName,
                  focusNode:        _nameFocus,
                  autofocus:        true,
                  textInputAction:  TextInputAction.next,
                  onEditingComplete: () => _emailFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.textMuted, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (v.trim().length > 50) return 'Name must be under 50 characters';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                QAuthField(
                  controller:       _emailCtrl,
                  label:            _kLabelEmail,
                  focusNode:        _emailFocus,
                  keyboardType:     TextInputType.emailAddress,
                  textInputAction:  TextInputAction.next,
                  onEditingComplete: () => _pwFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.textMuted, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                QAuthField(
                  controller:       _pwCtrl,
                  label:            _kLabelPassword,
                  obscureText:      true,
                  focusNode:        _pwFocus,
                  textInputAction:  TextInputAction.next,
                  onEditingComplete: () => _cpwFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textMuted, size: 20),
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                QAuthField(
                  controller:       _cpwCtrl,
                  label:            _kLabelConfirm,
                  obscureText:      true,
                  focusNode:        _cpwFocus,
                  textInputAction:  TextInputAction.done,
                  onEditingComplete: _submit,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textMuted, size: 20),
                  validator: (v) {
                    if (v != _pwCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md + AppSpacing.xs),
                if (_errorMessage != null) ...[
                  QAuthErrorBanner(message: _errorMessage!),
                  SizedBox(height: AppSpacing.sm + 4),
                ],
                QAuthButton(
                  label:     _kLabelCreate,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submit,
                ),
                SizedBox(height: AppSpacing.md + AppSpacing.xs),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text:  _kLabelHasAccount,
                          style: AppTextStyles.authSubheading
                              .copyWith(fontSize: _kLinkSize),
                        ),
                        TextSpan(
                          text: _kLabelLogin,
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
// Layout helpers
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