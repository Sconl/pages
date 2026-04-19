// lib/spaces/space_auth/auth_views/auth_templates/template_auth_split.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Two-panel split layout — branding left, form right.
//             Stub for Cycle 1. Falls back to stack below breakpoint.
// ─────────────────────────────────────────────────────────────────────────────
//
// Intended for desktop-first experiences. Not the default. Wire in Cycle 1.

import 'package:flutter/material.dart';

import '../layout_auth_config.dart';
import '../layout_auth_registry.dart';
import 'template_auth_stack.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kBreakpoint = 840.0;

// ─────────────────────────────────────────────────────────────────────────────
// templateAuthSplit
// ─────────────────────────────────────────────────────────────────────────────

Widget templateAuthSplit({
  required AuthMode             mode,
  required AuthTemplateSections sections,
}) {
  return _TemplateAuthSplit(mode: mode, sections: sections);
}

class _TemplateAuthSplit extends StatelessWidget {
  final AuthMode             mode;
  final AuthTemplateSections sections;

  const _TemplateAuthSplit({required this.mode, required this.sections});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Below breakpoint → fall back to stack so mobile is never broken.
    if (width < _kBreakpoint) {
      return templateAuthStack(mode: mode, sections: sections);
    }

    // TODO(Cycle 1): implement full split layout.
    // For now falls through to stack even on desktop — placeholder.
    return templateAuthStack(mode: mode, sections: sections);
  }
}