// lib/core/nav/_internal/top_strip_nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QTopStripNav — horizontal top tab row for the
//             QNavVariant.topStripOnly template on desktop. Active style
//             uses underline (suite.portal pattern).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import '../nav_config.dart';
import '../nav_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QTopStripNav
// ─────────────────────────────────────────────────────────────────────────────

class QTopStripNav extends StatelessWidget {
  final List<QNavItem>     items;
  final String             currentRoute;
  final QNavTemplate       template;
  final void Function(String) onTap;

  const QTopStripNav({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kNavAdminTopStripH,
      decoration: BoxDecoration(
        color:  AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Logo zone — mirrors sidebar logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BrandLogo(fallbackSize: LogoSize.sm),
          ),
          const VerticalDivider(width: 1),
          // Nav tabs
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.map((item) => _TopStripTab(
                  item:     item,
                  active:   item.route == currentRoute,
                  template: template,
                  onTap:    () => onTap(item.route),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopStripTab
// ─────────────────────────────────────────────────────────────────────────────

class _TopStripTab extends StatefulWidget {
  final QNavItem     item;
  final bool         active;
  final QNavTemplate template;
  final VoidCallback onTap;

  const _TopStripTab({
    required this.item,
    required this.active,
    required this.template,
    required this.onTap,
  });

  @override
  State<_TopStripTab> createState() => _TopStripTabState();
}

class _TopStripTabState extends State<_TopStripTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final color  = active ? AppColors.primary : AppColors.textSecondary;

    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kNavHoverAnim,
          padding:  const EdgeInsets.symmetric(horizontal: 16),
          height:   kNavAdminTopStripH,
          decoration: BoxDecoration(
            color: _hovered && !active
                ? AppColors.tint10(AppColors.primary)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color:  active ? AppColors.primary : Colors.transparent,
                width:  2,
              ),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              active ? widget.item.resolvedActiveIcon : widget.item.icon,
              size:  18,
              color: active ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              widget.item.label,
              style: AppTypography.h5.copyWith(
                color:      color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (widget.item.badge != null) ...[
              const SizedBox(width: 6),
              _StripBadge(label: widget.item.badge!),
            ],
          ]),
        ),
      ),
    );
  }
}

class _StripBadge extends StatelessWidget {
  final String label;
  const _StripBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          gradient:     AppGradients.button,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color:    Color(0xFFFFFFFF),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}