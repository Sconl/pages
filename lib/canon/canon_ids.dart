// lib/canon/canon_ids.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial — all canonical IDs, Canon v2.1.0. Vocabulary locked.
// ─────────────────────────────────────────────────────────────────────────────

// These are the only IDs that have canonical meaning in the system.
// No file outside lib/canon/ may invent new space, screen, or section IDs.
// If you need a new screen or block, declare it here first.

// ── Spaces ────────────────────────────────────────────────────────────────────

abstract class CanonSpace {
  // 3 public spaces — fixed forever. Canon v2.1.0 locks this.
  // Adding a fourth requires a canon.v3.json revision with explicit rationale.
  static const value     = 'space_value';
  static const system    = 'space_system';
  static const auxiliary = 'space_auxiliary';

  // Privileged meta-space. Sits beside the public 3, not inside them.
  // Not in public QNavBar. Gated by auth + role + tenant scope.
  static const admin = 'space_admin';

  // NOT YET ACTIVE — reserved for Cycle 7+ (Decision 027).
  // Do not reference this in any live code until the decision is revisited.
  static const dev = 'space_dev';
}

// ── Screens ───────────────────────────────────────────────────────────────────

abstract class CanonScreen {
  // 3 required screens per public space (Canon v2.0.0).
  // Suites may add screen_pricing, screen_about, etc. per Canon v2.1.0.
  static const entry   = 'screen_entry';
  static const explore = 'screen_explore';
  static const expand  = 'screen_expand';
}

abstract class CanonAdminScreen {
  // 6 admin screens — control plane only. Never appear in public QNavBar.
  static const overview = 'screen_admin_overview';
  static const content  = 'screen_admin_content';
  static const brand    = 'screen_admin_brand';
  static const assets   = 'screen_admin_assets';
  static const features = 'screen_admin_features';
  static const preview  = 'screen_admin_preview';
}

// ── Sections ─────────────────────────────────────────────────────────────────

abstract class CanonSection {
  // Fixed at 3. Canon v2.1.0. Do not add a fourth.
  // Core → Context → Connect is the universal scroll flow.
  static const core    = 'section_core';
  static const context = 'section_context';
  static const connect = 'section_connect';
}

// ── Blocks ───────────────────────────────────────────────────────────────────

abstract class CanonCoreBlock {
  static const identity = 'core_identity'; // brand identity, app name, tagline
  static const value    = 'core_value';    // core value proposition
  static const action   = 'core_action';   // primary CTA
  // core_trust is ONLY permitted on screen_entry (Canon v2.1.0).
  // Do not add it to screen_explore or screen_expand.
  static const trust    = 'core_trust';
}

abstract class CanonContextBlock {
  static const problem  = 'context_problem';
  static const solution = 'context_solution';
  static const proof    = 'context_proof';
}

abstract class CanonConnectBlock {
  static const offer     = 'connect_offer';
  static const path      = 'connect_path';
  static const extension = 'connect_extension';
}

// ── Roles ────────────────────────────────────────────────────────────────────

enum CanonRole {
  clientAdmin,  // brand tokens, copy, assets, approved feature toggles
  developer,    // + structural field mappings, advanced manifest fields
  architect,    // + schema rules, canonical defaults, permissions config (full access)
}

// ── Suites ───────────────────────────────────────────────────────────────────

abstract class CanonSuite {
  static const saas        = 'saas';        // first to ship
  static const corporate   = 'corporate';
  static const portfolio   = 'portfolio';
  static const agency      = 'agency';
  static const dashboard   = 'dashboard';
  static const portal      = 'portal';
  static const store       = 'store';
  static const marketplace = 'marketplace';
  static const membership  = 'membership';
}
