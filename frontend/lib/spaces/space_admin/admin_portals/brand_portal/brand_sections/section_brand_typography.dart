// lib/spaces/space_admin/admin_portals/brand_portal/brand_sections/section_brand_typography.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Five font role rows — each editable TextField + live
//             sample rendering + guidance copy. Uses discardGeneration as a
//             ValueKey so controllers rebuild cleanly when discard fires.
//             Editable gate via QAdminConfigScope.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../../../../../core/admin/admin_brand_draft.dart';
import '../../../../../core/admin/admin_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const double _kFontSampleSize = 20.0;

const Map<String, String> _kFontGuidance = {
  'fontHero':
      'Brand moments — splash screen, hero section wordmark, large display text. '
      'Should feel distinctive and expressive. Only used at large sizes.',
  'fontDisplay':
      'Page and section headings. Clear, authoritative, readable at large sizes. '
      'Used for h1–h4 across all public screens.',
  'fontText':
      'Body copy, buttons, inputs, labels. Your workhorse font — used everywhere. '
      'Prioritize readability and rendering quality across all sizes.',
  'fontAccent':
      'Numbers, statistics, timestamps, technical badges. Monospaced or structured '
      'fonts work best here. Great for data-heavy UI and code samples.',
  'fontSignature':
      'Emotional moments — greetings, milestones, personal messages. Used sparingly '
      'for warmth. Should feel human and personal.',
};

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


class SectionBrandTypography extends StatelessWidget {
  const SectionBrandTypography({super.key});

  @override
  Widget build(BuildContext context) {
    final draft    = AdminBrandDraftScope.of(context);
    final editable = QAdminConfigScope.of(context).accessFor('brand').editable;

    // Key on discardGeneration so the entire section rebuilds (re-initing all
    // controllers) when discard fires — cleaner than managing 5 controllers here.
    return KeyedSubtree(
      key: ValueKey('typo_${draft.discardGeneration}'),
      child: Column(
        children: [
          _FontRow(
            roleKey:   'fontHero',
            label:     'fontHero',
            initial:   draft.draftFontHero,
            sample:    '${draft.draftWordBold}${draft.draftWordLight}',
            editable:  editable,
            onChanged: draft.setFontHero,
          ),
          const SizedBox(height: 10),
          _FontRow(
            roleKey:   'fontDisplay',
            label:     'fontDisplay',
            initial:   draft.draftFontDisplay,
            sample:    'Page Heading',
            editable:  editable,
            onChanged: draft.setFontDisplay,
          ),
          const SizedBox(height: 10),
          _FontRow(
            roleKey:   'fontText',
            label:     'fontText',
            initial:   draft.draftFontText,
            sample:    'Body copy and buttons',
            editable:  editable,
            onChanged: draft.setFontText,
          ),
          const SizedBox(height: 10),
          _FontRow(
            roleKey:   'fontAccent',
            label:     'fontAccent',
            initial:   draft.draftFontAccent,
            sample:    '42,000 · 99.9%',
            editable:  editable,
            onChanged: draft.setFontAccent,
          ),
          const SizedBox(height: 10),
          _FontRow(
            roleKey:   'fontSignature',
            label:     'fontSignature',
            initial:   draft.draftFontSignature,
            sample:    'Welcome back',
            editable:  editable,
            onChanged: draft.setFontSignature,
          ),
        ],
      ),
    );
  }
}


class _FontRow extends StatefulWidget {
  final String   roleKey;
  final String   label;
  final String   initial;
  final String   sample;
  final bool     editable;
  final ValueChanged<String> onChanged;

  const _FontRow({
    required this.roleKey,
    required this.label,
    required this.initial,
    required this.sample,
    required this.editable,
    required this.onChanged,
  });

  @override
  State<_FontRow> createState() => _FontRowState();
}

class _FontRowState extends State<_FontRow> {
  late TextEditingController _ctrl;
  late String _currentFont;

  @override
  void initState() {
    super.initState();
    _currentFont = widget.initial;
    _ctrl        = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
                ),
                child: Text(widget.label, style: AppTypography.caption.copyWith(
                  color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700,
                )),
              ),
              const SizedBox(width: 10),

              // Editable font name — or read-only display
              Expanded(
                child: widget.editable
                    ? TextField(
                        controller: _ctrl,
                        onChanged: (val) {
                          if (val.trim().isNotEmpty) {
                            setState(() => _currentFont = val.trim());
                            widget.onChanged(val.trim());
                          }
                        },
                        style: AppTypography.bodySmall.copyWith(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Font family name',
                          hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(_currentFont,
                        style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Live sample — renders in the active font family
          Text(
            widget.sample,
            style: TextStyle(
              fontFamily: _currentFont,
              fontSize: _kFontSampleSize,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Guidance
          Text(
            _kFontGuidance[widget.roleKey] ?? '',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted, height: 1.5, fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}