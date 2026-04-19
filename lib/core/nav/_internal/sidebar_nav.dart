// lib/core/nav/_internal/sidebar_nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QSidebarNav — collapsible sidebar for web/desktop.
//             Handles sidebarFull and sidebarCompact template variants.
//             Renders active style (pill / accentBar) from template.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import '../nav_config.dart';
import '../nav_item.dart';
import 'nav_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QSidebarNav
// ─────────────────────────────────────────────────────────────────────────────

class QSidebarNav extends StatelessWidget {
  final List<QNavItem>   items;
  final String           currentRoute;
  final QNavTemplate     template;
  final bool             expanded;
  final QNavUserProfile? userProfile;
  final VoidCallback     onToggle;
  final void Function(String) onTap;

  const QSidebarNav({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.template,
    required this.expanded,
    required this.onToggle,
    required this.onTap,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kNavSidebarAnim,
      curve:    Curves.easeInOutCubic,
      width:    expanded ? kNavSidebarExpanded : kNavSidebarCollapsed,
      decoration: BoxDecoration(
        color:  AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SidebarHeader(
              expanded: expanded,
              collapsible: template.collapsible,
              onToggle: onToggle,
            ),
            _QNavDivider(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                children: items.map((item) => _SidebarItem(
                  item:        item,
                  active:      item.route == currentRoute,
                  expanded:    expanded,
                  template:    template,
                  onTap:       () => onTap(item.route),
                )).toList(),
              ),
            ),
            _QNavDivider(),
            if (template.showUserTile && userProfile != null)
              _SidebarUserTile(
                profile:  userProfile!,
                expanded: expanded,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarHeader — logo + collapse toggle
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final bool expanded;
  final bool collapsible;
  final VoidCallback onToggle;

  const _SidebarHeader({
    required this.expanded,
    required this.collapsible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 20),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (expanded)
            BrandLogo(fallbackSize: LogoSize.sm)
          else
            _LogoMark(),
          if (collapsible)
            _CollapseButton(onToggle: onToggle, expanded: expanded),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        gradient:     AppGradients.button,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          BrandCopy.wordBold[0],
          style: AppTypography.h4.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  final VoidCallback onToggle;
  final bool expanded;
  const _CollapseButton({required this.onToggle, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: expanded ? 'Collapse sidebar' : 'Expand sidebar',
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color:        AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border:       Border.all(color: AppColors.border),
          ),
          child: Icon(
            expanded
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            size:  18,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarItem
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarItem extends StatefulWidget {
  final QNavItem     item;
  final bool         active;
  final bool         expanded;
  final QNavTemplate template;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.active,
    required this.expanded,
    required this.template,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  Color get _bg {
    // accentBar style has no background highlight — bar on the left does the work.
    if (widget.template.activeStyle == QNavActiveStyle.accentBar) {
      return _hovered
          ? AppColors.tint10(AppColors.primary)
          : Colors.transparent;
    }
    // pill style
    if (widget.active) return AppColors.tint10(AppColors.primary) * 1.5;
    if (_hovered)      return AppColors.tint10(AppColors.primary);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final iconColor = active ? AppColors.primary : AppColors.textMuted;
    final textColor = active ? AppColors.primary : AppColors.textSecondary;

    final tile = MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            // Accent bar — only rendered for accentBar activeStyle
            if (widget.template.activeStyle == QNavActiveStyle.accentBar && active)
              Positioned(
                left: 0, top: 8, bottom: 8,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient:     AppGradients.button,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            AnimatedContainer(
              duration: kNavHoverAnim,
              height:   kNavItemHeight,
              padding:  EdgeInsets.symmetric(
                  horizontal: widget.expanded ? 12 : 0),
              decoration: BoxDecoration(
                color:        _bg,
                borderRadius: BorderRadius.circular(kNavItemRadius),
                border: widget.template.activeStyle == QNavActiveStyle.pill && active
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25))
                    : null,
              ),
              child: widget.expanded
                  ? Row(children: [
                      // Leave space for accent bar
                      if (widget.template.activeStyle ==
                          QNavActiveStyle.accentBar)
                        const SizedBox(width: 8),
                      Icon(
                        active
                            ? widget.item.resolvedActiveIcon
                            : widget.item.icon,
                        color: iconColor,
                        size:  20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.item.label,
                          style: AppTypography.h5.copyWith(
                            color:      textColor,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      // Badge
                      if (widget.item.badge != null)
                        _NavBadge(label: widget.item.badge!),
                      // Active dot
                      if (widget.template.showActiveDot && active)
                        _ActiveDot(),
                    ])
                  : Center(
                      child: Icon(
                        active
                            ? widget.item.resolvedActiveIcon
                            : widget.item.icon,
                        color: iconColor,
                        size:  22,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

    return widget.expanded
        ? tile
        : Tooltip(
            message:    widget.item.resolvedTooltip,
            preferBelow: false,
            child:      tile,
          );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarUserTile
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarUserTile extends StatelessWidget {
  final QNavUserProfile profile;
  final bool            expanded;

  const _SidebarUserTile({required this.profile, required this.expanded});

  @override
  Widget build(BuildContext context) {
    final avatar = _NavAvatar(profile: profile);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: expanded ? 16 : 0, vertical: 8),
      child: expanded
          ? Row(children: [
              avatar,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.firstName,
                      style: AppTypography.h5
                          .copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (profile.roleName != null)
                      Text(
                        profile.roleName!,
                        style: AppTypography.caption,
                      ),
                  ],
                ),
              ),
            ])
          : Center(child: avatar),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared internal primitives (also used by drawer_nav.dart)
// ─────────────────────────────────────────────────────────────────────────────

class _QNavDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: AppColors.border);
}

class _ActiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 5, height: 5,
        decoration: BoxDecoration(
          color: AppColors.primary, shape: BoxShape.circle),
      );
}

class _NavBadge extends StatelessWidget {
  final String label;
  const _NavBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient:     AppGradients.button,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color:    AppColors.onPrimary,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _NavAvatar extends StatelessWidget {
  final QNavUserProfile profile;
  const _NavAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape:  BoxShape.circle,
        color:  AppColors.tint10(AppColors.primary),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                profile.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    profile.initial,
                    style: AppTypography.h5
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                profile.initial,
                style: AppTypography.h5
                    .copyWith(color: AppColors.primary),
              ),
            ),
    );
  }
}