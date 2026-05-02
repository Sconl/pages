// frontend/lib/spaces/_architect/space_registrations/space_admin_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Stub registration for space_admin.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

const _kId     = 'space_admin';
const _kLabel  = 'space_admin';
const _kIcon   = Icons.admin_panel_settings_outlined;
const _kAccent = Color(0xFFFAAF2E);   // Kenyan Amber

final ArchitectSpace kRegisterSpaceAdmin = ArchitectSpace(
  id:      _kId,
  label:   _kLabel,
  icon:    _kIcon,
  accent:  _kAccent,
  screens: const [],
);