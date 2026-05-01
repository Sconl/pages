// frontend/lib/spaces/space_architect/architect_portals/dashboard_portal/dashboard_widgets/widget_dashboard_screen_card.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Screen card with hover state and preview button.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kCardWidth      = 260.0;
const double _kCardHeight     = 160.0;
const double _kBadgePadH      = 8.0;
const double _kBadgePadV      = 3.0;
const double _kBadgeFontSize  = 9.5;
const double _kTitleSize      = 14.0;
const double _kDescSize       = 11.5;
const double _kPreviewBtnH    = 32.0;
const double _kPreviewIconSize = 14.0;
const double _kPreviewFontSize = 12.0;
const String _kPreviewLabel   = 'Preview';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class WidgetDashboardScreenCard extends StatefulWidget {
  final ArchitectScreenEntry entry;
  final ArchitectSpace       space;
  final VoidCallback         onOpen;

  const WidgetDashboardScreenCard({
    super.key,
    required this.entry,
    required this.space,
    required this.onOpen,
  });

  @override
  State<WidgetDashboardScreenCard> createState() => _WidgetDashboardScreenCardState();
}

class _WidgetDashboardScreenCardState extends State<WidgetDashboardScreenCard> {
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
            color:        _hovered ? AppColors.surfaceMid : AppColors.surface,
            borderRadius: AppRadius.cardBR,
            border:       Border.all(
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
              // Label row + space badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.entry.label,
                      style: AppTypography.h5.copyWith(
                        fontSize:   _kTitleSize,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
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
                      widget.space.id.replaceFirst('space_', ''),
                      style: AppTypography.badge.copyWith(
                        fontSize: _kBadgeFontSize,
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
                    fontSize: _kDescSize,
                    color:    AppColors.textSecondary,
                    height:   1.5,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Preview button
              GestureDetector(
                onTap: widget.onOpen,
                child: Container(
                  height:    _kPreviewBtnH,
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
                        size:  _kPreviewIconSize,
                        color: AppColors.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _kPreviewLabel,
                        style: AppTypography.buttonSm.copyWith(
                          fontSize: _kPreviewFontSize,
                          color:    AppColors.onPrimary,
                        ),
                      ),
                    ],
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