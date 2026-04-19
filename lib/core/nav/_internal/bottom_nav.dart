// lib/core/nav/_internal/bottom_nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QBottomNav — native mobile bottom tab bar.
//             Respects QNavTemplate.showActiveDot and activeStyle.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import '../nav_config.dart';
import '../nav_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QBottomNav
// ─────────────────────────────────────────────────────────────────────────────

class QBottomNav extends StatelessWidget {
  final List<QNavItem>     items;
  final String             currentRoute;
  final QNavTemplate       template;
  final void Function(String) onTap;

  const QBottomNav({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:  AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final active = item.route == currentRoute;
            final color  = active ? AppColors.primary : AppColors.textMuted;
            return GestureDetector(
              onTap:     () => onTap(item.route),
              behavior:  HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical:  kNavBottomItemVPad,
                  horizontal: kNavBottomItemHPad,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Icon switches with a crossfade so the active/inactive swap
                  // feels snappy without a jarring cut.
                  AnimatedSwitcher(
                    duration: kNavHoverAnim,
                    child: Icon(
                      active ? item.resolvedActiveIcon : item.icon,
                      key:   ValueKey('$active-${item.route}'),
                      color: color,
                      size:  22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: AppTypography.caption.copyWith(
                      color:      color,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      fontSize:   kNavBottomLabelSize,
                    ),
                  ),
                  // Underline dot indicator for the active item — optional
                  if (template.showActiveDot && active)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    ),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}