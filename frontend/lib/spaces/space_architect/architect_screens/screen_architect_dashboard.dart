// frontend/lib/spaces/space_architect/architect_screens/screen_architect_dashboard.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. Architect dashboard. Left sidebar for space
//                  selection, main grid of screen cards, opens preview overlay.
// ─────────────────────────────────────────────────────────────────────────────
//
// Layout: fixed left sidebar + scrollable main grid.
// Selecting a space in the sidebar filters the screen cards.
// Clicking a card's "Preview" button pushes ScreenArchitectPreview.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/style/app_style.dart';
import '../architect_registry/architect_screen_registry.dart';
import '../architect_state/architect_riverpod.dart';
import 'screen_architect_preview.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ─────────────────────────────────────────────────────────────────────
const double _kSidebarWidth      = 220.0;
const double _kHeaderHeight      = 56.0;
const double _kCardWidth         = 260.0;
const double _kCardHeight        = 160.0;
const double _kCardGridSpacing   = 16.0;
const double _kCardGridPadding   = 24.0;
const double _kSidebarItemH      = 48.0;
const double _kSidebarIconSize   = 18.0;
const double _kSidebarFontSize   = 13.0;
const double _kCardTitleSize     = 14.0;
const double _kCardDescSize      = 11.5;
const double _kCardBadgePadH     = 8.0;
const double _kCardBadgePadV     = 3.0;
const double _kCardBadgeFontSize = 9.5;
const double _kEmptyIconSize     = 48.0;

// ── Copy ───────────────────────────────────────────────────────────────────────
const String _kTitle           = 'Architect';
const String _kSubtitle        = 'QSpace Dev System';
const String _kPreviewBtn      = 'Preview';
const String _kEmptyLabel      = 'No screens built yet';
const String _kEmptyHint       = 'Add entries to kArchitectSpaces in architect_screen_registry.dart';
const String _kLogoutTooltip   = 'Exit architect space';

// ─────────────────────────────────────────────────────────────────────────────
// ScreenArchitectDashboard
// ─────────────────────────────────────────────────────────────────────────────

class ScreenArchitectDashboard extends ConsumerWidget {
  const ScreenArchitectDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSpaceId = ref.watch(architectSelectedSpaceProvider);
    final selectedSpace = kArchitectSpaces.firstWhere(
      (s) => s.id == selectedSpaceId,
      orElse: () => kArchitectSpaces.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Left sidebar ────────────────────────────────────────────────────
          _ArchitectSidebar(
            spaces:          kArchitectSpaces,
            selectedSpaceId: selectedSpaceId,
            onSpaceSelected: (id) =>
                ref.read(architectSelectedSpaceProvider.notifier).state = id,
            onLogout: () =>
                ref.read(architectIsLoggedInProvider.notifier).state = false,
          ),

          // ── Vertical divider ────────────────────────────────────────────────
          Container(width: 1, color: AppColors.border),

          // ── Main content ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHeader(space: selectedSpace),
                Container(height: 1, color: AppColors.border),
                Expanded(
                  child: selectedSpace.screens.isEmpty
                      ? _EmptySpace(space: selectedSpace)
                      : _ScreenGrid(
                          space:   selectedSpace,
                          onOpen:  (entry) => _openPreview(context, ref, entry),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPreview(
    BuildContext context,
    WidgetRef ref,
    ArchitectScreenEntry entry,
  ) {
    // Set the default device for this screen type
    ref.read(architectPreviewDeviceProvider.notifier).state =
        entry.defaultDevice;

    // Push preview as a full-screen route on top of the dashboard
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ScreenArchitectPreview(entry: entry),
        transitionDuration: AppDurations.normal,
        reverseTransitionDuration: AppDurations.normal,
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve:  Curves.easeOut,
          );
          return FadeTransition(
            opacity: fade,
            child:   SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end:   Offset.zero,
              ).animate(fade),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ArchitectSidebar
// ─────────────────────────────────────────────────────────────────────────────

class _ArchitectSidebar extends StatelessWidget {
  final List<ArchitectSpace> spaces;
  final String               selectedSpaceId;
  final ValueChanged<String> onSpaceSelected;
  final VoidCallback         onLogout;

  const _ArchitectSidebar({
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
          _SidebarHeader(),

          Container(height: 1, color: AppColors.border),

          // Space list
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
          _SidebarLogoutButton(onLogout: onLogout),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:  _kHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Architect gradient badge
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
    );
  }
}

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
          duration:  AppDurations.fast,
          height:    _kSidebarItemH,
          margin:    EdgeInsets.only(bottom: 2),
          padding:   EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive
                ? widget.space.accent.withValues(alpha: 0.15)
                : _hovered
                    ? AppColors.surface
                    : Colors.transparent,
            borderRadius: AppRadius.smBR,
            border: isActive
                ? Border.all(
                    color: widget.space.accent.withValues(alpha: 0.30),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.space.icon,
                size:  _kSidebarIconSize,
                color: isActive ? widget.space.accent : AppColors.textMuted,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.space.label,
                  style: AppTypography.helper.copyWith(
                    fontSize:   _kSidebarFontSize,
                    color:      isActive ? widget.space.accent : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Screen count badge
              if (widget.space.screens.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kCardBadgePadH,
                    vertical:   _kCardBadgePadV,
                  ),
                  decoration: BoxDecoration(
                    color:        widget.space.accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.pillBR,
                  ),
                  child: Text(
                    '${widget.space.screens.length}',
                    style: AppTypography.badge.copyWith(
                      fontSize: _kCardBadgeFontSize,
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

class _SidebarLogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _SidebarLogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _kLogoutTooltip,
      child: InkWell(
        onTap: onLogout,
        child: SizedBox(
          height:  _kSidebarItemH,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size:  _kSidebarIconSize,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Exit',
                  style: AppTypography.helper.copyWith(
                    fontSize: _kSidebarFontSize,
                    color:    AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DashboardHeader — top bar showing the selected space name
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final ArchitectSpace space;
  const _DashboardHeader({required this.space});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  _kHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: _kCardGridPadding),
      child: Row(
        children: [
          Icon(space.icon, size: 18, color: space.accent),
          SizedBox(width: AppSpacing.sm),
          Text(
            space.label,
            style: AppTypography.h4.copyWith(color: space.accent),
          ),
          SizedBox(width: AppSpacing.sm),
          if (space.screens.isNotEmpty)
            Text(
              '${space.screens.length} screen${space.screens.length == 1 ? '' : 's'}',
              style: AppTypography.caption,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScreenGrid — wraps screen cards
// ─────────────────────────────────────────────────────────────────────────────

class _ScreenGrid extends StatelessWidget {
  final ArchitectSpace                      space;
  final void Function(ArchitectScreenEntry) onOpen;

  const _ScreenGrid({required this.space, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_kCardGridPadding),
      child: Wrap(
        spacing:     _kCardGridSpacing,
        runSpacing:  _kCardGridSpacing,
        children: space.screens
            .map((entry) => _ScreenCard(
                  entry:   entry,
                  space:   space,
                  onOpen:  () => onOpen(entry),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScreenCard — individual screen card with preview button
// ─────────────────────────────────────────────────────────────────────────────

class _ScreenCard extends StatefulWidget {
  final ArchitectScreenEntry entry;
  final ArchitectSpace       space;
  final VoidCallback         onOpen;

  const _ScreenCard({
    required this.entry,
    required this.space,
    required this.onOpen,
  });

  @override
  State<_ScreenCard> createState() => _ScreenCardState();
}

class _ScreenCardState extends State<_ScreenCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onOpen,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width:    _kCardWidth,
          height:   _kCardHeight,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceMid : AppColors.surface,
            borderRadius: AppRadius.cardBR,
            border: Border.all(
              color: _hovered
                  ? widget.space.accent.withValues(alpha: 0.40)
                  : AppColors.border,
            ),
            boxShadow: _hovered ? AppShadows.card : null,
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: screen label + space badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.entry.label,
                      style: AppTypography.h5.copyWith(
                        fontSize:   _kCardTitleSize,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kCardBadgePadH,
                      vertical:   _kCardBadgePadV,
                    ),
                    decoration: BoxDecoration(
                      color:        widget.space.accent.withValues(alpha: 0.12),
                      borderRadius: AppRadius.pillBR,
                    ),
                    child: Text(
                      widget.space.id.replaceFirst('space_', ''),
                      style: AppTypography.badge.copyWith(
                        fontSize: _kCardBadgeFontSize,
                        color:    widget.space.accent,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.xs),

              // Description
              Expanded(
                child: Text(
                  widget.entry.description,
                  style: AppTypography.helper.copyWith(
                    fontSize: _kCardDescSize,
                    color:    AppColors.textSecondary,
                    height:   1.5,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),

              SizedBox(height: AppSpacing.sm),

              // Preview button — always at the bottom
              _CardPreviewButton(
                spaceAccent: widget.space.accent,
                onTap:       widget.onOpen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPreviewButton extends StatelessWidget {
  final Color        spaceAccent;
  final VoidCallback onTap;

  const _CardPreviewButton({required this.spaceAccent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:   32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient:     AppGradients.button,
          borderRadius: AppRadius.pillBR,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              size:  14,
              color: AppColors.onPrimary,
            ),
            SizedBox(width: 4),
            Text(
              _kPreviewBtn,
              style: AppTypography.buttonSm.copyWith(
                fontSize: 12,
                color:    AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptySpace — shown when a space has no registered screens yet
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySpace extends StatelessWidget {
  final ArchitectSpace space;
  const _EmptySpace({required this.space});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            space.icon,
            size:  _kEmptyIconSize,
            color: space.accent.withValues(alpha: 0.25),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _kEmptyLabel,
            style: AppTypography.h4.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            _kEmptyHint,
            style: AppTypography.helper.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}