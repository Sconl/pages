// lib/spaces/space_auth/auth_model/auth_form_state.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Pure data models for auth form state. No framework deps.
//   v2.0.0 — Moved from model/ → auth_model/ per layered architecture.
//             Added AuthFormController — holds TextEditingControllers and
//             FocusNodes for the auth form. Owned by ShellAuthRoot, passed
//             into SectionAuthForm. Keeps controller lifecycle in one place.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: the shape of auth form data.
// What does NOT live here: any UI, any provider import, any auth logic.

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const kDisplayNameMinLength = 2;
const kDisplayNameMaxLength = 50;
const kPasswordMinLength    = 8;

// ─────────────────────────────────────────────────────────────────────────────
// AuthFormController
// ─────────────────────────────────────────────────────────────────────────────

// Owns all controllers and focus nodes for the auth form.
// ShellAuthRoot creates one, disposes it, and passes it to SectionAuthForm.
// SectionAuthForm reads from it — never owns it.
class AuthFormController {
  final formKey             = GlobalKey<FormState>();
  final emailCtrl           = TextEditingController();
  final passwordCtrl        = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final displayNameCtrl     = TextEditingController();

  final emailFocus           = FocusNode();
  final passwordFocus        = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final displayNameFocus     = FocusNode();

  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    displayNameCtrl.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    displayNameFocus.dispose();
  }
}