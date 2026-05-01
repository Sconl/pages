// frontend/lib/spaces/space_architect/architect_model/architect_screen_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_model → architect_model.
//   • 2026-04-25 — Initial. ArchitectDevice presets, ArchitectScreenEntry,
//                  ArchitectSpace, kArchitectSpaces registry.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO ADD A SCREEN:
//   1. Import the screen widget file at the top of this file
//   2. Add an ArchitectScreenEntry to the matching space's list in kArchitectSpaces
//   3. Done — the dashboard portal renders it automatically
//
// The `builder` closure returns a raw Widget. The preview portal wraps it in
// its own ProviderScope + MaterialApp + BrandScope + MediaQuery override,
// so the builder needs no awareness of those layers.

import 'package:flutter/material.dart';

import '../../space_auth/auth_views/shell_auth_root.dart';
import '../../space_auth/auth_views/layout_auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectDevice — responsive device presets
// ─────────────────────────────────────────────────────────────────────────────

enum ArchitectDevice {
  mobileS( label: 'SE',        width: 375,  height: 667),
  mobileM( label: 'iPhone 14', width: 390,  height: 844),
  mobileL( label: 'Plus',      width: 430,  height: 932),
  tablet(  label: 'iPad',      width: 768,  height: 1024),
  tabletL( label: 'iPad Pro',  width: 1024, height: 1366),
  desktop( label: 'Desktop',   width: 1280, height: 800),
  desktopW(label: 'Wide',      width: 1440, height: 900);

  const ArchitectDevice({
    required this.label,
    required this.width,
    required this.height,
  });

  final String label;
  final double width;
  final double height;

  Size get size => Size(width, height);

  // Mobile frames get realistic safe-area insets in the preview
  bool get isMobile => width < 600;
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectScreenEntry
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectScreenEntry {
  final String            id;
  final String            label;
  final String            description;
  final Widget Function() builder;
  final ArchitectDevice   defaultDevice;

  const ArchitectScreenEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.builder,
    this.defaultDevice = ArchitectDevice.mobileM,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectSpace — a grouping of screens in the dashboard sidebar
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectSpace {
  final String                     id;
  final String                     label;
  final IconData                   icon;
  final Color                      accent;
  final List<ArchitectScreenEntry>  screens;

  const ArchitectSpace({
    required this.id,
    required this.label,
    required this.icon,
    required this.accent,
    required this.screens,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// kArchitectSpaces — THE REGISTRY
// ─────────────────────────────────────────────────────────────────────────────
//
// Order here = order in the dashboard sidebar.
// Add ArchitectSpace entries as new spaces are built.
// Add ArchitectScreenEntry items to existing spaces as their screens are created.

final List<ArchitectSpace> kArchitectSpaces = [

  ArchitectSpace(
    id:     'space_auth',
    label:  'space_auth',
    icon:   Icons.lock_outline_rounded,
    accent: const Color(0xFF9933FF),
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
        description: 'Display name + email + password + confirm. Role toggle visible '
                     'when signup config enables it.',
        builder:     () => const ShellAuthRoot(mode: AuthMode.signup),
      ),
      ArchitectScreenEntry(
        id:          'screen_auth_reset',
        label:       'Reset Password',
        description: 'Email-only form. Success state shows email-sent confirmation.',
        builder:     () => const ShellAuthRoot(mode: AuthMode.reset),
      ),
    ],
  ),

  ArchitectSpace(
    id:     'space_value',
    label:  'space_value',
    icon:   Icons.home_outlined,
    accent: const Color(0xFF0F91D2),
    screens: const [],
  ),

  ArchitectSpace(
    id:     'space_admin',
    label:  'space_admin',
    icon:   Icons.admin_panel_settings_outlined,
    accent: const Color(0xFFFAAF2E),
    screens: const [],
  ),

  ArchitectSpace(
    id:     'space_site',
    label:  'space_site',
    icon:   Icons.language_outlined,
    accent: const Color(0xFF00E676),
    screens: const [],
  ),

  ArchitectSpace(
    id:     'space_dev',
    label:  'space_dev',
    icon:   Icons.code_outlined,
    accent: const Color(0xFF40C4FF),
    screens: const [],
  ),
];