// frontend/lib/spaces/space_architect/architect_screens/screen_architect_login.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. Architect login screen. Reuses auth widget
//                  primitives so it looks identical to the real auth flow.
//                  Local validation only — no Riverpod auth providers needed.
// ─────────────────────────────────────────────────────────────────────────────
//
// This is intentionally separate from ShellAuthRoot. It shares the visual
// language (AppCanvas, BrandLogoEngine, WidgetAuthField, WidgetAuthButton)
// but validates against local hardcoded credentials, not a backend.
//
// The architect toggle that gives access to the role selector lives here,
// but only here. Regular users never see this toggle.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/style/app_style.dart';
import '../../space_auth/auth_views/auth_widgets/widget_auth_field.dart';
import '../../space_auth/auth_views/auth_widgets/widget_auth_button.dart';
import '../../space_auth/auth_views/auth_widgets/widget_auth_toggle.dart';
import '../architect_auth/architect_credentials.dart';
import '../architect_state/architect_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Copy ───────────────────────────────────────────────────────────────────────
const String _kHeading       = 'Architect Access';
const String _kSubheading    = 'QSpace internal development system';
const String _kLabelUsername = 'Username';
const String _kLabelPassword = 'Password';
const String _kBadgeLabel    = 'ARCHITECT';
const String _kErrorInvalid  = 'Invalid credentials. Check username and password.';

// ── Layout ─────────────────────────────────────────────────────────────────────
const double _kFormMaxWidth   = 400.0;
const double _kFormPaddingH   = 32.0;
const double _kHeadingSize    = 22.0;
const double _kSubheadingSize = 13.5;
const double _kBadgeFontSize  = 10.0;
const double _kBadgePadH      = 10.0;
const double _kBadgePadV      = 4.0;
const double _kIconSize       = 20.0;

// ─────────────────────────────────────────────────────────────────────────────
// ScreenArchitectLogin
// ─────────────────────────────────────────────────────────────────────────────

class ScreenArchitectLogin extends ConsumerStatefulWidget {
  const ScreenArchitectLogin({super.key});

  @override
  ConsumerState<ScreenArchitectLogin> createState() =>
      _ScreenArchitectLoginState();
}

class _ScreenArchitectLoginState extends ConsumerState<ScreenArchitectLogin> {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool    _isLoading    = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    // Tiny artificial delay so the loading spinner renders — UX polish
    await Future.delayed(const Duration(milliseconds: 400));

    final valid = validateArchitectCredentials(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (valid) {
      ref.read(architectIsLoggedInProvider.notifier).state = true;
    } else {
      setState(() {
        _isLoading    = false;
        _errorMessage = _kErrorInvalid;
      });
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
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _kFormPaddingH),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: AppSpacing.xl),

                      // Logo + architect badge
                      _ArchitectHeader(),

                      SizedBox(height: AppSpacing.xl),

                      // Heading
                      Text(
                        _kHeading,
                        textAlign: TextAlign.center,
                        style: AppTypography.h2.copyWith(
                          fontSize:   _kHeadingSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        _kSubheading,
                        textAlign: TextAlign.center,
                        style: AppTypography.helper.copyWith(
                          fontSize: _kSubheadingSize,
                          color:    AppColors.textMuted,
                        ),
                      ),

                      SizedBox(height: AppSpacing.xl),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WidgetAuthField(
                              controller:        _usernameCtrl,
                              label:             _kLabelUsername,
                              focusNode:         _usernameFocus,
                              autofocus:         true,
                              textInputAction:   TextInputAction.next,
                              onEditingComplete: () =>
                                  _passwordFocus.requestFocus(),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.textMuted,
                                size:  _kIconSize,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Username is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppSpacing.md),
                            WidgetAuthField(
                              controller:        _passwordCtrl,
                              label:             _kLabelPassword,
                              focusNode:         _passwordFocus,
                              obscureText:       true,
                              textInputAction:   TextInputAction.done,
                              onEditingComplete: _submit,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textMuted,
                                size:  _kIconSize,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.sm),

                      // Inline error
                      if (_errorMessage != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        WidgetAuthErrorBanner(message: _errorMessage!),
                        SizedBox(height: AppSpacing.sm),
                      ],

                      SizedBox(height: AppSpacing.sm),

                      // Submit
                      WidgetAuthButton(
                        label:     'Enter Architect Space',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),

                      SizedBox(height: AppSpacing.xl),
                    ],
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
// _ArchitectHeader — logo + ARCHITECT badge
// ─────────────────────────────────────────────────────────────────────────────
//
// Identical to SectionAuthHeader in layout, but adds the badge below the logo
// to visually distinguish this from the regular user login.

class _ArchitectHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BrandLogoEngine.verticalColored(),
        SizedBox(height: AppSpacing.sm),
        // The badge that tells you this isn't the regular login
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _kBadgePadH,
            vertical:   _kBadgePadV,
          ),
          decoration: BoxDecoration(
            gradient:     AppGradients.button,
            borderRadius: AppRadius.pillBR,
          ),
          child: Text(
            _kBadgeLabel,
            style: AppTypography.badge.copyWith(
              fontSize:      _kBadgeFontSize,
              color:         AppColors.onPrimary,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ],
    );
  }
}