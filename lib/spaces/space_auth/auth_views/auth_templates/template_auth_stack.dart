// lib/spaces/space_auth/auth_views/auth_templates/template_auth_stack.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Single-column stacked arrangement. Default template.
//             Fills available height via ConstrainedBox(minHeight) so the
//             column distributes space evenly without scrolling on most devices.
//             SingleChildScrollView activates gracefully when the keyboard appears.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: how pre-built sections are arranged vertically.
// What does NOT live here: section content, auth logic, config decisions.

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../layout_auth_config.dart';
import '../layout_auth_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kFormMaxWidth  = 400.0;
const _kFormPaddingH  = 32.0;

// ─────────────────────────────────────────────────────────────────────────────
// templateAuthStack — top-level function matching AuthTemplateBuilder typedef
// ─────────────────────────────────────────────────────────────────────────────

Widget templateAuthStack({
  required AuthMode            mode,
  required AuthTemplateSections sections,
}) {
  return _TemplateAuthStack(mode: mode, sections: sections);
}

class _TemplateAuthStack extends StatelessWidget {
  final AuthMode             mode;
  final AuthTemplateSections sections;

  const _TemplateAuthStack({
    required this.mode,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final screen          = MediaQuery.of(context);
    final availableHeight = screen.size.height
        - screen.padding.top
        - screen.padding.bottom;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _kFormMaxWidth),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            // minHeight fills the screen when content is short — keeps
            // spaceBetween from collapsing to content height on tall screens.
            constraints: BoxConstraints(minHeight: availableHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kFormPaddingH),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top: header ─────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xl),
                    child: sections.header ?? const SizedBox.shrink(),
                  ),

                  // ── Middle: roles + form + help + actions ────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sections.roles != null) ...[
                        sections.roles!,
                        SizedBox(height: AppSpacing.lg),
                      ],
                      if (sections.form != null)
                        sections.form!,
                      if (sections.help != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        sections.help!,
                      ],
                      SizedBox(height: AppSpacing.sm),
                      if (sections.actions != null)
                        sections.actions!,
                    ],
                  ),

                  // ── Bottom: navigation link ──────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Column(
                      children: [
                        if (sections.bottomLink != null) ...[
                          SizedBox(height: AppSpacing.lg),
                          const WidgetAuthDividerInline(),
                          SizedBox(height: AppSpacing.md),
                          sections.bottomLink!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Small inline alias so the template can use the divider without importing
// auth_widgets directly. The template only arranges — but it can use style tokens.
class WidgetAuthDividerInline extends StatelessWidget {
  const WidgetAuthDividerInline();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1.0)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child:   Text('OR', style: AppTypography.helper),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1.0)),
      ],
    );
  }
}