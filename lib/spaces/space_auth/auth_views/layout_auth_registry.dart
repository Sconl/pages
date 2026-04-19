// lib/spaces/space_auth/auth_views/layout_auth_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Translator/factory layer — maps AuthLayoutVariant to the
//             correct template builder function. ShellAuthRoot stays generic;
//             template choices evolve here without touching the shell.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: the mapping from layout choice to template.
// What does NOT live here: layout policy, UI styling, section content, auth logic.

import 'package:flutter/widgets.dart';

import 'layout_auth_config.dart';
import 'auth_templates/template_auth_stack.dart';
import 'auth_templates/template_auth_split.dart';
import 'auth_templates/template_auth_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthTemplateSections — pre-built section widgets passed to a template.
// Templates arrange these; they do not build them.
// ─────────────────────────────────────────────────────────────────────────────

class AuthTemplateSections {
  final Widget? header;
  final Widget? roles;
  final Widget? form;
  final Widget? help;
  final Widget? actions;
  final Widget? bottomLink;

  const AuthTemplateSections({
    this.header,
    this.roles,
    this.form,
    this.help,
    this.actions,
    this.bottomLink,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthTemplateBuilder typedef
// ─────────────────────────────────────────────────────────────────────────────

typedef AuthTemplateBuilder = Widget Function({
  required AuthMode             mode,
  required AuthTemplateSections sections,
});

// ─────────────────────────────────────────────────────────────────────────────
// authLayoutRegistry — the map
// ─────────────────────────────────────────────────────────────────────────────

// Adding a new template = add one entry here. Nothing else changes.
final Map<AuthLayoutVariant, AuthTemplateBuilder> authLayoutRegistry = {
  AuthLayoutVariant.stack: templateAuthStack,
  AuthLayoutVariant.split: templateAuthSplit,
  AuthLayoutVariant.card:  templateAuthCard,
};

// ─────────────────────────────────────────────────────────────────────────────
// resolveTemplate — convenience lookup with stack fallback
// ─────────────────────────────────────────────────────────────────────────────

AuthTemplateBuilder resolveTemplate(AuthLayoutVariant variant) =>
    authLayoutRegistry[variant] ?? templateAuthStack;