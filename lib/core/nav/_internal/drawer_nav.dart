// lib/core/nav/_internal/drawer_nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QDrawerNav — drawer content for web/desktop narrow mode.
//             Shares visual language with QSidebarNav but is always expanded.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import '../nav_config.dart';
import '../nav_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QDrawerNav
// ─────────────────────────────────────────────────────────────────────────────

class QDrawerNav extends StatelessWidget {
  final List<QNavItem>   items;
  final String           currentRoute;
  final QNavTemplate     template;
  final QNavUserProfile? userProfile;
  final void Function(String) onTap;

  const QDrawerNav({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.template,
    required this.onTap,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: logo + close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(children: [
              BrandLogo(fallbackSize: LogoSize.sm),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color:        AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border:       Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textMuted),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: items
                  .map((item) => _DrawerItem(
                        item:     item,
                        active:   item.route == currentRoute,
                        template: template,
                        onTap:    () => onTap(item.route),
                      ))
                  .toList(),
            ),
          ),

          Divider(color: AppColors.border, height: 1),

          // User tile
          if (template.showUserTile && userProfile != null)
            _DrawerUserTile(profile: userProfile!),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerItem
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerItem extends StatefulWidget {
  final QNavItem     item;
  final bool         active;
  final QNavTemplate template;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.item,
    required this.active,
    required this.template,
    required this.onTap,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final bg    = active
        ? AppColors.primary.withValues(alpha: 0.12)
        : _hovered
            ? AppColors.tint10(AppColors.primary)
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
          height:  kNavItemHeight,
          margin:  const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(kNavItemRadius),
            border:       active
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(children: [
            // Accent bar for accentBar style
            if (widget.template.activeStyle == QNavActiveStyle.accentBar)
              _AccentBar(active: active),
            if (widget.template.activeStyle == QNavActiveStyle.accentBar)
              const SizedBox(width: 8),
            Icon(
              active
                  ? widget.item.resolvedActiveIcon
                  : widget.item.icon,
              color: color,
              size:  20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.item.label,
                style: AppTypography.h5.copyWith(
                  color:      color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (widget.item.badge != null)
              _SmallBadge(label: widget.item.badge!),
            if (widget.template.showActiveDot && active)
              _ActiveDot(),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerUserTile
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerUserTile extends StatelessWidget {
  final QNavUserProfile profile;
  const _DrawerUserTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initial = profile.initial;
    final avatar  = Container(
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
                  child: Text(initial,
                      style: AppTypography.h5
                          .copyWith(color: AppColors.primary)),
                ),
              ),
            )
          : Center(
              child: Text(initial,
                  style: AppTypography.h5
                      .copyWith(color: AppColors.primary)),
            ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
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
                Text(profile.roleName!, style: AppTypography.caption),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primitives
// ─────────────────────────────────────────────────────────────────────────────

class _AccentBar extends StatelessWidget {
  final bool active;
  const _AccentBar({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kNavHoverAnim,
      width:  3,
      height: active ? 24 : 0,
      decoration: active
          ? BoxDecoration(
              gradient:     AppGradients.button,
              borderRadius: BorderRadius.circular(2),
            )
          : null,
    );
  }
}

class _ActiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 5, height: 5,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: AppColors.primary, shape: BoxShape.circle),
      );
}

class _SmallBadge extends StatelessWidget {
  final String label;
  const _SmallBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        margin:  const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          gradient:     AppGradients.button,
          borderRadius: BorderRadius.circular(6),
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