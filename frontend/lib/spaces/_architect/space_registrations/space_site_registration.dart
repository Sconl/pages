// frontend/lib/spaces/_architect/space_registrations/space_site_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Stub registration for space_site.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

const _kId     = 'space_site';
const _kLabel  = 'space_site';
const _kIcon   = Icons.language_outlined;
const _kAccent = Color(0xFF00E676);

final ArchitectSpace kRegisterSpaceSite = ArchitectSpace(
  id:      _kId,
  label:   _kLabel,
  icon:    _kIcon,
  accent:  _kAccent,
  screens: const [],
);