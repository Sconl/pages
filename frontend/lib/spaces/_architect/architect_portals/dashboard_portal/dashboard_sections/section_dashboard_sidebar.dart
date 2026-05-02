// frontend/lib/spaces/_architect/architect_portals/dashboard_portal/dashboard_sections/section_dashboard_sidebar.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Rebuilt using the exact visual language of QSidebarNav from
//                  lib/core/nav/_internal/sidebar_nav.dart. Same constants,
//                  same item dimensions, same active/hover states, same logo
//                  mark, same user tile structure, same collapse affordance.
//                  Data model stays ArchitectSpace (not QNavItem) since this is
//                  a space selector, not a page navigator.
//   • 2026-04-26 — Initial. Custom sidebar.
// ─────────────────────────────────────────────────────────────────────────────
//
// Why not use QSidebarNav directly: QSidebarNav drives page routing via
// QNavItem.route. Here we are selecting a data category (which space to browse),
// not navigating. The data model is different. The visual language is the same.
//
// Constants imported / mirrored from nav_config.dart so if the core nav
// changes its sizing, this sidebar will stay aligned.

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../../../core/nav/nav_config.dart';   // kNavSidebarAnim, kNavItemHeight, kNavItemRadius, kNavSidebarExpanded, kNavSidebarCollapsed
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Copy ───────────────────────────────────────────────────────────────────────
const String _kTitle         = 'Architect';
const String _kSubtitle      = 'Dev System';
const String _kLogoutTooltip = 'Exit architect space';
const String _kCollapseLabel = 'Collapse';
const String _kExpandLabel   = 'Expand';

// ── Badge pill (screen count) ──────────────────────────────────────────────────
const double _kBadgePadH     = 6.0;
const double _kBadgePadV     = 2.0;
const double _kBadgeFontSize = 9.0;
const double _kBadgeRadius   = 8.0;

// ── Logo mark ──────────────────────────────────────────────────────────────────
const double _kLogoMarkSize   = 36.0;
const double _kLogoMarkRadius = 10.0;

// ── Header ─────────────────────────────────────────────────────────────────────
const double _kHeaderPadTop    = 20.0;
const double _kHeaderPadBottom = 20.0;
const double _kHeaderPadLeft   = 16.0;
const double _kHeaderPadRight  = 8.0;

// ── Collapse button ────────────────────────────────────────────────────────────
const double _kCollapseBtnSize   = 30.0;
const double _kCollapseBtnRadius = 8.0;
const double _kCollapseIconSize  = 18.0;

// ── Item ───────────────────────────────────────────────────────────────────────
// Mirrors _SidebarItem active/hover alpha values from sidebar_nav.dart
const double _kItemActiveBg = 0.15;
const double _kItemHoverBg  = 0.08;
const double _kItemIconSize = 20.0;
const double _kItemFontSize = 13.0;
const double _kItemBorderAlpha = 0.25;

// ── Logout ─────────────────────────────────────────────────────────────────────
const double _kLogoutPadV  = 8.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionDashboardSidebar extends StatefulWidget {
  final List<ArchitectSpace> spaces;
  final String               selectedSpaceId;
  final ValueChanged<String> onSpaceSelected;
  final VoidCallback         onLogout;

  const SectionDashboardSidebar({
    super.key,
    required this.spaces,
    required this.selectedSpaceId,
    required this.onSpaceSelected,
    required this.onLogout,
  });

  @override
  State<SectionDashboardSidebar> createState() => _SectionDashboardSidebarState();
}

class _SectionDashboardSidebarState extends State<SectionDashboardSidebar> {
  // Matches QSidebarNav's own expanded state — collapsible by default
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kNavSidebarAnim,
      curve:    Curves.easeInOutCubic,
      width:    _expanded ? kNavSidebarExpanded : kNavSidebarCollapsed,
      decoration: BoxDecoration(
        color:  AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — mirrors _SidebarHeader from sidebar_nav.dart
            _SidebarHeader(
              expanded:  _expanded,
              onToggle:  () => setState(() => _expanded = !_expanded),
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),

            // Space items list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: widget.spaces.map((space) => _SpaceItem(
                  space:      space,
                  isSelected: space.id == widget.selectedSpaceId,
                  expanded:   _expanded,
                  onTap:      () => widget.onSpaceSelected(space.id),
                )).toList(),
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Logout — mirrors _SidebarUserTile structure
            _LogoutTile(
              expanded: _expanded,
              onLogout: widget.onLogout,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarHeader — logo mark + collapse toggle
// Mirrors _SidebarHeader + _LogoMark + _CollapseButton from sidebar_nav.dart
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final bool         expanded;
  final VoidCallback onToggle;

  const _SidebarHeader({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kHeaderPadLeft, _kHeaderPadTop, _kHeaderPadRight, _kHeaderPadBottom,
      ),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (expanded)
            // Full wordmark when open — same as BrandLogo in QSidebarNav
            BrandLogo(fallbackSize: LogoSize.sm)
          else
            // Collapsed: gradient square mark — identical to _LogoMark
            _ArchitectMark(),

          Tooltip(
            message: expanded ? _kCollapseLabel : _kExpandLabel,
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                width:  _kCollapseBtnSize,
                height: _kCollapseBtnSize,
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(_kCollapseBtnRadius),
                  border:       Border.all(color: AppColors.border),
                ),
                child: Icon(
                  expanded
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size:  _kCollapseIconSize,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Architect gradient square — replaces the brand icon mark when collapsed.
// Same size as _LogoMark in sidebar_nav.dart.
class _ArchitectMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:  _kLogoMarkSize,
      height: _kLogoMarkSize,
      decoration: BoxDecoration(
        gradient:     AppGradients.button,
        borderRadius: BorderRadius.circular(_kLogoMarkRadius),
      ),
      child: Center(
        child: Text(
          'A',
          style: AppTypography.h4.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SpaceItem — mirrors _SidebarItem (pill style) from sidebar_nav.dart
// ─────────────────────────────────────────────────────────────────────────────

class _SpaceItem extends StatefulWidget {
  final ArchitectSpace space;
  final bool           isSelected;
  final bool           expanded;
  final VoidCallback   onTap;

  const _SpaceItem({
    required this.space,
    required this.isSelected,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<_SpaceItem> createState() => _SpaceItemState();
}

class _SpaceItemState extends State<_SpaceItem> {
  bool _hovered = false;

  Color get _bg {
    // Pill-style active state — same alpha values as _SidebarItemState._bg
    if (widget.isSelected) return widget.space.accent.withValues(alpha: _kItemActiveBg);
    if (_hovered)          return widget.space.accent.withValues(alpha: _kItemHoverBg);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final isActive  = widget.isSelected;
    final iconColor = isActive ? widget.space.accent : AppColors.textMuted;
    final textColor = isActive ? widget.space.accent : AppColors.textSecondary;

    final tile = MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kNavHoverAnim,
          height:   kNavItemHeight,
          padding:  EdgeInsets.symmetric(
            horizontal: widget.expanded ? 12 : 0,
          ),
          decoration: BoxDecoration(
            color:        _bg,
            borderRadius: BorderRadius.circular(kNavItemRadius),
            border: isActive
                ? Border.all(
                    color: widget.space.accent.withValues(alpha: _kItemBorderAlpha),
                  )
                : null,
          ),
          child: widget.expanded
              ? Row(children: [
                  Icon(widget.space.icon, color: iconColor, size: _kItemIconSize),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.space.label,
                      style: AppTypography.h5.copyWith(
                        fontSize:   _kItemFontSize,
                        color:      textColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Screen count badge — only shown when screens exist
                  if (widget.space.screens.isNotEmpty)
                    Container(
                      margin:  const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: _kBadgePadH,
                        vertical:   _kBadgePadV,
                      ),
                      decoration: BoxDecoration(
                        gradient:     isActive ? AppGradients.button : null,
                        color:        isActive
                            ? null
                            : widget.space.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(_kBadgeRadius),
                      ),
                      child: Text(
                        '${widget.space.screens.length}',
                        style: AppTypography.caption.copyWith(
                          color:    isActive
                              ? AppColors.onPrimary
                              : widget.space.accent,
                          fontSize: _kBadgeFontSize,
                        ),
                      ),
                    ),
                ])
              : Center(
                  child: Icon(widget.space.icon, color: iconColor, size: 22),
                ),
        ),
      ),
    );

    // Tooltip only when collapsed — same pattern as _SidebarItem
    return widget.expanded
        ? tile
        : Tooltip(
            message:     widget.space.label,
            preferBelow: false,
            child:       tile,
          );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LogoutTile — mirrors _SidebarUserTile structure from sidebar_nav.dart
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutTile extends StatefulWidget {
  final bool         expanded;
  final VoidCallback onLogout;

  const _LogoutTile({required this.expanded, required this.onLogout});

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _kLogoutTooltip,
      child: MouseRegion(
        cursor:  SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onLogout,
          child: AnimatedContainer(
            duration: kNavHoverAnim,
            color: _hovered
                ? AppColors.error.withValues(alpha: 0.06)
                : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: widget.expanded ? 16 : 0,
              vertical:   _kLogoutPadV,
            ),
            child: widget.expanded
                ? Row(children: [
                    Icon(
                      Icons.logout_rounded,
                      size:  _kItemIconSize,
                      color: _hovered ? AppColors.error : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Exit',
                      style: AppTypography.h5.copyWith(
                        fontSize: _kItemFontSize,
                        color: _hovered ? AppColors.error : AppColors.textMuted,
                      ),
                    ),
                  ])
                : Center(
                    child: Icon(
                      Icons.logout_rounded,
                      size:  22,
                      color: _hovered ? AppColors.error : AppColors.textMuted,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}