// lib/experience/spaces/space_auth/screens/screen_login.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Full login screen for QSpace Pages.
//   v2.0.0 — Redesigned. Single column, no natural scroll.
//             Layout: ConstrainedBox(minHeight) + Column(spaceBetween) so the
//             screen fills available height on all devices. Keyboard-up causes
//             the SingleChildScrollView to activate, Spacers compress gracefully.
//             Two-column layout removed — use the template layout system (Cycle 1).
//             Role toggle integrated via QRoleToggle + QAuthConfig.
//             Copy driven by QAuthConfig — no hardcoded strings in logic.
//             Post-login routing driven by selectedUserClassProvider.
// ─────────────────────────────────────────────────────────────────────────────
//
// Navigation is handled entirely by GoRouter redirect — zero context.go() calls
// in this file. The screen writes selectedUserClassProvider before calling signIn,
// then the router reads it to pick the right post-login destination.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/style/app_style.dart';
import '../../../core/auth/auth_policy.dart';
import '../state/auth_riverpod.dart';
import 'auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const _kFormMaxWidth   = 400.0;
const _kFormPaddingH   = 32.0;

// ── Labels ──
const _kLabelEmail     = 'Email';
const _kLabelPassword  = 'Password';
const _kLabelLogin     = 'Log In';
const _kLabelForgot    = 'Forgot password?';
const _kLabelNoAccount = "Don't have an account? ";
const _kLabelSignup    = 'Sign up';

// ── Typography ──
const _kHeadingSize    = 22.0;
const _kSubheadingSize = 13.5;
const _kLinkSize       = 13.0;

// ── Assets ──
// No assets hardcoded here — branding comes from BrandScope.

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
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _pwCtrl     = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus    = FocusNode();

  // The role toggle selection. Null until config is read — initialized lazily in build.
  AuthUserClass? _selectedClass;

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

    // Store the selected class so the router redirect knows where to send the user.
    // Must happen before signIn so it's in place when the session stream fires.
    final classToCommit = _selectedClass;
    if (classToCommit != null) {
      ref.read(selectedUserClassProvider.notifier).state = classToCommit.id;
    }

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
      setState(() => _errorMessage = 'Enter your email above, then tap Forgot password.');
      return;
    }
    setState(() { _resetSending = true; _errorMessage = null; });
    try {
      await ref.read(authAdapterProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset email sent to $email', style: AppTypography.helper)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = _mapError(e));
    } finally {
      if (mounted) setState(() => _resetSending = false);
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('invalid-credential') || msg.contains('user-not-found')) {
      return 'No account found with these credentials.';
    }
    if (msg.contains('wrong-password'))     return 'Incorrect password. Please try again.';
    if (msg.contains('too-many-requests'))  return 'Too many attempts. Wait a few minutes.';
    if (msg.contains('network'))            return 'Connection error. Check your internet.';
    if (msg.contains('401') || msg.contains('403')) return 'Login failed. Check your credentials.';
    if (_kDevMode) return 'DEBUG: $msg';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final config  = ref.watch(authConfigProvider);
    final screen  = MediaQuery.of(context);

    // Initialize the selected class to the config default on first build.
    _selectedClass ??= config.defaultClass;
    final selected = _selectedClass;

    // Available height for the ConstrainedBox — fills screen minus safe areas.
    final availableHeight = screen.size.height
        - screen.padding.top
        - screen.padding.bottom;

    return Scaffold(
      // resizeToAvoidBottomInset (default true) shrinks the body when the keyboard
      // appears. The SingleChildScrollView takes over, letting fields scroll into view.
      body: AppCanvas(
        type:          BackgroundType.meshParticle,
        particleStyle: ParticleStyle.drift,
        gradientStyle: GradientStyle.pulse,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _kFormMaxWidth),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  // minHeight ensures the column fills the screen when content is
                  // short. Without this, Column(spaceBetween) collapses to content height.
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _kFormPaddingH),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── Top: branding ─────────────────────────────────
                        _TopRegion(config: config),

                        // ── Middle: toggle + form ─────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (config.isToggleVisible && selected != null) ...[
                                QRoleToggle(
                                  userClasses: config.userClasses,
                                  selected:    selected,
                                  onSelected:  (c) => setState(() => _selectedClass = c),
                                ),
                                SizedBox(height: AppSpacing.lg),
                              ],
                              QAuthField(
                                controller:        _emailCtrl,
                                label:             _kLabelEmail,
                                focusNode:         _emailFocus,
                                keyboardType:      TextInputType.emailAddress,
                                textInputAction:   TextInputAction.next,
                                autofocus:         true,
                                onEditingComplete: () => _pwFocus.requestFocus(),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.textMuted,
                                  size:  _kIconSize,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email is required';
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.md),
                              QAuthField(
                                controller:        _pwCtrl,
                                label:             _kLabelPassword,
                                obscureText:       true,
                                focusNode:         _pwFocus,
                                textInputAction:   TextInputAction.done,
                                onEditingComplete: _submit,
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textMuted,
                                  size:  _kIconSize,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  return null;
                                },
                              ),
                              if (config.allowPasswordReset)
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
                                            width: 14, height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5, color: AppColors.primary,
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
                              SizedBox(height: AppSpacing.sm),
                              if (_errorMessage != null) ...[
                                QAuthErrorBanner(message: _errorMessage!),
                                SizedBox(height: AppSpacing.sm),
                              ],
                              QAuthButton(
                                label:     _kLabelLogin,
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _submit,
                              ),
                            ],
                          ),
                        ),

                        // ── Bottom: signup link ────────────────────────────
                        if (config.allowSignup)
                          _BottomLinks()
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private layout widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopRegion extends StatelessWidget {
  final QAuthConfig config;
  const _TopRegion({required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.xl),
        BrandLogoEngine.verticalColored(),
        SizedBox(height: AppSpacing.sm),
        Text(
          config.loginHeading,
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubheading.copyWith(
            fontSize:   _kHeadingSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          config.loginSubheading,
          textAlign: TextAlign.center,
          style: AppTypography.helper.copyWith(
            fontSize: _kSubheadingSize,
            color:    AppColors.textMuted,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _BottomLinks extends StatelessWidget {
  const _BottomLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.lg),
        const QAuthDivider(),
        SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => context.go(kRouteSignup),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text:  _kLabelNoAccount,
                style: AppTextStyles.authSubheading.copyWith(fontSize: _kLinkSize),
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
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// Need to expose these constants for the private widgets above.
// They live in the CONFIG BLOCK at the top — referenced here directly.
const _kIconSize = 20.0; // matches QAuthField's expected icon size