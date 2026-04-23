// lib/spaces/space_auth/auth_views/auth_templates/template_auth_stack.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Single column layout. Default template.
//   v2.0.0 — Wires social section between actions and bottomLink.
//             Social appears below the submit button with its own divider
//             (handled inside SectionAuthSocial itself).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../core/style/app_style.dart';
import '../layout_auth_config.dart';
import '../layout_auth_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kFormMaxWidth = 400.0;
const _kFormPaddingH = 32.0;

// ─────────────────────────────────────────────────────────────────────────────
// templateAuthStack
// ─────────────────────────────────────────────────────────────────────────────

Widget templateAuthStack({
  required AuthMode             mode,
  required AuthTemplateSections sections,
}) =>
    _TemplateAuthStack(mode: mode, sections: sections);

class _TemplateAuthStack extends StatelessWidget {
  final AuthMode             mode;
  final AuthTemplateSections sections;

  const _TemplateAuthStack({required this.mode, required this.sections});

  @override
  Widget build(BuildContext context) {
    final screen          = MediaQuery.of(context);
    final availableHeight = screen.size.height
        - screen.padding.top
        - screen.padding.bottom;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
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

                  // ── Middle: roles + form + help + actions + social ───────
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
                      // Social appears below the main CTA, inside its own divider
                      if (sections.social != null)
                        sections.social!,
                    ],
                  ),

                  // ── Bottom: navigation link ──────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Column(
                      children: [
                        if (sections.bottomLink != null) ...[
                          SizedBox(height: AppSpacing.lg),
                          const _BottomDivider(),
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

class _BottomDivider extends StatelessWidget {
  const _BottomDivider();
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