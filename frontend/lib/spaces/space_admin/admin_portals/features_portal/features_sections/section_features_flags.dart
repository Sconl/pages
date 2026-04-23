// lib/spaces/space_admin/admin_portals/features_portal/features_sections/section_features_flags.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Read-only display of QSpaceFeatureFlags defaults.
//             Editable version ships Cycle 3. Extracted from screen_admin_features.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../layout_features_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// (label, enabled) — mirrors QSpaceFeatureFlags defaults.
// TODO(Cycle3): replace with live QSpaceFeatureFlags from a provider.
const _kFlags = [
  ('Trial Signup',      true),
  ('Pricing Table',     true),
  ('Testimonials',      true),
  ('Analytics Consent', true),
  ('Dark Mode Toggle',  true),
  ('API Docs',          false),
  ('Blog Section',      false),
  ('Live Chat',         false),
  ('Multi-Language',    false),
];

// ─────────────────────────────────────────────────────────────────────────────

class SectionFeaturesFlags extends StatelessWidget {
  const SectionFeaturesFlags({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
            borderRadius: AppRadius.cardBR,
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.info),
              const SizedBox(width: 10),
              Expanded(
                child: Text(kFeatFlagsNote, style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary, height: 1.5,
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: _kFlags.asMap().entries.map((e) {
              final i    = e.key;
              final flag = e.value;
              return Column(
                children: [
                  _FlagRow(label: flag.$1, enabled: flag.$2),
                  if (i < _kFlags.length - 1) Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FlagRow extends StatelessWidget {
  final String label;
  final bool   enabled;
  const _FlagRow({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16,
            color: enabled ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.body.copyWith(
              fontSize: 13,
              color: enabled ? AppColors.textPrimary : AppColors.textMuted,
            )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.success.withValues(alpha: 0.10)
                  : AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              enabled ? 'ON' : 'OFF',
              style: AppTypography.caption.copyWith(
                color: enabled ? AppColors.success : AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}