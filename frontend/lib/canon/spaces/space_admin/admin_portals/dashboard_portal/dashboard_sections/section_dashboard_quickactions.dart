// lib/spaces/space_admin/admin_portals/dashboard_portal/dashboard_sections/section_dashboard_quickactions.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Architecture diagram (Canon v2.2.0, portal layer shown)
//             + quick action chips. Extracted from screen_admin_overview.
//             Quick actions now open the preview panel via AdminPanelControllerScope.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../../core/style/app_style.dart';
import '../../../admin_views/admin_widgets/admin_preview_panel.dart';

class SectionDashboardQuickActions extends StatelessWidget {
  const SectionDashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Architecture diagram
        _ArchitectureDiagram(),
        const SizedBox(height: 24),

        // Quick actions
        Text('QUICK ACTIONS', style: AppTypography.overline),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _QuickAction(
              icon:  Icons.palette_outlined,
              label: 'Brand Preview',
              onTap: () => AdminPanelControllerScope.of(context).open(),
            ),
            _QuickAction(
              icon:  Icons.tune_outlined,
              label: 'Dev Screen Controls',
              onTap: () => _snack(context, 'Switch to the Features tab.'),
            ),
            _QuickAction(
              icon:  Icons.open_in_new_outlined,
              label: 'GitHub Canvas',
              onTap: () => _snack(context, 'Open the project canvas from your file system.'),
            ),
          ],
        ),
      ],
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.surfaceLit,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
    ));
  }
}

class _ArchitectureDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ARCHITECTURE — CANON v2.2.0', style: AppTypography.overline),
          const SizedBox(height: 12),
          // Auth layer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
              borderRadius: AppRadius.smBR,
            ),
            child: Text(
              'AUTH LAYER — space_auth (cross-cutting) · AuthPort → QAuthSession → GoRouter guards',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Plane(
                title: 'Rendering Plane',
                color: AppColors.primary,
                items: const [
                  'space_value',
                  '  └ space_home (sub-space)',
                  'space_system',
                  'space_auxiliary',
                  '↓',
                  'QPScreen → Section → Block',
                  'BrandConfig + AppTheme',
                ],
              )),
              const SizedBox(width: 16),
              Column(
                children: [
                  const SizedBox(height: 28),
                  Icon(Icons.sync_alt, color: AppColors.textMuted, size: 18),
                  const SizedBox(height: 2),
                  Text('edit', style: AppTypography.caption.copyWith(fontSize: 9)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(child: _Plane(
                title: 'Control Plane',
                color: const Color(0xFF22D3EE),
                highlight: true,
                items: const [
                  'space_admin ← HERE',
                  '  admin_portals/',
                  '  dashboard / brand',
                  '  features / settings',
                  '↓',
                  'AdminBrandDraft → overlay.json',
                  '↓ merge_engine ↓ public UX',
                ],
              )),
            ],
          ),
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
  const _Plane({required this.title, required this.color, required this.items, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: highlight ? 0.35 : 0.20)),
        borderRadius: AppRadius.cardBR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption.copyWith(
            color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5,
          )),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(item, style: AppTypography.caption.copyWith(
              color: item.startsWith('↓') ? color.withValues(alpha: 0.6) : AppColors.textSecondary,
              fontSize: 10,
              fontStyle: item.startsWith('↓') ? FontStyle.italic : FontStyle.normal,
            )),
          )),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

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
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}