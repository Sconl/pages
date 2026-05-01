// frontend/lib/spaces/space_architect/architect_views/architect_templates/template_architect_login.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Single-column centred login template.
// ─────────────────────────────────────────────────────────────────────────────
//
// Arranges header → form → actions in a centred scrollable column.
// Same structural pattern as template_auth_stack.dart for visual consistency.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../layout_architect_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kFormMaxWidth = 400.0;
const double _kFormPaddingH = 32.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

Widget templateArchitectLogin({
  required ArchitectLoginSections sections,
}) =>
    _TemplateArchitectLogin(sections: sections);

class _TemplateArchitectLogin extends StatelessWidget {
  final ArchitectLoginSections sections;
  const _TemplateArchitectLogin({required this.sections});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenH),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kFormPaddingH),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sections.header != null) ...[
                    SizedBox(height: AppSpacing.xl),
                    sections.header!,
                    SizedBox(height: AppSpacing.xl),
                  ],
                  if (sections.form != null) sections.form!,
                  SizedBox(height: AppSpacing.md),
                  if (sections.actions != null) sections.actions!,
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}