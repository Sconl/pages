// lib/spaces/space_admin/admin_portals/dashboard_portal/dashboard_sections/section_dashboard_kpis.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. KPI cards row. Extracted from screen_admin_overview.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';
import '../layout_dashboard_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// KPI data — (label, current, target, color)
// TODO: wire to a provider once API layer is live (Cycle 3).
const _kKpis = [
  ('Customers',  '0',        '1–3 pilots', Color(0xFF9933FF)),
  ('MRR',        'KES 0',    'KES 10K',    Color(0xFF22D3EE)),
  ('Templates',  '0',        '1',          Color(0xFF00E676)),
  ('Admin Live', 'Cycle 3+', 'Cycle 3',    Color(0xFFFFB300)),
];

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionDashboardKpis extends StatelessWidget {
  const SectionDashboardKpis({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _kKpis.map((kpi) => _KpiCard(
        label:   kpi.$1,
        current: kpi.$2,
        target:  kpi.$3,
        color:   kpi.$4,
      )).toList(),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String current;
  final String target;
  final Color  color;

  const _KpiCard({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  kDashKpiWidth,
      height: kDashKpiHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: AppRadius.cardBR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current,
                  style: AppTypography.h3.copyWith(color: color, fontSize: 18)),
              Text('target: $target',
                  style: AppTypography.caption.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}