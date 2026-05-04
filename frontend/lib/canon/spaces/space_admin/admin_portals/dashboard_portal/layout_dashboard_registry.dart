// lib/spaces/space_admin/admin_portals/dashboard_portal/layout_dashboard_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Defines the ordered section list for the dashboard portal.
//             ShellDashboardRoot renders these in a single scrollable column.
// ─────────────────────────────────────────────────────────────────────────────

import '../../admin_model/admin_portal_model.dart';
import 'dashboard_sections/section_dashboard_status.dart';
import 'dashboard_sections/section_dashboard_kpis.dart';
import 'dashboard_sections/section_dashboard_quickactions.dart';

// Order here = render order in the dashboard scroll view.
final List<AdminSectionEntry> kDashboardSections = const [

  AdminSectionEntry(
    id:      'status',
    label:   'Current Status',
    section: SectionDashboardStatus(),
  ),

  AdminSectionEntry(
    id:      'kpis',
    label:   'Key Metrics',
    section: SectionDashboardKpis(),
  ),

  AdminSectionEntry(
    id:      'quickactions',
    label:   'Quick Actions',
    section: SectionDashboardQuickActions(),
  ),

];