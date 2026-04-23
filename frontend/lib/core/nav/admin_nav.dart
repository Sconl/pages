// lib/core/nav/admin_nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QAdminNav — fixed admin sidebar + top breadcrumb strip.
//   v1.0.1 — Fixed: `if (trailing != null) trailing!` →  null-aware element
//             `trailing?` per use_null_aware_elements lint rule.
// ─────────────────────────────────────────────────────────────────────────────
//
// Separate from QAppNavShell by design — the control plane has its own layout
// contract: no collapse, group headers, breadcrumb strip. Slides to a drawer
// on narrow screens (admins use a browser, no bottom bar).

import 'package:flutter/material.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import 'nav_config.dart';
import 'nav_item.dart';
import 'nav_mode.dart';
import 'nav_scope.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QAdminNav
// ─────────────────────────────────────────────────────────────────────────────

class QAdminNav extends StatefulWidget {
  /// Grouped nav items — the admin sidebar organises by section.
  /// Pass a single QNavGroup with no header if grouping isn't needed.
  final List<QNavGroup> groups;

  /// Current active route — used to highlight the active item.
  final String currentRoute;

  /// Called when a nav item is tapped.
  final void Function(String route) onNavigate;

  /// Page title shown in the breadcrumb strip.
  final String breadcrumb;

  /// Optional trailing widgets for the top strip (publish button, etc.).
  final Widget? topStripTrailing;

  /// Template — defaults to kNavTemplateAdmin.
  final QNavTemplate template;

  /// The admin page content.
  final Widget child;

  const QAdminNav({
    super.key,
    required this.groups,
    required this.currentRoute,
    required this.onNavigate,
    required this.breadcrumb,
    required this.child,
    this.topStripTrailing,
    this.template = kNavTemplateAdmin,
  });

  @override
  State<QAdminNav> createState() => _QAdminNavState();
}

class _QAdminNavState extends State<QAdminNav> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigate(BuildContext ctx, String route) {
    if (route == widget.currentRoute) return;
    widget.onNavigate(route);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(ctx).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mode  = width >= kNavSidebarBreak
        ? QNavMode.sidebar
        : QNavMode.drawer;

    return QNavScope(
      mode:            mode,
      openDrawer:      () => _scaffoldKey.currentState?.openDrawer(),
      sidebarExpanded: true, // admin sidebar is always fully expanded
      toggleSidebar:   () {},
      template:        widget.template,
      child:           mode == QNavMode.sidebar
          ? _buildWide(context)
          : _buildNarrow(context),
    );
  }

  Widget _buildWide(BuildContext context) {
    return Scaffold(
      key:             _scaffoldKey,
      backgroundColor: AppColors.background,
      body: Row(children: [
        _AdminSidebar(
          groups:       widget.groups,
          currentRoute: widget.currentRoute,
          template:     widget.template,
          onTap:        (r) => _navigate(context, r),
        ),
        Expanded(
          child: Column(children: [
            _AdminTopStrip(
              breadcrumb: widget.breadcrumb,
              trailing:   widget.topStripTrailing,
            ),
            Expanded(child: widget.child),
          ]),
        ),
      ]),
    );
  }

  Widget _buildNarrow(BuildContext context) {
    return Scaffold(
      key:             _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        width:           kNavAdminSidebarW,
        child: _AdminSidebar(
          groups:       widget.groups,
          currentRoute: widget.currentRoute,
          template:     widget.template,
          onTap:        (r) => _navigate(context, r),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kNavAdminTopStripH),
        child: _AdminTopStrip(
          breadcrumb:     widget.breadcrumb,
          trailing:       widget.topStripTrailing,
          showHamburger:  true,
          onHamburger:    () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AdminSidebar
// ─────────────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final List<QNavGroup>    groups;
  final String             currentRoute;
  final QNavTemplate       template;
  final void Function(String) onTap;

  const _AdminSidebar({
    required this.groups,
    required this.currentRoute,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kNavAdminSidebarW,
      decoration: BoxDecoration(
        color:  AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: BrandLogo(fallbackSize: LogoSize.sm),
            ),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                children: groups.expand((group) => [
                  if (template.adminShowGroupHeaders &&
                      group.header != null)
                    _GroupHeader(label: group.header!),
                  ...group.items.map((item) => _AdminNavItem(
                        item:   item,
                        active: item.route == currentRoute,
                        onTap:  () => onTap(item.route),
                      )),
                  // Spacer between groups but not after the last one
                  if (group != groups.last) const SizedBox(height: 8),
                ]).toList(),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Control Plane',
                style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AdminTopStrip
// ─────────────────────────────────────────────────────────────────────────────

class _AdminTopStrip extends StatelessWidget {
  final String        breadcrumb;
  final Widget?       trailing;
  final bool          showHamburger;
  final VoidCallback? onHamburger;

  const _AdminTopStrip({
    required this.breadcrumb,
    this.trailing,
    this.showHamburger = false,
    this.onHamburger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kNavAdminTopStripH,
      decoration: BoxDecoration(
        color:  AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        if (showHamburger)
          IconButton(
            icon:      const Icon(Icons.menu_rounded),
            color:     AppColors.textMuted,
            iconSize:  20,
            onPressed: onHamburger,
          ),
        Text(
          breadcrumb,
          style: AppTypography.h5.copyWith(
            color:      AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        // Null-aware element — renders nothing when trailing is null,
        // no if-check needed (fixed use_null_aware_elements lint).
        ?trailing,
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GroupHeader
// ─────────────────────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color:         AppColors.textMuted,
          fontSize:      10,
          fontWeight:    FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AdminNavItem
// ─────────────────────────────────────────────────────────────────────────────

class _AdminNavItem extends StatefulWidget {
  final QNavItem     item;
  final bool         active;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  State<_AdminNavItem> createState() => _AdminNavItemState();
}

class _AdminNavItemState extends State<_AdminNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final bg = active
        ? AppColors.primary.withValues(alpha: 0.10)
        : _hovered
            ? AppColors.surface.withValues(alpha: 0.6)
            : Colors.transparent;
    final color = active ? AppColors.primary : AppColors.textSecondary;

    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kNavHoverAnim,
          height:   kNavAdminItemH,
          margin:   const EdgeInsets.only(bottom: 2),
          padding:  const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(kNavAdminItemRadius),
            border: active
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(children: [
            Icon(
              active ? widget.item.resolvedActiveIcon : widget.item.icon,
              size:  18,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.item.label,
                style: AppTypography.body.copyWith(
                  color:      color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  fontSize:   13,
                ),
              ),
            ),
            if (widget.item.badge != null)
              _AdminBadge(label: widget.item.badge!),
          ]),
        ),
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  final String label;
  const _AdminBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color:        AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      AppColors.primary,
            fontSize:   9,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}