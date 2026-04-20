// lib/spaces/space_admin/admin_portals/brand_portal/brand_sections/section_brand_identity.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Six editable identity fields (wordBold, wordLight,
//             appName, tagline, domain, copyright) with per-field guidance copy.
//             Uses discardGeneration as a ValueKey for clean controller resets.
//             Editable gate via QAdminConfigScope.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../../../../../core/admin/admin_brand_draft.dart';
import '../../../../../core/admin/admin_config.dart';

class SectionBrandIdentity extends StatelessWidget {
  const SectionBrandIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    final draft    = AdminBrandDraftScope.of(context);
    final editable = QAdminConfigScope.of(context).accessFor('brand').editable;

    return KeyedSubtree(
      key: ValueKey('identity_${draft.discardGeneration}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card,
        child: Column(
          children: [
            _IdentityRow(
              label:     'Word Bold',
              guidance:  'The bold/weighted part of the two-tone wordmark. '
                         'e.g. "Well" in WellPath.',
              initial:   draft.draftWordBold,
              editable:  editable,
              onChanged: draft.setWordBold,
            ),
            Divider(height: 1, color: AppColors.border),
            _IdentityRow(
              label:     'Word Light',
              guidance:  'The lighter part of the wordmark. e.g. "Path" in WellPath.',
              initial:   draft.draftWordLight,
              editable:  editable,
              onChanged: draft.setWordLight,
            ),
            Divider(height: 1, color: AppColors.border),
            _IdentityRow(
              label:     'App Name',
              guidance:  'Full app name used in titles, meta tags, and onboarding.',
              initial:   draft.draftAppName,
              editable:  editable,
              onChanged: draft.setAppName,
            ),
            Divider(height: 1, color: AppColors.border),
            _IdentityRow(
              label:     'Tagline',
              guidance:  'One-line brand promise. Shown below the wordmark on hero sections.',
              initial:   draft.draftTagline,
              editable:  editable,
              onChanged: draft.setTagline,
            ),
            Divider(height: 1, color: AppColors.border),
            _IdentityRow(
              label:     'Domain',
              guidance:  'Public URL shown in footers and contact sections.',
              initial:   draft.draftDomain,
              editable:  editable,
              onChanged: draft.setDomain,
            ),
            Divider(height: 1, color: AppColors.border),
            _IdentityRow(
              label:     'Copyright',
              guidance:  'Footer copyright string. Include year and legal entity name.',
              initial:   draft.draftCopyright,
              editable:  editable,
              onChanged: draft.setCopyright,
              isLast:    true,
            ),
          ],
        ),
      ),
    );
  }
}


class _IdentityRow extends StatefulWidget {
  final String   label;
  final String   guidance;
  final String   initial;
  final bool     editable;
  final bool     isLast;
  final ValueChanged<String> onChanged;

  const _IdentityRow({
    required this.label,
    required this.guidance,
    required this.initial,
    required this.editable,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  State<_IdentityRow> createState() => _IdentityRowState();
}

class _IdentityRowState extends State<_IdentityRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + guidance in a fixed-width column
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted, fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 4),
                Text(widget.guidance, style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted, fontSize: 9, height: 1.4,
                )),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Value — editable or read-only
          Expanded(
            child: widget.editable
                ? TextField(
                    controller: _ctrl,
                    onChanged: widget.onChanged,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.inputBR,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputBR,
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputBR,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(widget.initial, style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    )),
                  ),
          ),
        ],
      ),
    );
  }
}