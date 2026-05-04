// frontend/lib/spaces/space_architect/architect_portals/dashboard_portal/dashboard_sections/section_dashboard_grid.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Screen card grid + header bar + empty state.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';
import '../dashboard_widgets/widget_dashboard_screen_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kHeaderHeight   = 56.0;
const double _kGridPadding    = 24.0;
const double _kGridSpacing    = 16.0;
const double _kEmptyIconSize  = 48.0;
const String _kEmptyLabel     = 'No screens registered yet';
const String _kEmptyHint      = 'Add entries to kArchitectSpaces\nin architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionDashboardGrid extends StatelessWidget {
  final ArchitectSpace                      space;
  final void Function(ArchitectScreenEntry) onOpen;

  const SectionDashboardGrid({
    super.key,
    required this.space,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar showing space name and screen count
        _GridHeader(space: space),
        Container(height: 1, color: AppColors.border),

        // Grid or empty state
        Expanded(
          child: space.screens.isEmpty
              ? _EmptyState(space: space)
              : _ScreenGrid(space: space, onOpen: onOpen),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GridHeader
// ─────────────────────────────────────────────────────────────────────────────

class _GridHeader extends StatelessWidget {
  final ArchitectSpace space;
  const _GridHeader({required this.space});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  _kHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: _kGridPadding),
      child: Row(
        children: [
          Icon(space.icon, size: 18, color: space.accent),
          SizedBox(width: AppSpacing.sm),
          Text(
            space.label,
            style: AppTypography.h4.copyWith(color: space.accent),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            space.screens.isEmpty
                ? 'no screens yet'
                : '${space.screens.length} screen${space.screens.length == 1 ? '' : 's'}',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScreenGrid — Wrap of screen cards
// ─────────────────────────────────────────────────────────────────────────────

class _ScreenGrid extends StatelessWidget {
  final ArchitectSpace                      space;
  final void Function(ArchitectScreenEntry) onOpen;

  const _ScreenGrid({required this.space, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_kGridPadding),
      child: Wrap(
        spacing:    _kGridSpacing,
        runSpacing: _kGridSpacing,
        children: space.screens.map((entry) => WidgetDashboardScreenCard(
          entry: entry,
          space: space,
          onOpen: () => onOpen(entry),
        )).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ArchitectSpace space;
  const _EmptyState({required this.space});

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
            style:     AppTypography.helper.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}