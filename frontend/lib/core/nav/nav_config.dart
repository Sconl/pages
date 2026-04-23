// lib/core/nav/nav_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Master nav config: all tunable values + QNavTemplate
//             system for per-client variation without code duplication.
//   v1.0.1 — Removed unused flutter/material.dart import. QNavTemplate is
//             pure Dart — no Flutter types needed here.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW THIS FILE WORKS
// ─────────────────────────────────────────────────────────────────────────────
//   1. Every measurement, duration, and layout constant lives here as a named
//      constant — nothing hardcoded inside widget files.
//   2. QNavTemplate is the variation handle. Pass a different template to
//      QAppNavShell / QMarketingNav / QAdminNav and the entire nav family
//      changes personality. The default is kNavTemplateDefault.
//   3. client_config.dart picks which template to use. Zero widget code
//      changes between clients.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const double kNavSidebarBreak       = 1100.0; // px — sidebar vs drawer switchover
const double kNavMarketingBreak     = 800.0;  // px — marketing desktop vs mobile
const double kNavSidebarExpanded    = 232.0;  // sidebar open width
const double kNavSidebarCollapsed   = 72.0;   // sidebar icon-only width
const double kNavItemHeight         = 48.0;   // every nav row is exactly this tall
const double kNavItemRadius         = 12.0;   // corner radius on nav row highlight
const double kNavBarHeightMarketing = 72.0;   // total height of floating marketing bar
const double kNavElementHeight      = 40.0;   // interactive element height inside the bar
const double kNavHPad               = 32.0;   // horizontal page padding for marketing bar
const double kNavSideZoneWidth      = 220.0;  // logo zone AND cta zone — keeps center links centred
const double kNavItemSpacing        = 28.0;   // gap between desktop marketing nav links
const double kNavCtaProfileGap      = 10.0;   // gap between CTA button and profile circle
const double kNavAdminSidebarW      = 240.0;  // admin sidebar width (fixed, no collapse)
const double kNavAdminTopStripH     = 56.0;   // admin top strip height
const double kNavAdminItemH         = 44.0;   // admin nav item row height
const double kNavAdminItemRadius    = 10.0;   // admin nav item corner radius

// ── Durations ──
const Duration kNavSidebarAnim = Duration(milliseconds: 240); // sidebar expand/collapse
const Duration kNavMenuAnim    = Duration(milliseconds: 200); // mobile menu slide
const Duration kNavHoverAnim   = Duration(milliseconds: 120); // hover state fade

// ── Scroll ──
const double kNavFrostThreshold = 20.0; // scroll px before frosted glass activates

// ── Bottom nav ──
const double kNavBottomItemVPad  = 10.0;
const double kNavBottomItemHPad  = 12.0;
const double kNavBottomLabelSize = 10.0;

// ── Mobile menu ──
const double kNavMobileItemH    = 48.0;
const double kNavMobileCtaH     = 52.0;
const double kNavMobileMenuVPad = 20.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// QNavVariant / QNavActiveStyle
// ─────────────────────────────────────────────────────────────────────────────

enum QNavVariant {
  /// Full sidebar with expand/collapse + user tile at bottom (default for apps).
  sidebarFull,

  /// Sidebar icon-only — always collapsed, no toggle, best for power-user tools.
  sidebarCompact,

  /// No sidebar at all on desktop — top strip only (portal pattern).
  topStripOnly,

  /// Fixed sidebar with group headers, no user tile — control plane only.
  adminSidebar,
}

enum QNavActiveStyle {
  /// Tinted pill background (default).
  pill,

  /// Left-edge accent bar only — no background fill.
  accentBar,

  /// Bottom border on top-strip nav items.
  underline,
}

// ─────────────────────────────────────────────────────────────────────────────
// QNavTemplate
// ─────────────────────────────────────────────────────────────────────────────
//
// One template covers the entire nav family (shell + marketing + admin).
// Swap this in client_config.dart — zero widget changes between clients.

class QNavTemplate {
  final QNavVariant     variant;
  final QNavActiveStyle activeStyle;
  final bool            showUserTile;
  final bool            collapsible;
  final bool            startsCollapsed;
  final bool            marketingFrost;
  final bool            marketingFloating;
  final bool            showActiveDot;
  final bool            adminShowGroupHeaders;

  const QNavTemplate({
    this.variant               = QNavVariant.sidebarFull,
    this.activeStyle           = QNavActiveStyle.pill,
    this.showUserTile          = true,
    this.collapsible           = true,
    this.startsCollapsed       = false,
    this.marketingFrost        = true,
    this.marketingFloating     = false,
    this.showActiveDot         = true,
    this.adminShowGroupHeaders = true,
  });

  QNavTemplate copyWith({
    QNavVariant?     variant,
    QNavActiveStyle? activeStyle,
    bool?            showUserTile,
    bool?            collapsible,
    bool?            startsCollapsed,
    bool?            marketingFrost,
    bool?            marketingFloating,
    bool?            showActiveDot,
    bool?            adminShowGroupHeaders,
  }) => QNavTemplate(
    variant:               variant               ?? this.variant,
    activeStyle:           activeStyle           ?? this.activeStyle,
    showUserTile:          showUserTile          ?? this.showUserTile,
    collapsible:           collapsible           ?? this.collapsible,
    startsCollapsed:       startsCollapsed       ?? this.startsCollapsed,
    marketingFrost:        marketingFrost        ?? this.marketingFrost,
    marketingFloating:     marketingFloating     ?? this.marketingFloating,
    showActiveDot:         showActiveDot         ?? this.showActiveDot,
    adminShowGroupHeaders: adminShowGroupHeaders ?? this.adminShowGroupHeaders,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in Templates
// ─────────────────────────────────────────────────────────────────────────────

/// Standard app nav — collapsible sidebar, pill highlight, user tile.
const QNavTemplate kNavTemplateDefault = QNavTemplate();

/// Icon-only sidebar — no toggle, no user tile. Dense productivity tools.
const QNavTemplate kNavTemplateCompact = QNavTemplate(
  variant:         QNavVariant.sidebarCompact,
  showUserTile:    false,
  collapsible:     false,
  startsCollapsed: true,
  showActiveDot:   false,
);

/// Horizontal top strip on desktop. suite.portal pattern.
const QNavTemplate kNavTemplatePortal = QNavTemplate(
  variant:      QNavVariant.topStripOnly,
  showUserTile: false,
  collapsible:  false,
);

/// Left accent-bar highlight. No pill background. Portfolio / agency suites.
const QNavTemplate kNavTemplateAccent = QNavTemplate(
  activeStyle:   QNavActiveStyle.accentBar,
  showActiveDot: false,
);

/// Admin control plane — fixed sidebar, group headers, no user tile.
const QNavTemplate kNavTemplateAdmin = QNavTemplate(
  variant:               QNavVariant.adminSidebar,
  showUserTile:          false,
  collapsible:           false,
  showActiveDot:         false,
  adminShowGroupHeaders: true,
);