// lib/spaces/space_auth/auth_views/auth_sections/section_auth_roles.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Choice surface for selecting which user class / auth
//             path to use. Renders WidgetAuthToggle.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: the role/portal selection block — visual choice surface.
// What does NOT live here: permission enforcement, backend claims, routing.

import 'package:flutter/material.dart';

import '../../../../core/auth/auth_config.dart';
import '../auth_widgets/widget_auth_toggle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SectionAuthRoles
// ─────────────────────────────────────────────────────────────────────────────

class SectionAuthRoles extends StatelessWidget {
  final List<AuthUserClass>         userClasses;
  final AuthUserClass               selected;
  final ValueChanged<AuthUserClass> onSelected;

  const SectionAuthRoles({
    super.key,
    required this.userClasses,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetAuthToggle(
      userClasses: userClasses,
      selected:    selected,
      onSelected:  onSelected,
    );
  }
}