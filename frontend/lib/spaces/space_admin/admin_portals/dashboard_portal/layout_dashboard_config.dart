// lib/spaces/space_admin/admin_portals/dashboard_portal/layout_dashboard_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. All tunable layout and copy values for the dashboard portal.
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double kDashPagePad    = 32.0;
const double kDashMaxWidth   = 880.0;
const double kDashSectionGap = 36.0;
const double kDashKpiWidth   = 180.0;
const double kDashKpiHeight  = 100.0;

// ── Copy ──────────────────────────────────────────────────────────────────────
const String kDashTitle    = 'Dashboard';
const String kDashSubtitle = 'Project status, phase, and key metrics at a glance.';

// ── Project status snapshot ───────────────────────────────────────────────────
// TODO: replace with a provider call once the API layer is live (Cycle 3).
const String kDashCurrentPhase  = 'Pre-Cycle 0 · Week 7 — Auth Flow Complete';
const String kDashActiveBranch  = 'feature/auth-flow → merge pending into main';
const String kDashLastCompleted =
    'Auth flow (17 files, 2 adapters, 3 screens, GoRouter guards). '
    'Canon v2.2.0 (Nested Sub-Spaces) locked. Admin portal architecture implemented.';
const String kDashNextMilestone =
    'Merge auth + style → Canon migration (QPScreen rename) → merge engine → package skeleton';
const String kDashSuiteTarget = 'Beacon: Brochure (Cycle 1)';
const String kDashMvpDate     = 'May 15, 2026';
const String kDashWeek        = 'Week 7 / 16';