// frontend/lib/spaces/_architect/space_registrations/space_dev_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Stub registration for space_dev.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

const _kId     = 'space_dev';
const _kLabel  = 'space_dev';
const _kIcon   = Icons.code_outlined;
const _kAccent = Color(0xFF40C4FF);

final ArchitectSpace kRegisterSpaceDev = ArchitectSpace(
  id:      _kId,
  label:   _kLabel,
  icon:    _kIcon,
  accent:  _kAccent,
  screens: const [],
);