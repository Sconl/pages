// frontend/lib/spaces/space_architect/architect_portals/dashboard_portal/layout_dashboard_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Layout config for the architect dashboard portal.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// DashboardSectionVisibility
// ─────────────────────────────────────────────────────────────────────────────

class DashboardSectionVisibility {
  final bool sidebar;  // space selector + logout
  final bool grid;     // screen cards for the selected space

  const DashboardSectionVisibility({
    this.sidebar = true,
    this.grid    = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardLayoutConfig
// ─────────────────────────────────────────────────────────────────────────────

class DashboardLayoutConfig {
  final DashboardSectionVisibility sections;

  const DashboardLayoutConfig({required this.sections});

  static const DashboardLayoutConfig standard = DashboardLayoutConfig(
    sections: DashboardSectionVisibility(),
  );
}