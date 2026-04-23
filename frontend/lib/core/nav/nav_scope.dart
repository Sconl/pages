// lib/core/nav/nav_scope.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QNavScope InheritedWidget + QHamburgerButton.
//   v1.0.1 — Fixed: package:flutter/widgets.dart → material.dart so Icons
//             resolves. Removed const from Icon widget that used Icons (it
//             can't be const when material.dart isn't transitively pulling in
//             the Icons class at compile time via widgets.dart).
// ─────────────────────────────────────────────────────────────────────────────
//
// USAGE
// ─────────────────────────────────────────────────────────────────────────────
//   // Inside any widget that lives below a QAppNavShell or QAdminNav:
//   final nav = QNavScope.of(context);
//   if (nav.mode == QNavMode.drawer) nav.openDrawer();
//   nav.toggleSidebar(); // no-op if template is not collapsible
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'nav_config.dart';
import 'nav_mode.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QNavScope
// ─────────────────────────────────────────────────────────────────────────────

class QNavScope extends InheritedWidget {
  /// Current resolved nav mode — changes with window width / platform.
  final QNavMode mode;

  /// Open the drawer programmatically (no-op if mode != drawer).
  final VoidCallback openDrawer;

  /// Whether the sidebar is currently expanded (only relevant for sidebar mode).
  final bool sidebarExpanded;

  /// Toggle sidebar expand/collapse (no-op if template is not collapsible).
  final VoidCallback toggleSidebar;

  /// The active template — passed down so nested widgets can read variant flags.
  final QNavTemplate template;

  const QNavScope({
    super.key,
    required this.mode,
    required this.openDrawer,
    required this.sidebarExpanded,
    required this.toggleSidebar,
    required this.template,
    required super.child,
  });

  /// Access the nearest QNavScope. Throws a clear message if none found —
  /// that means the widget is outside any shell, which is always a bug.
  static QNavScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<QNavScope>();
    assert(
      scope != null,
      'No QNavScope found in widget tree.\n'
      'Wrap your screen with QAppNavShell, QAdminNav, or QMarketingNav.',
    );
    return scope!;
  }

  /// Nullable variant — use when you're not sure if a shell is in scope.
  static QNavScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QNavScope>();

  @override
  bool updateShouldNotify(QNavScope old) =>
      mode != old.mode ||
      sidebarExpanded != old.sidebarExpanded ||
      template != old.template;
}

// ─────────────────────────────────────────────────────────────────────────────
// QHamburgerButton
// ─────────────────────────────────────────────────────────────────────────────
//
// Drop anywhere inside a screen header. Reads its own scope — no props needed.
// Returns SizedBox.shrink() when mode != drawer so it's always safe to include
// without a conditional at the call site.

class QHamburgerButton extends StatelessWidget {
  const QHamburgerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = QNavScope.maybeOf(context);
    if (scope == null || scope.mode != QNavMode.drawer) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: scope.openDrawer,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          // Raw colours here — this file deliberately has no app_style import
          // so it stays dependency-free. Consumers style their own headers.
          color:        const Color(0xFF1A1025),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: const Color(0x1FFFFFFF)),
        ),
        child: const Icon(
          Icons.menu_rounded,
          size:  18,
          color: Color(0x8AFFFFFF),
        ),
      ),
    );
  }
}