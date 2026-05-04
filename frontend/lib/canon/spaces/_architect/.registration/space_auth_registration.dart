// frontend/lib/spaces/_architect/.registrations/space_auth_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Correct imports documented. Two imports is always enough
//                  for a space_auth screen: the shell root + AuthMode enum.
// ─────────────────────────────────────────────────────────────────────────────
//
// ─────────────────────────────────────────────────────────────────────────────
// HOW SCREEN REGISTRATION WORKS — read this once
// ─────────────────────────────────────────────────────────────────────────────
//
// Every screen in the architect preview is built by returning a widget from
// the `builder` closure inside ArchitectScreenEntry.
//
// The ONLY widget you need to return is the SHELL ROOT of that screen.
// The shell root is the top-level widget — it owns everything inside it:
// layout, sections, form state, providers, animations. You don't import any
// of those. You just construct the shell and hand it its arguments.
//
// For space_auth the shell is ShellAuthRoot. It takes one argument: an
// AuthMode enum value (login / signup / reset). AuthMode lives in
// layout_auth_config.dart.
//
// GENERAL PATTERN FOR ANY SPACE:
//
//   Import 1: the shell root        → lib/spaces/{space}/*/shell_{name}_root.dart
//   Import 2: any enums/config it   → lib/spaces/{space}/*/layout_{name}_config.dart
//             needs as arguments      (only needed if the shell takes constructor args)
//
//   builder: () => const ShellFooRoot(mode: FooMode.bar)
//
// If the shell takes no constructor args (just `const ShellFooRoot()`), you
// only need one import.
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

// Import 1: the shell root — this IS the screen
import '../../space_auth/auth_views/shell_auth_root.dart';

// Import 2: AuthMode enum — the only argument ShellAuthRoot takes
// It lives in layout_auth_config.dart alongside the shell registry.
import '../../space_auth/auth_views/layout_auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const _kId     = 'space_auth';
const _kLabel  = 'space_auth';
const _kIcon   = Icons.lock_outline_rounded;
const _kAccent = Color(0xFF9933FF);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

final ArchitectSpace kRegisterSpaceAuth = ArchitectSpace(
  id:     _kId,
  label:  _kLabel,
  icon:   _kIcon,
  accent: _kAccent,
  screens: [

    // ── Login ─────────────────────────────────────────────────────────────────
    // Shell: ShellAuthRoot  •  Arg: AuthMode.login
    // That's it. The shell handles role toggle, form, biometric, social, etc.
    ArchitectScreenEntry(
      id:          'screen_auth_login',
      label:       'Login',
      description: 'Three-tier role toggle, credential fields, '
                   'forgot-password link, biometric shortcut.',
      builder:     () => const ShellAuthRoot(mode: AuthMode.login),
      defaultDevice: ArchitectDevice.mobileM,
    ),

    // ── Sign Up ───────────────────────────────────────────────────────────────
    ArchitectScreenEntry(
      id:          'screen_auth_signup',
      label:       'Sign Up',
      description: 'Display name + email + password + confirm password. '
                   'Role toggle visible when signup config enables it.',
      builder:     () => const ShellAuthRoot(mode: AuthMode.signup),
      defaultDevice: ArchitectDevice.mobileM,
    ),

    // ── Reset Password ────────────────────────────────────────────────────────
    ArchitectScreenEntry(
      id:          'screen_auth_reset',
      label:       'Reset Password',
      description: 'Email-only form. Success state shows the email-sent '
                   'confirmation screen. Never reveals whether an account exists.',
      builder:     () => const ShellAuthRoot(mode: AuthMode.reset),
      defaultDevice: ArchitectDevice.mobileM,
    ),
  ],
);