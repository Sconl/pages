// lib/core/nav/app_nav_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QAppNavShell — project-agnostic authenticated nav shell.
//             Handles sidebar / drawer / bottom / topStrip modes. All three
//             QNavTemplate variation families (sidebarFull, sidebarCompact,
//             topStripOnly) render from this single widget.
// ─────────────────────────────────────────────────────────────────────────────
//
// USAGE (inside app_router.dart — route builder):
// ─────────────────────────────────────────────────────────────────────────────
//   QAppNavShell(
//     currentRoute : state.uri.path,
//     items        : kUserNavItems,        // your QNavItem list
//     template     : kNavTemplateDefault,  // or whatever the client config picks
//     onNavigate   : (route) => context.go(route),
//     userProfile  : QNavUserProfile(displayName: session.displayName),
//     child        : child,
//   )
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import 'nav_config.dart';
import 'nav_item.dart';
import 'nav_mode.dart';
import 'nav_scope.dart';
import '_internal/sidebar_nav.dart';
import '_internal/drawer_nav.dart';
import '_internal/bottom_nav.dart';
import '_internal/top_strip_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QAppNavShell
// ─────────────────────────────────────────────────────────────────────────────

class QAppNavShell extends StatefulWidget {
  /// The currently active route path — used to highlight the active item.
  final String currentRoute;

  /// Flat list of nav destinations. The order here is the order they appear.
  final List<QNavItem> items;

  /// Visual + structural template. Defaults to kNavTemplateDefault.
  final QNavTemplate template;

  /// Called when a nav item is tapped. Usually `context.go(route)`.
  /// The shell doesn't import go_router — the caller wires this.
  final void Function(String route) onNavigate;

  /// User identity for the user tile at the bottom of the sidebar.
  /// Ignored if template.showUserTile == false.
  final QNavUserProfile? userProfile;

  /// The page content — displayed to the right of (or below) the nav.
  final Widget child;

  const QAppNavShell({
    super.key,
    required this.currentRoute,
    required this.items,
    required this.onNavigate,
    required this.child,
    this.template    = kNavTemplateDefault,
    this.userProfile,
  });

  @override
  State<QAppNavShell> createState() => _QAppNavShellState();
}

class _QAppNavShellState extends State<QAppNavShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Start expanded or collapsed based on the template.
  // We track it locally — no global state needed, this is pure UI.
  late bool _sidebarExpanded;

  @override
  void initState() {
    super.initState();
    _sidebarExpanded = !widget.template.startsCollapsed;
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _toggleSidebar() {
    // No-op if this template isn't collapsible.
    if (!widget.template.collapsible) return;
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }

  void _navigate(BuildContext ctx, String route) {
    // Don't re-navigate to the current route — avoids unnecessary rebuilds.
    if (route == widget.currentRoute) {
      // If the drawer is open, still close it.
      if (_scaffoldKey.currentState?.isDrawerOpen == true) {
        Navigator.of(ctx).pop();
      }
      return;
    }
    widget.onNavigate(route);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(ctx).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = QNavModeResolver.resolve(context, widget.template.variant);

    return QNavScope(
      mode:            mode,
      openDrawer:      _openDrawer,
      sidebarExpanded: _sidebarExpanded,
      toggleSidebar:   _toggleSidebar,
      template:        widget.template,
      child: _buildScaffold(context, mode),
    );
  }

  Widget _buildScaffold(BuildContext context, QNavMode mode) {
    switch (mode) {
      case QNavMode.sidebar:
        return Scaffold(
          key:             _scaffoldKey,
          backgroundColor: AppColors.background,
          body: Row(children: [
            QSidebarNav(
              items:           widget.items,
              currentRoute:    widget.currentRoute,
              template:        widget.template,
              expanded:        _sidebarExpanded,
              userProfile:     widget.userProfile,
              onToggle:        _toggleSidebar,
              onTap:           (r) => _navigate(context, r),
            ),
            Expanded(child: widget.child),
          ]),
        );

      case QNavMode.drawer:
        return Scaffold(
          key:             _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: Drawer(
            backgroundColor: AppColors.surface,
            width:           kNavSidebarExpanded,
            child: QDrawerNav(
              items:        widget.items,
              currentRoute: widget.currentRoute,
              template:     widget.template,
              userProfile:  widget.userProfile,
              onTap:        (r) => _navigate(context, r),
            ),
          ),
          body: widget.child,
        );

      case QNavMode.bottom:
        return Scaffold(
          key:                  _scaffoldKey,
          backgroundColor:      AppColors.background,
          body:                 widget.child,
          bottomNavigationBar:  QBottomNav(
            items:        widget.items,
            currentRoute: widget.currentRoute,
            template:     widget.template,
            onTap:        (r) => _navigate(context, r),
          ),
        );

      case QNavMode.topStrip:
        return Scaffold(
          key:             _scaffoldKey,
          backgroundColor: AppColors.background,
          body: Column(children: [
            QTopStripNav(
              items:        widget.items,
              currentRoute: widget.currentRoute,
              template:     widget.template,
              onTap:        (r) => _navigate(context, r),
            ),
            Expanded(child: widget.child),
          ]),
        );
    }
  }
}