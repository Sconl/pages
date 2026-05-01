// frontend/lib/spaces/space_architect/architect_views/shell_architect_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Login shell — owns form state and credential
//                  validation, delegates layout to the template system.
// ─────────────────────────────────────────────────────────────────────────────
//
// SCRTSC: Shell → Config → Registry → Template → Sections → Widgets.
//
// This is the orchestrator for the architect login experience. It:
//   - owns all mutable state (controllers, loading flag, error message)
//   - reads ArchitectLayoutConfig to decide which sections are visible
//   - resolves the correct template via the registry
//   - passes pre-built section widgets into the template
//   - calls validateArchitectCredentials and flips architectIsLoggedInProvider
//
// The template, sections, and widgets know nothing about the state or the
// credential check — this file is the only one that does.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/style/app_style.dart';
import '../architect_model/architect_credentials.dart';
import '../architect_state/architect_riverpod.dart';
import 'layout_architect_config.dart';
import 'layout_architect_registry.dart';
import 'architect_sections/section_architect_header.dart';
import 'architect_sections/section_architect_form.dart';
import 'architect_sections/section_architect_actions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── UX ─────────────────────────────────────────────────────────────────────────
// Small artificial delay so the loading spinner actually renders — a 0ms
// credential check makes it impossible to verify loading states in development
const Duration _kSubmitDelay  = Duration(milliseconds: 400);
const String   _kErrorMessage = 'Invalid credentials. Check username and password.';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class ShellArchitectRoot extends ConsumerStatefulWidget {
  const ShellArchitectRoot({super.key});

  @override
  ConsumerState<ShellArchitectRoot> createState() => _ShellArchitectRootState();
}

class _ShellArchitectRootState extends ConsumerState<ShellArchitectRoot> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
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

    await Future.delayed(_kSubmitDelay);

    final valid = validateArchitectCredentials(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (valid) {
      ref.read(architectIsLoggedInProvider.notifier).state = true;
    } else {
      setState(() { _isLoading = false; _errorMessage = _kErrorMessage; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Config selects which sections are visible and which template to use
    const config  = ArchitectLayoutConfig.login;
    final vis     = config.sections;
    final builder = resolveArchitectTemplate(config.variant);

    final sections = ArchitectLoginSections(
      header:  vis.header  ? const SectionArchitectHeader()  : null,
      form:    vis.form
          ? SectionArchitectForm(
              formKey:      _formKey,
              usernameCtrl: _usernameCtrl,
              passwordCtrl: _passwordCtrl,
              usernameFocus: _usernameFocus,
              passwordFocus: _passwordFocus,
              onSubmit:     _submit,
            )
          : null,
      actions: vis.actions
          ? SectionArchitectActions(
              isLoading:    _isLoading,
              errorMessage: _errorMessage,
              onSubmit:     _submit,
            )
          : null,
    );

    return Scaffold(
      body: AppCanvas(
        type:          BackgroundType.meshParticle,
        particleStyle: ParticleStyle.drift,
        gradientStyle: GradientStyle.pulse,
        child: SafeArea(
          child: builder(sections: sections),
        ),
      ),
    );
  }
}