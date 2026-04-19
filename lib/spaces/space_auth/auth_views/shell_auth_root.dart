// lib/spaces/space_auth/auth_views/shell_auth_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Top-level auth orchestrator. Replaces screen_login.dart,
//             screen_signup.dart, and screen_reset.dart entirely.
//             Owns all auth state: form controllers, loading, errors, submit
//             logic, selected user class. Delegates composition to the
//             layout registry → template → sections pipeline.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: orchestration — choosing the layout, owning state, wiring
//                  sections, handling submit and navigation post-auth.
// What does NOT live here: section-specific UI, auth backend details, field
//                           validation rules, template arrangement logic.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/style/app_style.dart';
import '../../../core/auth/auth_policy.dart';
import '../../../client/qspace/client_config.dart';
import '../auth_model/auth_form_state.dart';
import '../auth_state/auth_riverpod.dart';
import 'layout_auth_config.dart';
import 'layout_auth_registry.dart';
import 'auth_sections/section_auth_header.dart';
import 'auth_sections/section_auth_form.dart';
import 'auth_sections/section_auth_actions.dart';
import 'auth_sections/section_auth_roles.dart';
import 'auth_sections/section_auth_help.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Links ──
const _kLinkSize       = 13.0;
const _kLabelNoAccount = "Don't have an account? ";
const _kLabelSignup    = 'Sign up';
const _kLabelHasAcct   = 'Already have an account? ';
const _kLabelLogin     = 'Log in';
const _kLabelBackLogin = '← Back to login';

// ── Reset success ──
const _kSuccessTitle    = 'Email sent!';
const _kSuccessBody     =
    "Check your inbox. If the account exists, you'll receive a reset link shortly.";
const _kSuccessIconSize = 56.0;

// ── Feature flags ──
// Flip to false before production — shows raw exception text in error banner.
const _kDevMode = true;

// ─────────────────────────────────────────────────────────────────────────────
// ShellAuthRoot
// ─────────────────────────────────────────────────────────────────────────────

class ShellAuthRoot extends ConsumerStatefulWidget {
  final AuthMode          mode;

  // layoutVariant: null → stack (default). Pass explicitly to override.
  // Future: read from QAuthConfig for tenant-specific default.
  final AuthLayoutVariant? layoutVariant;

  const ShellAuthRoot({
    super.key,
    required this.mode,
    this.layoutVariant,
  });

  @override
  ConsumerState<ShellAuthRoot> createState() => _ShellAuthRootState();
}

class _ShellAuthRootState extends ConsumerState<ShellAuthRoot> {
  late final AuthFormController _form;

  AuthUserClass? _selectedClass;
  bool           _isLoading      = false;
  bool           _resetSending   = false;
  bool           _resetEmailSent = false;
  String?        _errorMessage;

  @override
  void initState() {
    super.initState();
    _form = AuthFormController();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_form.formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final classToCommit = _selectedClass;
    if (classToCommit != null) {
      ref.read(selectedUserClassProvider.notifier).state = classToCommit.id;
    }

    try {
      switch (widget.mode) {
        case AuthMode.login:
          await ref.read(authAdapterProvider).signIn(
            email:    _form.emailCtrl.text.trim(),
            password: _form.passwordCtrl.text,
          );
          // No explicit navigation — GoRouter redirect fires on session emit.
          break;

        case AuthMode.signup:
          await ref.read(authAdapterProvider).signUp(
            email:       _form.emailCtrl.text.trim(),
            password:    _form.passwordCtrl.text,
            displayName: _form.displayNameCtrl.text.trim(),
            tenantId:    kDefaultTenantId,
            roleHint:    classToCommit?.id,
          );
          break;

        case AuthMode.reset:
          await ref.read(authAdapterProvider).sendPasswordReset(
            _form.emailCtrl.text.trim(),
          );
          // Don't reveal whether the email exists — show success regardless.
          if (mounted) setState(() => _resetEmailSent = true);
          break;
      }
    } catch (e, stack) {
      debugPrint('[ShellAuthRoot:${widget.mode.name}] error: $e\n$stack');
      // For reset, still show success — security best practice.
      if (widget.mode == AuthMode.reset) {
        if (mounted) setState(() => _resetEmailSent = true);
      } else {
        if (mounted) setState(() => _errorMessage = _mapError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _form.emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Enter your email above, then tap Forgot password.');
      return;
    }
    setState(() { _resetSending = true; _errorMessage = null; });
    try {
      await ref.read(authAdapterProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reset email sent to $email', style: AppTypography.helper),
        ));
      }
    } catch (_) {
      // Security: don't reveal whether email exists — swallow silently.
    } finally {
      if (mounted) setState(() => _resetSending = false);
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('invalid-credential') || msg.contains('user-not-found')) {
      return 'No account found with these credentials.';
    }
    if (msg.contains('wrong-password'))    return 'Incorrect password. Please try again.';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Wait a few minutes.';
    if (msg.contains('network'))           return 'Connection error. Check your internet.';
    if (msg.contains('401') || msg.contains('403')) {
      return 'Login failed. Check your credentials.';
    }
    if (msg.contains('email-already-in-use') || msg.contains('409')) {
      return 'An account with this email already exists. Try logging in.';
    }
    if (msg.contains('weak-password')) return 'Password must be at least 8 characters.';
    if (msg.contains('invalid-email')) return 'Please enter a valid email address.';
    if (_kDevMode) return 'DEBUG: $msg';
    return 'Something went wrong. Please try again.';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(authConfigProvider);
    _selectedClass ??= config.defaultClass;

    // Reset success state — show a dedicated view instead of the normal form.
    if (widget.mode == AuthMode.reset && _resetEmailSent) {
      return _buildResetSuccess(context);
    }

    final variant      = widget.layoutVariant ?? AuthLayoutVariant.stack;
    final layoutConfig = AuthLayoutConfig.forMode(
      widget.mode,
      variant:   variant,
      showRoles: config.isToggleVisible,
    );
    final vis = layoutConfig.sections;

    final sections = AuthTemplateSections(
      header: vis.header
          ? SectionAuthHeader(mode: widget.mode, config: config)
          : null,
      roles: vis.roles && _selectedClass != null
          ? SectionAuthRoles(
              userClasses: config.userClasses,
              selected:    _selectedClass!,
              onSelected:  (c) => setState(() => _selectedClass = c),
            )
          : null,
      form: vis.form
          ? SectionAuthForm(
              mode:           widget.mode,
              formController: _form,
              onSubmit:       _submit,
            )
          : null,
      help: vis.help
          ? SectionAuthHelp(
              errorMessage:       _errorMessage,
              allowPasswordReset: config.allowPasswordReset,
              isResetting:        _resetSending,
              onForgotPassword:   _forgotPassword,
            )
          : null,
      actions: vis.actions
          ? SectionAuthActions(
              mode:      widget.mode,
              isLoading: _isLoading,
              onSubmit:  _submit,
            )
          : null,
      bottomLink: vis.bottomLink
          ? _buildBottomLink(context, config)
          : null,
    );

    final templateBuilder = resolveTemplate(variant);

    return Scaffold(
      body: AppCanvas(
        type:          BackgroundType.meshParticle,
        particleStyle: ParticleStyle.drift,
        gradientStyle: GradientStyle.pulse,
        child: SafeArea(
          child: templateBuilder(mode: widget.mode, sections: sections),
        ),
      ),
    );
  }

  // ── Reset success state ──────────────────────────────────────────────────

  Widget _buildResetSuccess(BuildContext context) {
    return Scaffold(
      body: AppCanvas(
        type:          BackgroundType.meshParticle,
        particleStyle: ParticleStyle.drift,
        gradientStyle: GradientStyle.pulse,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BrandLogoEngine.verticalColored(),
                    SizedBox(height: AppSpacing.xxl),
                    // NOT const — AppColors.primary is not compile-time const
                    Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.primary,
                      size:  _kSuccessIconSize,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      _kSuccessTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authSubheading.copyWith(
                        fontSize:   20,
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
                    // Reusing WidgetAuthButton directly — success view is the shell's concern
                    _ResetSuccessButton(onTap: () => context.go(kRouteLogin)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Navigation links (shell owns routing — sections/widgets do not) ──────

  Widget _buildBottomLink(BuildContext context, QAuthConfig config) {
    switch (widget.mode) {
      case AuthMode.login:
        if (!config.allowSignup) return const SizedBox.shrink();
        return _AuthNavLink(
          prefix: _kLabelNoAccount,
          action: _kLabelSignup,
          onTap:  () => context.go(kRouteSignup),
        );
      case AuthMode.signup:
        return _AuthNavLink(
          prefix: _kLabelHasAcct,
          action: _kLabelLogin,
          onTap:  () => context.go(kRouteLogin),
        );
      case AuthMode.reset:
        return TextButton(
          onPressed: () => context.go(kRouteLogin),
          child: Text(
            _kLabelBackLogin,
            style: AppTypography.helper.copyWith(
              color:      AppColors.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private shell widgets — navigation and success UI
// ─────────────────────────────────────────────────────────────────────────────

// Rich text nav link (e.g. "Don't have an account? Sign up")
class _AuthNavLink extends StatelessWidget {
  final String     prefix;
  final String     action;
  final VoidCallback onTap;

  const _AuthNavLink({
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text:  prefix,
              style: AppTextStyles.authSubheading.copyWith(fontSize: _kLinkSize),
            ),
            TextSpan(
              text:  action,
              style: AppTextStyles.authSubheading.copyWith(
                fontSize:   _kLinkSize,
                color:      AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// "Back to Login" button shown on the reset success screen
class _ResetSuccessButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ResetSuccessButton({required this.onTap});

  @override
  State<_ResetSuccessButton> createState() => _ResetSuccessButtonState();
}

class _ResetSuccessButtonState extends State<_ResetSuccessButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration:  AppDurations.fast,
          height:    50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient:     _hovered ? AppGradients.buttonHover : AppGradients.button,
            borderRadius: AppRadius.pillBR,
            boxShadow:    _hovered ? AppShadows.buttonGlowHover : AppShadows.buttonGlow,
          ),
          child: Text('Back to Login', style: AppTypography.button),
        ),
      ),
    );
  }
}