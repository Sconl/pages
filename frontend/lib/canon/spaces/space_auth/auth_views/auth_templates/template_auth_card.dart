// lib/spaces/space_auth/auth_views/auth_templates/template_auth_card.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Centered card container layout. Stub for Cycle 1.
// ─────────────────────────────────────────────────────────────────────────────
//
// Wraps the auth experience in a floating card for modal-like or
// inset form aesthetics. Wire fully in Cycle 1.

import 'package:flutter/material.dart';

import '../layout_auth_config.dart';
import '../layout_auth_registry.dart';
import 'template_auth_stack.dart';

// ─────────────────────────────────────────────────────────────────────────────
// templateAuthCard
// ─────────────────────────────────────────────────────────────────────────────

Widget templateAuthCard({
  required AuthMode             mode,
  required AuthTemplateSections sections,
}) {
  return _TemplateAuthCard(mode: mode, sections: sections);
}

class _TemplateAuthCard extends StatelessWidget {
  final AuthMode             mode;
  final AuthTemplateSections sections;

  const _TemplateAuthCard({required this.mode, required this.sections});

  @override
  Widget build(BuildContext context) {
    // TODO(Cycle 1): implement card wrapping. Falling back to stack for now.
    return templateAuthStack(mode: mode, sections: sections);
  }
}