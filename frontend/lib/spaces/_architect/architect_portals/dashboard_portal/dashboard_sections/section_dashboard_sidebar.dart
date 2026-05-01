// frontend/lib/spaces/space_architect/architect_portals/dashboard_portal/dashboard_sections/section_dashboard_sidebar.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Fixed sidebar with space selector and logout.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kSidebarWidth    = 220.0;
const double _kHeaderHeight    = 56.0;
const double _kItemHeight      = 48.0;
const double _kItemIconSize    = 18.0;
const double _kItemFontSize    = 13.0;
const double _kBadgePadH       = 8.0;
const double _kBadgePadV       = 3.0;
const double _kBadgeFontSize   = 9.5;
const String _kTitle           = 'Architect';
const String _kSubtitle        = 'QSpace Dev System';
const String _kLogoutTooltip   = 'Exit architect space';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionDashboardSidebar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kSidebarWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            height:  _kHeaderHeight,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width:  8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppGradients.button,
                    shape:    BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kTitle,
                      style: AppTypography.h5.copyWith(
                        fontSize:   13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _kSubtitle,
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.border),

          // Space items
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical:   AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              child: Column(
                children: spaces.map((space) => _SidebarSpaceItem(
                  space:      space,
                  isSelected: space.id == selectedSpaceId,
                  onTap:      () => onSpaceSelected(space.id),
                )).toList(),
              ),
            ),
          ),

          Container(height: 1, color: AppColors.border),

          // Logout
          Tooltip(
            message: _kLogoutTooltip,
            child: InkWell(
              onTap: onLogout,
              child: SizedBox(
                height: _kItemHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size:  _kItemIconSize,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Exit',
                        style: AppTypography.helper.copyWith(
                          fontSize: _kItemFontSize,
                          color:    AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarSpaceItem
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarSpaceItem extends StatefulWidget {
  final ArchitectSpace space;
  final bool           isSelected;
  final VoidCallback   onTap;

  const _SidebarSpaceItem({
    required this.space,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarSpaceItem> createState() => _SidebarSpaceItemState();
}

class _SidebarSpaceItemState extends State<_SidebarSpaceItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected;

    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height:   _kItemHeight,
          margin:   const EdgeInsets.only(bottom: 2),
          padding:  EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive
                ? widget.space.accent.withValues(alpha: 0.15)
                : _hovered
                    ? AppColors.surface
                    : Colors.transparent,
            borderRadius: AppRadius.smBR,
            border: isActive
                ? Border.all(color: widget.space.accent.withValues(alpha: 0.30))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.space.icon,
                size:  _kItemIconSize,
                color: isActive ? widget.space.accent : AppColors.textMuted,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.space.label,
                  style: AppTypography.helper.copyWith(
                    fontSize:   _kItemFontSize,
                    color:      isActive ? widget.space.accent : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Screen count badge — only when there are registered screens
              if (widget.space.screens.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kBadgePadH,
                    vertical:   _kBadgePadV,
                  ),
                  decoration: BoxDecoration(
                    color:        widget.space.accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.pillBR,
                  ),
                  child: Text(
                    '${widget.space.screens.length}',
                    style: AppTypography.badge.copyWith(
                      fontSize: _kBadgeFontSize,
                      color:    widget.space.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}