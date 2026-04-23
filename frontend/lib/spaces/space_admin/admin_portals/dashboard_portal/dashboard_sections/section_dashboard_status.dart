// lib/spaces/space_admin/admin_portals/dashboard_portal/dashboard_sections/section_dashboard_status.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Extracted from screen_admin_overview. Phase badge +
//             status rows for branch, last completed, next milestone, MVP date.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../layout_dashboard_config.dart';

class SectionDashboardStatus extends StatelessWidget {
  const SectionDashboardStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              kDashCurrentPhase,
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StatusRow(label: 'Active Branch',   value: kDashActiveBranch),
          _StatusRow(label: 'Last Completed',  value: kDashLastCompleted),
          _StatusRow(label: 'Next Milestone',  value: kDashNextMilestone),
          _StatusRow(label: 'MVP Target',      value: kDashMvpDate),
          _StatusRow(label: 'Sprint Progress', value: kDashWeek),
          _StatusRow(label: 'First Template',  value: kDashSuiteTarget, isLast: true),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _StatusRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(label, style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted, fontWeight: FontWeight.w600,
                )),
              ),
              Expanded(
                child: Text(value, style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                )),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}