// lib/core/nav/nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Barrel export for lib/core/nav/.
//             One import line gives everything: config, models, modes,
//             scope, shell, marketing nav, admin nav, shared helpers.
// ─────────────────────────────────────────────────────────────────────────────
//
// USAGE
// ─────────────────────────────────────────────────────────────────────────────
//   import 'package:qspace_pages/core/nav/nav.dart';
//
// That one line exposes:
//   QNavItem, QNavGroup, QNavUserProfile           ← data models
//   QNavTemplate, QNavVariant, QNavActiveStyle      ← template system
//   kNavTemplateDefault, kNavTemplateCompact, ...   ← built-in templates
//   QNavMode, QNavModeResolver                      ← platform resolution
//   QNavScope, QHamburgerButton                     ← scope + helper widget
//   QAppNavShell                                    ← authenticated shell
//   QMarketingNav                                   ← public top nav
//   QAdminNav                                       ← control plane nav
// ─────────────────────────────────────────────────────────────────────────────

export 'nav_config.dart';
export 'nav_item.dart';
export 'nav_mode.dart';
export 'nav_scope.dart';
export 'app_nav_shell.dart';
export 'marketing_nav.dart';
export 'admin_nav.dart';

// _internal widgets are package-private. Do not export them.
// They're imported directly by their consumers inside lib/core/nav/.