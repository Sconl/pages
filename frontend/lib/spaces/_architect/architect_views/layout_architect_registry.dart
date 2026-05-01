// frontend/lib/spaces/space_architect/architect_views/layout_architect_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Maps ArchitectLayoutVariant → template builder.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

import 'layout_architect_config.dart';
import 'architect_templates/template_architect_login.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectLoginSections — section widgets passed to a template
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectLoginSections {
  final Widget? header;
  final Widget? form;
  final Widget? actions;

  const ArchitectLoginSections({
    this.header,
    this.form,
    this.actions,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Template builder typedef
// ─────────────────────────────────────────────────────────────────────────────

typedef ArchitectTemplateBuilder = Widget Function({
  required ArchitectLoginSections sections,
});

// ─────────────────────────────────────────────────────────────────────────────
// Registry + resolver
// ─────────────────────────────────────────────────────────────────────────────

final Map<ArchitectLayoutVariant, ArchitectTemplateBuilder> architectLayoutRegistry = {
  ArchitectLayoutVariant.stack: templateArchitectLogin,
};

ArchitectTemplateBuilder resolveArchitectTemplate(ArchitectLayoutVariant variant) =>
    architectLayoutRegistry[variant] ?? templateArchitectLogin;