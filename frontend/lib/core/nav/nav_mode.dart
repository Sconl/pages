// lib/core/nav/nav_mode.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QNavMode enum + QNavModeResolver. Platform + width logic
//             in one place so neither the shell nor the scope has to care.
// ─────────────────────────────────────────────────────────────────────────────
//
// Platform resolution matrix:
//   Native Android / iOS          → QNavMode.bottom   (always, any size)
//   Web / Desktop ≥ 1100px        → QNavMode.sidebar  (from nav_config.dart)
//   Web / Desktop < 1100px        → QNavMode.drawer
//
// QNavVariant.topStripOnly overrides sidebar → top on desktop.
// QNavVariant.sidebarCompact keeps sidebar but always collapsed.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'nav_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QNavMode
// ─────────────────────────────────────────────────────────────────────────────

enum QNavMode {
  /// Collapsible or icon-only left sidebar (web/desktop wide).
  sidebar,

  /// Hamburger → sliding drawer (web/desktop narrow).
  drawer,

  /// Bottom tab bar (native iOS/Android).
  bottom,

  /// Horizontal top strip / tab row (portal pattern, desktop only).
  topStrip,
}

// ─────────────────────────────────────────────────────────────────────────────
// QNavModeResolver
// ─────────────────────────────────────────────────────────────────────────────

class QNavModeResolver {
  const QNavModeResolver._();

  /// Resolves the correct [QNavMode] for the current platform, screen width,
  /// and the structural [QNavVariant] requested by the active template.
  ///
  /// Call this inside [LayoutBuilder] or [MediaQuery]-aware widgets — not at
  /// the const level. The result changes as the window resizes.
  static QNavMode resolve(BuildContext context, QNavVariant variant) {
    // Native mobile always gets bottom nav — no overrides.
    if (!kIsWeb) {
      final p = defaultTargetPlatform;
      if (p == TargetPlatform.android || p == TargetPlatform.iOS) {
        return QNavMode.bottom;
      }
    }

    final width = MediaQuery.sizeOf(context).width;

    // Below the marketing break, any variant falls back to drawer (hamburger).
    // This ensures even topStripOnly templates degrade gracefully on narrow
    // browser windows — same hamburger as everything else.
    if (width < kNavSidebarBreak) return QNavMode.drawer;

    // Wide screen — variant decides the desktop pattern.
    return switch (variant) {
      QNavVariant.topStripOnly  => QNavMode.topStrip,
      QNavVariant.adminSidebar  => QNavMode.sidebar,   // admin always gets sidebar
      _                         => QNavMode.sidebar,
    };
  }
}