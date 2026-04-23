// lib/spaces/space_auth/auth_views/layout_auth_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Registry mapping variants to template builders.
//   v2.0.0 — Added social field to AuthTemplateSections.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

import 'layout_auth_config.dart';
import 'auth_templates/template_auth_stack.dart';
import 'auth_templates/template_auth_split.dart';
import 'auth_templates/template_auth_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthTemplateSections — pre-built section widgets passed to a template
// ─────────────────────────────────────────────────────────────────────────────

class AuthTemplateSections {
  final Widget? header;
  final Widget? roles;
  final Widget? form;
  final Widget? help;
  final Widget? actions;
  final Widget? social;      // social login section — after actions
  final Widget? bottomLink;

  const AuthTemplateSections({
    this.header,
    this.roles,
    this.form,
    this.help,
    this.actions,
    this.social,
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
// authLayoutRegistry
// ─────────────────────────────────────────────────────────────────────────────

final Map<AuthLayoutVariant, AuthTemplateBuilder> authLayoutRegistry = {
  AuthLayoutVariant.stack: templateAuthStack,
  AuthLayoutVariant.split: templateAuthSplit,
  AuthLayoutVariant.card:  templateAuthCard,
};

AuthTemplateBuilder resolveTemplate(AuthLayoutVariant variant) =>
    authLayoutRegistry[variant] ?? templateAuthStack;