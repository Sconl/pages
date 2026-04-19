// lib/core/nav/nav_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Master nav config: all tunable values + NavTemplate
//             system for per-client variation without code duplication.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW THIS FILE WORKS
// ─────────────────────────────────────────────────────────────────────────────
//   1. Every measurement, duration, colour tint, and label lives here as a
//      named constant — nothing hardcoded inside widget files.
//   2. QNavTemplate is the variation handle. Pass a different template to
//      QAppNavShell / QMarketingNav / QAdminNav and the entire nav family
//      changes personality. The default is kNavTemplateDefault.
//   3. client_config.dart picks which template to use. Zero widget code
//      changes between clients.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

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
const double kNavElementHeight      = 40.0;   // interactive element height inside bar
const double kNavHPad               = 32.0;   // horizontal page padding for marketing bar
const double kNavSideZoneWidth      = 220.0;  // logo zone AND cta zone — keeps center links centred
const double kNavItemSpacing        = 28.0;   // gap between desktop marketing nav links
const double kNavCtaProfileGap      = 10.0;   // gap between CTA button and profile circle
const double kNavAdminSidebarW      = 240.0;  // admin sidebar width (fixed, no collapse)
const double kNavAdminTopStripH     = 56.0;   // admin top strip height (tab + breadcrumb)
const double kNavAdminItemH         = 44.0;   // admin nav item row height
const double kNavAdminItemRadius    = 10.0;   // admin nav item corner radius

// ── Durations ──
const Duration kNavSidebarAnim      = Duration(milliseconds: 240); // sidebar expand/collapse
const Duration kNavMenuAnim         = Duration(milliseconds: 200); // mobile menu slide
const Duration kNavHoverAnim        = Duration(milliseconds: 120); // hover state fade

// ── Scroll ──
const double kNavFrostThreshold     = 20.0; // scroll px before frosted glass activates

// ── Bottom nav ──
const double kNavBottomItemVPad     = 10.0;
const double kNavBottomItemHPad     = 12.0;
const double kNavBottomLabelSize    = 10.0;

// ── Mobile menu ──
const double kNavMobileItemH        = 48.0;
const double kNavMobileCtaH         = 52.0;
const double kNavMobileMenuVPad     = 20.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// QNavTemplate
// ─────────────────────────────────────────────────────────────────────────────
//
// Structural + aesthetic variation handle for the entire nav family.
// Each template describes *how* the nav looks and behaves — not which routes
// it shows. Routes are always injected via QNavItem lists.
//
// Add new templates here and pass them via client_config.dart. No widget code
// changes between clients.

enum QNavVariant {
  /// Full sidebar with expand/collapse + user tile at bottom (default for apps)
  sidebarFull,

  /// Sidebar icon-only — always collapsed, no toggle, best for power-user tools
  sidebarCompact,

  /// No sidebar at all on desktop — top strip only (marketing/portal pattern)
  topStripOnly,

  /// Admin-style: fixed sidebar with group headers, no user tile
  adminSidebar,
}

enum QNavActiveStyle {
  /// Tinted pill background (default)
  pill,

  /// Left-edge accent bar only
  accentBar,

  /// Bottom border on top nav items
  underline,
}

class QNavTemplate {
  /// Which structural variant to use for the authenticated shell on wide screens.
  final QNavVariant variant;

  /// How the active item is highlighted.
  final QNavActiveStyle activeStyle;

  /// Whether to show the user tile at the bottom of the sidebar.
  final bool showUserTile;

  /// Whether the sidebar is collapsible (toggle button shown).
  final bool collapsible;

  /// Whether to start collapsed.
  final bool startsCollapsed;

  /// Whether the marketing nav uses a frosted-glass scroll effect.
  final bool marketingFrost;

  /// Whether the marketing bar shows a floating pill outline at rest.
  final bool marketingFloating;

  /// Active indicator dot on sidebar items (tiny dot at the right end of the row).
  final bool showActiveDot;

  /// Whether the admin nav shows group-level section headers.
  final bool adminShowGroupHeaders;

  const QNavTemplate({
    this.variant              = QNavVariant.sidebarFull,
    this.activeStyle          = QNavActiveStyle.pill,
    this.showUserTile         = true,
    this.collapsible          = true,
    this.startsCollapsed      = false,
    this.marketingFrost       = true,
    this.marketingFloating    = false,
    this.showActiveDot        = true,
    this.adminShowGroupHeaders = true,
  });

  // Quick copy-with for one-off overrides without defining a whole new template.
  QNavTemplate copyWith({
    QNavVariant? variant,
    QNavActiveStyle? activeStyle,
    bool? showUserTile,
    bool? collapsible,
    bool? startsCollapsed,
    bool? marketingFrost,
    bool? marketingFloating,
    bool? showActiveDot,
    bool? adminShowGroupHeaders,
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

/// Standard app nav — collapsible sidebar, pill active style, user tile.
/// This is the default. Most clients use this as-is.
const QNavTemplate kNavTemplateDefault = QNavTemplate();

/// Minimal app nav — icon sidebar only, no user tile, no toggle.
/// Good for dense productivity tools where screen real estate matters.
const QNavTemplate kNavTemplateCompact = QNavTemplate(
  variant:        QNavVariant.sidebarCompact,
  showUserTile:   false,
  collapsible:    false,
  startsCollapsed: true,
  showActiveDot:  false,
);

/// Portal / SaaS — top-strip-only on desktop, no sidebar.
/// Use when the content IS the nav (tab-based navigation pattern).
const QNavTemplate kNavTemplatePortal = QNavTemplate(
  variant:     QNavVariant.topStripOnly,
  showUserTile: false,
  collapsible:  false,
);

/// Accent-bar style — left edge highlight instead of pill background.
/// Clean, editorial feel — suits portfolio or agency suites.
const QNavTemplate kNavTemplateAccent = QNavTemplate(
  activeStyle:   QNavActiveStyle.accentBar,
  showActiveDot: false,
);

/// Admin control plane nav — fixed sidebar, group headers, no user tile.
/// Used by QAdminNav. Deliberately separate from the public shell templates.
const QNavTemplate kNavTemplateAdmin = QNavTemplate(
  variant:               QNavVariant.adminSidebar,
  showUserTile:          false,
  collapsible:           false,
  showActiveDot:         false,
  adminShowGroupHeaders:  true,
);