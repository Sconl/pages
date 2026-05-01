// frontend/lib/spaces/space_architect/architect_portals/dashboard_portal/layout_dashboard_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Section widget container for the dashboard portal.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

/// Pre-built section widgets passed into the dashboard template.
/// The shell builds these; the template arranges them.
class DashboardPortalSections {
  final Widget? sidebar;
  final Widget? grid;

  const DashboardPortalSections({
    this.sidebar,
    this.grid,
  });
}