// frontend/lib/spaces/space_architect/architect_registry/architect_screen_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. Screen registry + device presets.
//                  Add entries here as new screens are built across all spaces.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO ADD A SCREEN:
//   1. Import the screen's file at the top
//   2. Add an ArchitectScreenEntry to the matching space's list in kArchitectSpaces
//   3. Done — it appears in the dashboard automatically
//
// The `builder` closure returns the raw Widget. The preview wrapper handles all
// context (ProviderScope, MaterialApp, GoRouter, BrandScope, theme).
// You never need to worry about providers inside the builder.

import 'package:flutter/material.dart';

// Auth screens — the only real screens built so far
import '../../space_auth/auth_views/shell_auth_root.dart';
import '../../space_auth/auth_views/layout_auth_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectDevice — device resolution presets
// ─────────────────────────────────────────────────────────────────────────────

enum ArchitectDevice {
  mobileS(label: 'SE',         width: 375,  height: 667),
  mobileM(label: 'iPhone 14',  width: 390,  height: 844),
  mobileL(label: 'Plus',       width: 430,  height: 932),
  tablet( label: 'iPad',       width: 768,  height: 1024),
  tabletL(label: 'iPad Pro',   width: 1024, height: 1366),
  desktop(label: 'Desktop',    width: 1280, height: 800),
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

  // Whether this is a mobile-class device (portrait orientation by default)
  bool get isMobile => width < 600;
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectScreenEntry — a single screen registered for preview
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectScreenEntry {
  final String id;
  final String label;
  final String description;
  final Widget Function() builder;

  // Default device to open when previewing — mobile for auth, desktop for admin
  final ArchitectDevice defaultDevice;

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
  final String id;
  final String label;
  final IconData icon;
  final Color accent;
  final List<ArchitectScreenEntry> screens;

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
// Add new ArchitectSpace entries as new spaces are built.
// Add screens to existing spaces as they are created.
// Order here = order in the dashboard sidebar.

final List<ArchitectSpace> kArchitectSpaces = [

  // ── space_auth ─────────────────────────────────────────────────────────────
  ArchitectSpace(
    id:     'space_auth',
    label:  'space_auth',
    icon:   Icons.lock_outline_rounded,
    accent: const Color(0xFF9933FF),
    screens: [
      ArchitectScreenEntry(
        id:          'screen_auth_login',
        label:       'Login',
        description: 'Three-tier role toggle + credential form. '
                     'Tests the full login flow including biometric and social.',
        builder:     () => const ShellAuthRoot(mode: AuthMode.login),
      ),
      ArchitectScreenEntry(
        id:          'screen_auth_signup',
        label:       'Sign Up',
        description: 'Display name + email + password + confirm password. '
                     'Role toggle visible when signup config allows it.',
        builder:     () => const ShellAuthRoot(mode: AuthMode.signup),
      ),
      ArchitectScreenEntry(
        id:          'screen_auth_reset',
        label:       'Reset Password',
        description: 'Email-only form. Success state shows email-sent confirmation. '
                     'Never reveals whether an account exists.',
        builder:     () => const ShellAuthRoot(mode: AuthMode.reset),
      ),
    ],
  ),

  // ── space_value ────────────────────────────────────────────────────────────
  // Add screens here as space_value is built
  ArchitectSpace(
    id:     'space_value',
    label:  'space_value',
    icon:   Icons.home_outlined,
    accent: const Color(0xFF0F91D2),
    screens: const [],   // ← add screen entries as they're built
  ),

  // ── space_admin ────────────────────────────────────────────────────────────
  ArchitectSpace(
    id:     'space_admin',
    label:  'space_admin',
    icon:   Icons.admin_panel_settings_outlined,
    accent: const Color(0xFFFAAF2E),
    screens: const [],   // ← add screen entries as they're built
  ),

  // ── space_site ─────────────────────────────────────────────────────────────
  ArchitectSpace(
    id:     'space_site',
    label:  'space_site',
    icon:   Icons.language_outlined,
    accent: const Color(0xFF00E676),
    screens: const [],
  ),

  // ── space_dev ──────────────────────────────────────────────────────────────
  ArchitectSpace(
    id:     'space_dev',
    label:  'space_dev',
    icon:   Icons.code_outlined,
    accent: const Color(0xFF40C4FF),
    screens: const [],
  ),
];