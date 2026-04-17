// lib/experience/spaces/space_admin/screens/screen_admin_overview.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — project status dashboard for space_admin. Read-only.
//     Shows phase, branch, KPI cards, admin plane diagram, and quick actions.
//     No backend yet — all data is hardcoded from the current project canvas.
//     Replace static values with provider calls once the API layer is live.
// ─────────────────────────────────────────────────────────────────────────────
//
// This screen is read-only. It never writes to the manifest or content store.
// Its job is to surface the current state of the project at a glance.

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kPagePad      = 32.0;
const double _kMaxWidth     = 880.0;
const double _kKpiCardWidth = 180.0;
const double _kKpiCardH     = 100.0;
const double _kSectionGap   = 36.0;

// ── Copy — project status snapshot ───────────────────────────────────────────
// Update these as the project progresses. Full provider integration Cycle 3.
const String _kCurrentPhase  = 'Pre-Cycle 0 · Week 7';
const String _kActiveBranch  = 'feature/style-system → merge pending';
const String _kLastCompleted = 'Style system + Canon v2.0.0 + all lint errors fixed';
const String _kNextMilestone = 'Merge → QPScreen rename → merge engine → package skeleton';
const String _kSuiteTarget   = 'Beacon: Brochure (Cycle 1)';
const String _kMvpDate       = 'May 15, 2026';
const String _kCurrentWeek   = 'Week 7 / 16';

// ── KPI data — snapshot values ────────────────────────────────────────────────
// (label, current, target, color)
const _kKpis = [
  ('Customers',   '0',       '1–3 pilots',  Color(0xFF9933FF)),
  ('MRR',         'KES 0',   'KES 10K',     Color(0xFF22D3EE)),
  ('Templates',   '0',       '1',           Color(0xFF00E676)),
  ('Admin Live',  'Cycle 3+','Cycle 3',     Color(0xFFFFB300)),
];

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


class ScreenAdminOverview extends StatelessWidget {
  const ScreenAdminOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kPagePad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  title: 'Overview',
                  subtitle: 'Project status, phase, and key metrics at a glance.',
                ),
                const SizedBox(height: _kSectionGap),

                // Current status card
                _AdminSection(
                  label: 'Current Status',
                  child: _StatusCard(),
                ),
                const SizedBox(height: _kSectionGap),

                // KPI row
                _AdminSection(
                  label: 'Key Metrics',
                  child: _KpiRow(),
                ),
                const SizedBox(height: _kSectionGap),

                // Two-plane architecture reminder
                _AdminSection(
                  label: 'Architecture',
                  child: _ArchitectureDiagram(),
                ),
                const SizedBox(height: _kSectionGap),

                // Quick navigation links to other admin screens
                _AdminSection(
                  label: 'Quick Actions',
                  child: _QuickActions(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _StatusCard — current phase, branch, last done, next up
// ─────────────────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
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
              _kCurrentPhase,
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StatusRow(label: 'Active Branch',   value: _kActiveBranch),
          _StatusRow(label: 'Last Completed',  value: _kLastCompleted),
          _StatusRow(label: 'Next Milestone',  value: _kNextMilestone),
          _StatusRow(label: 'MVP Target',      value: _kMvpDate),
          _StatusRow(label: 'Sprint Progress', value: _kCurrentWeek),
          _StatusRow(label: 'First Template',  value: _kSuiteTarget, isLast: true),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _StatusRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

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
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _KpiRow — 4 KPI cards in a horizontal wrap
// ─────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
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
  final Color color;

  const _KpiCard({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kKpiCardWidth,
      height: _kKpiCardH,
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
              Text(
                'target: $target',
                style: AppTypography.caption.copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ArchitectureDiagram — simplified two-plane overview
// ─────────────────────────────────────────────────────────────────────────────

class _ArchitectureDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Plane(
            title: 'Rendering Plane',
            color: AppColors.primary,
            items: const [
              'space_value',
              'space_system',
              'space_auxiliary',
              '↓',
              'QPScreen → Sections → Blocks',
              '↓',
              'Rendered by BrandConfig + AppTheme',
            ],
          )),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.sync_alt, color: AppColors.textMuted, size: 20),
              const SizedBox(height: 4),
              Text('edit', style: AppTypography.caption.copyWith(fontSize: 9)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(child: _Plane(
            title: 'Control Plane',
            color: const Color(0xFF22D3EE),
            items: const [
              'space_admin ← HERE',
              'screen_admin_overview',
              'screen_admin_brand',
              'screen_admin_features',
              '↓',
              'Writes overlay.json',
              '↓ merge_engine ↓',
              'Re-renders public UX',
            ],
            highlight: true,
          )),
        ],
      ),
    );
  }
}

class _Plane extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> items;
  final bool highlight;

  const _Plane({
    required this.title,
    required this.color,
    required this.items,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: highlight ? 0.35 : 0.20)),
        borderRadius: AppRadius.cardBR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              item,
              style: AppTypography.caption.copyWith(
                color: item.startsWith('↓') || item.startsWith('←')
                    ? color.withValues(alpha: 0.6)
                    : AppColors.textSecondary,
                fontSize: 10,
                fontStyle: item.startsWith('↓') ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          )),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _QuickActions — shortcuts to the other admin screens
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _QuickAction(
          icon: Icons.palette_outlined,
          label: 'View Brand Tokens',
          // Nav to Brand tab — user switches manually since we use IndexedStack
          onTap: () => _showInfo(context, 'Switch to the Brand tab in the sidebar.'),
        ),
        _QuickAction(
          icon: Icons.tune_outlined,
          label: 'Edit Dev Screen',
          onTap: () => _showInfo(context, 'Switch to the Features tab to control space_dev screens.'),
        ),
        _QuickAction(
          icon: Icons.open_in_new_outlined,
          label: 'GitHub Canvas',
          onTap: () => _showInfo(context, 'Open the project canvas from your file system.'),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surfaceLit,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.cardBR,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Shared layout helpers (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _AdminSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _AdminSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.overline,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}