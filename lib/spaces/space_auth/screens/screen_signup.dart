// lib/spaces/space_auth/screens/screen_signup.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v2.0.0 — Single column, role toggle, roleHint forwarded to signUp().
//   v2.0.1 — Fixed: AppSpacing.xxs doesn't exist — replaced with AppSpacing.xs.
//             Fixed: import paths updated (experience/spaces → spaces).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/style/app_style.dart';
import '../../../core/auth/auth_policy.dart';
import '../../../client/qspace/client_config.dart';
import '../state/auth_riverpod.dart';
import 'auth_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kFormMaxWidth  = 400.0;
const _kFormPaddingH  = 32.0;
const _kIconSize      = 20.0;
const _kHeadingSize   = 22.0;
const _kSubheadingSize = 13.5;
const _kLinkSize      = 13.0;

const _kLabelName    = 'Display Name';
const _kLabelEmail   = 'Email';
const _kLabelPassword = 'Password';
const _kLabelConfirm = 'Confirm Password';
const _kLabelCreate  = 'Create Account';
const _kLabelHasAcct = 'Already have an account? ';
const _kLabelLogin   = 'Log in';

const _kDevMode = true;

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

  AuthUserClass? _selectedClass;
  bool    _isLoading    = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();  _emailCtrl.dispose();
    _pwCtrl.dispose();    _cpwCtrl.dispose();
    _nameFocus.dispose(); _emailFocus.dispose();
    _pwFocus.dispose();   _cpwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final classToCommit = _selectedClass;
    if (classToCommit != null) {
      ref.read(selectedUserClassProvider.notifier).state = classToCommit.id;
    }

    try {
      await ref.read(authAdapterProvider).signUp(
        email:       _emailCtrl.text.trim(),
        password:    _pwCtrl.text,
        displayName: _nameCtrl.text.trim(),
        tenantId:    kDefaultTenantId,
        roleHint:    classToCommit?.id,
      );
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
    if (msg.contains('network'))       return 'Connection error. Check your internet.';
    if (_kDevMode) return 'DEBUG: $msg';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(authConfigProvider);
    final screen = MediaQuery.of(context);

    _selectedClass ??= config.defaultClass;
    final selected = _selectedClass;

    final availableHeight = screen.size.height - screen.padding.top - screen.padding.bottom;

    return Scaffold(
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
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _kFormPaddingH),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TopRegion(config: config),
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
                                controller:        _nameCtrl,
                                label:             _kLabelName,
                                focusNode:         _nameFocus,
                                autofocus:         true,
                                textInputAction:   TextInputAction.next,
                                onEditingComplete: () => _emailFocus.requestFocus(),
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted, size: _kIconSize),
                                validator: (v) {
                                  if (v == null || v.trim().length < 2) return 'Name must be at least 2 characters';
                                  if (v.trim().length > 50)             return 'Name must be under 50 characters';
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.sm),
                              QAuthField(
                                controller:        _emailCtrl,
                                label:             _kLabelEmail,
                                focusNode:         _emailFocus,
                                keyboardType:      TextInputType.emailAddress,
                                textInputAction:   TextInputAction.next,
                                onEditingComplete: () => _pwFocus.requestFocus(),
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: _kIconSize),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email is required';
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.sm),
                              QAuthField(
                                controller:        _pwCtrl,
                                label:             _kLabelPassword,
                                obscureText:       true,
                                focusNode:         _pwFocus,
                                textInputAction:   TextInputAction.next,
                                onEditingComplete: () => _cpwFocus.requestFocus(),
                                prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: _kIconSize),
                                validator: (v) {
                                  if (v == null || v.length < 8) return 'Password must be at least 8 characters';
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.sm),
                              QAuthField(
                                controller:        _cpwCtrl,
                                label:             _kLabelConfirm,
                                obscureText:       true,
                                focusNode:         _cpwFocus,
                                textInputAction:   TextInputAction.done,
                                onEditingComplete: _submit,
                                prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: _kIconSize),
                                validator: (v) {
                                  if (v != _pwCtrl.text) return 'Passwords do not match';
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.sm),
                              if (_errorMessage != null) ...[
                                QAuthErrorBanner(message: _errorMessage!),
                                SizedBox(height: AppSpacing.sm),
                              ],
                              QAuthButton(
                                label:     _kLabelCreate,
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _submit,
                              ),
                            ],
                          ),
                        ),
                        _BottomLinks(),
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
        SizedBox(height: AppSpacing.lg),
        BrandLogoEngine.verticalColored(),
        SizedBox(height: AppSpacing.sm),
        Text(
          config.signupHeading,
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubheading.copyWith(fontSize: _kHeadingSize, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.xs),   // was xxs — minimum token is xs (4px)
        Text(
          config.signupSubheading,
          textAlign: TextAlign.center,
          style: AppTypography.helper.copyWith(fontSize: _kSubheadingSize, color: AppColors.textMuted),
        ),
        SizedBox(height: AppSpacing.lg),
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
          onPressed: () => context.go(kRouteLogin),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(text: _kLabelHasAcct, style: AppTextStyles.authSubheading.copyWith(fontSize: _kLinkSize)),
              TextSpan(
                text: _kLabelLogin,
                style: AppTextStyles.authSubheading.copyWith(fontSize: _kLinkSize, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}