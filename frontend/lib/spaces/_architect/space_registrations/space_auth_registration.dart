// frontend/lib/spaces/_architect/space_registrations/space_auth_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Registration for space_auth screens.
// ─────────────────────────────────────────────────────────────────────────────
//
// TEMPLATE — copy this file to register a new space:
//
//   1. Rename to {space_name}_registration.dart
//   2. Change kRegisterSpace{Name} to match
//   3. Update id, label, icon, accent
//   4. Import the screen widget(s) and add ArchitectScreenEntry items
//   5. Add the import + list entry in architect_auto_registry.dart
//
// That's the complete workflow for registering any new space.

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

// Screen imports for space_auth
import '../../space_auth/auth_views/shell_auth_root.dart';
import '../../space_auth/auth_views/layout_auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change accent / icon / label here when the space is rebranded
// ─────────────────────────────────────────────────────────────────────────────

const _kId     = 'space_auth';
const _kLabel  = 'space_auth';
const _kIcon   = Icons.lock_outline_rounded;
const _kAccent = Color(0xFF9933FF);   // Deep Violet — primary brand colour

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

final ArchitectSpace kRegisterSpaceAuth = ArchitectSpace(
  id:     _kId,
  label:  _kLabel,
  icon:   _kIcon,
  accent: _kAccent,
  screens: [
    ArchitectScreenEntry(
      id:          'screen_auth_login',
      label:       'Login',
      description: 'Three-tier role toggle, credential fields, biometric shortcut.',
      builder:     () => const ShellAuthRoot(mode: AuthMode.login),
    ),
    ArchitectScreenEntry(
      id:          'screen_auth_signup',
      label:       'Sign Up',
      description: 'Display name + email + password + confirm. '
                   'Role toggle visible when signup config enables it.',
      builder:     () => const ShellAuthRoot(mode: AuthMode.signup),
    ),
    ArchitectScreenEntry(
      id:          'screen_auth_reset',
      label:       'Reset Password',
      description: 'Email-only form. Never reveals whether an account exists. '
                   'Success state shows email-sent confirmation.',
      builder:     () => const ShellAuthRoot(mode: AuthMode.reset),
    ),
  ],
);