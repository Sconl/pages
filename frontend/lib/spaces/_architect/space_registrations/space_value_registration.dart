// frontend/lib/spaces/_architect/space_registrations/space_value_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Stub registration for space_value.
// ─────────────────────────────────────────────────────────────────────────────
//
// Add screen imports + ArchitectScreenEntry items to the screens list as
// space_value screens are built. The dashboard will populate automatically.

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const _kId     = 'space_value';
const _kLabel  = 'space_value';
const _kIcon   = Icons.home_outlined;
const _kAccent = Color(0xFF0F91D2);   // Digital Blue

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

final ArchitectSpace kRegisterSpaceValue = ArchitectSpace(
  id:      _kId,
  label:   _kLabel,
  icon:    _kIcon,
  accent:  _kAccent,
  screens: const [],   // ← import screens and add entries as they are built
);