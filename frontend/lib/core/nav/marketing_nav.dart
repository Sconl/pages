// lib/core/nav/marketing_nav.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QMarketingNav — floating public nav bar.
//             Three-column desktop layout (logo | links | CTA + profile).
//             Collapsible mobile menu. Frosted-glass scroll effect.
//             All sizes and durations from nav_config.dart.
//             Template controls frost and floating modes.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qspace_pages/core/style/app_style.dart';

import 'nav_config.dart';
import 'nav_item.dart';
import 'nav_scope.dart';
import 'nav_mode.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QMarketingNav
// ─────────────────────────────────────────────────────────────────────────────
//
// Drop this inside a Stack as the first child (Positioned top:0) on any
// marketing/public page. Pass your ScrollController so it knows when to
// activate the frost effect.

class QMarketingNav extends StatefulWidget {
  /// Flat list of marketing nav links.
  final List<QNavItem> items;

  /// Label for the primary CTA button.
  final String ctaLabel;

  /// Called when the CTA button is tapped.
  final VoidCallback onCta;

  /// Optional — called when the profile circle is tapped. Null = no circle.
  final VoidCallback? onProfileTap;

  /// Icon for the profile circle. Defaults to person outline.
  final IconData profileIcon;

  /// Tooltip shown on the profile circle.
  final String profileTooltip;

  /// Visual template — controls frost, floating border, etc.
  final QNavTemplate template;

  /// Scroll controller from the page's scrollable. Drives the frost effect.
  final ScrollController? scrollController;

  /// Called when a nav link is tapped. Usually context.push(route).
  final void Function(String route) onNavigate;

  const QMarketingNav({
    super.key,
    required this.items,
    required this.ctaLabel,
    required this.onCta,
    required this.onNavigate,
    this.onProfileTap,
    this.profileIcon      = Icons.person_outline_rounded,
    this.profileTooltip   = 'Sign in',
    this.template         = kNavTemplateDefault,
    this.scrollController,
  });

  @override
  State<QMarketingNav> createState() => _QMarketingNavState();
}

class _QMarketingNavState extends State<QMarketingNav>
    with SingleTickerProviderStateMixin {

  bool _scrolled   = false;
  bool _mobileOpen = false;

  late final AnimationController _menuCtrl;
  late final Animation<double>   _menuFade;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
        vsync: this, duration: kNavMenuAnim);
    _menuFade = CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOut);
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled =
        (widget.scrollController?.hasClients ?? false) &&
        widget.scrollController!.offset > kNavFrostThreshold;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
  }

  void _toggleMenu() {
    setState(() => _mobileOpen = !_mobileOpen);
    _mobileOpen ? _menuCtrl.forward() : _menuCtrl.reverse();
  }

  void _closeMenu() {
    if (!_mobileOpen) return;
    setState(() => _mobileOpen = false);
    _menuCtrl.reverse();
  }

  @override
  void didUpdateWidget(QMarketingNav old) {
    super.didUpdateWidget(old);
    if (old.scrollController != widget.scrollController) {
      old.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _menuCtrl.dispose();
    super.dispose();
  }

  double get _mobileMenuHeight =>
      widget.items.length * kNavMobileItemH +
      kNavMobileCtaH + kNavMobileMenuVPad * 2 + AppSpacing.sm;

  bool get _frosted =>
      widget.template.marketingFrost && (_scrolled || _mobileOpen);

  @override
  Widget build(BuildContext context) {
    final mode = QNavModeResolver.resolve(
        context, widget.template.variant);

    // The marketing nav wraps itself in a QNavScope so QHamburgerButton
    // works from anywhere on the page.
    return QNavScope(
      mode:            mode,
      openDrawer:      _toggleMenu, // marketing "drawer" is the mobile menu
      sidebarExpanded: false,
      toggleSidebar:   () {},
      template:        widget.template,
      child: Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          bottom: false,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _frosted ? 16 : 0,
                sigmaY: _frosted ? 16 : 0,
              ),
              child: AnimatedContainer(
                duration: kNavSidebarAnim,
                curve:    Curves.easeOut,
                decoration: BoxDecoration(
                  color: _frosted
                      ? AppColors.background.withAlpha(215)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: _frosted
                          ? AppColors.border
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  return constraints.maxWidth < kNavMarketingBreak
                      ? _buildMobile(ctx)
                      : _buildDesktop(ctx);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Desktop ────────────────────────────────────────────────────────────────
  //
  // Three-column: [logo zone | Expanded links | CTA + profile zone]
  // Left and right zones are fixed-width (kNavSideZoneWidth) so the
  // center links are mathematically centred in the viewport.

  Widget _buildDesktop(BuildContext context) {
    return SizedBox(
      height: kNavBarHeightMarketing,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kNavHPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Left — logo
            SizedBox(
              width:  kNavSideZoneWidth,
              height: kNavElementHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.onNavigate('/'),
                    child: BrandLogo(
                        fallbackSize: LogoSize.lg,
                        height: kNavElementHeight),
                  ),
                ),
              ),
            ),

            // Center — nav links
            Expanded(
              child: SizedBox(
                height: kNavElementHeight,
                child: Center(
                  child: Wrap(
                    alignment:          WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing:            kNavItemSpacing,
                    children: widget.items
                        .map((item) => _MarketingNavLink(
                              item:       item,
                              onNavigate: widget.onNavigate,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),

            // Right — CTA + optional profile circle
            SizedBox(
              width:  kNavSideZoneWidth,
              height: kNavElementHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: _MarketingCtaButton(
                      label:     widget.ctaLabel,
                      onPressed: widget.onCta,
                    ),
                  ),
                  if (widget.onProfileTap != null) ...[
                    const SizedBox(width: kNavCtaProfileGap),
                    SizedBox(
                      width: kNavElementHeight, height: kNavElementHeight,
                      child: Center(
                        child: _ProfileCircle(
                          icon:      widget.profileIcon,
                          tooltip:   widget.profileTooltip,
                          onPressed: widget.onProfileTap!,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile ─────────────────────────────────────────────────────────────────

  Widget _buildMobile(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kNavBarHeightMarketing,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kNavHPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      _closeMenu();
                      widget.onNavigate('/');
                    },
                    child: BrandLogo(
                      fallbackSize: LogoSize.sm,
                      height:       kNavElementHeight - 4,
                    ),
                  ),
                ),
                const Spacer(),
                _HamburgerButton(
                  isOpen: _mobileOpen,
                  onTap:  _toggleMenu,
                ),
              ],
            ),
          ),
        ),

        // Collapsible mobile menu panel
        AnimatedContainer(
          duration: kNavMenuAnim,
          curve:    Curves.easeOut,
          height:   _mobileOpen ? _mobileMenuHeight : 0,
          child: ClipRect(
            child: FadeTransition(
              opacity: _menuFade,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  kNavHPad, kNavMobileMenuVPad,
                  kNavHPad, kNavMobileMenuVPad,
                ),
                child: Column(
                  mainAxisSize:        MainAxisSize.min,
                  crossAxisAlignment:  CrossAxisAlignment.stretch,
                  children: [
                    ...widget.items.map((item) => _MobileNavLink(
                          item: item,
                          onNavigate: (r) {
                            _closeMenu();
                            widget.onNavigate(r);
                          },
                        )),
                    SizedBox(height: AppSpacing.sm),
                    _MarketingCtaButton(
                      label:     widget.ctaLabel,
                      fullWidth: true,
                      onPressed: () {
                        _closeMenu();
                        widget.onCta();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MarketingNavLink — desktop link with gradient hover + animated underline
// ─────────────────────────────────────────────────────────────────────────────

class _MarketingNavLink extends StatefulWidget {
  final QNavItem item;
  final void Function(String) onNavigate;
  const _MarketingNavLink({required this.item, required this.onNavigate});

  @override
  State<_MarketingNavLink> createState() => _MarketingNavLinkState();
}

class _MarketingNavLinkState extends State<_MarketingNavLink> {
  bool _hovered = false;
  bool _focused = false;

  static const _base = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, height: 1.0);

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: MouseRegion(
        cursor:  SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => widget.onNavigate(widget.item.route),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedSwitcher(
              duration: kNavHoverAnim,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: active
                  ? ShaderMask(
                      key: const ValueKey('g'),
                      shaderCallback: (b) => AppGradients.button.createShader(
                          Rect.fromLTWH(0, 0, b.width, b.height)),
                      blendMode: BlendMode.srcIn,
                      child: Text(widget.item.label,
                          style: _base.copyWith(color: Colors.white),
                          semanticsLabel:
                              widget.item.resolvedSemanticLabel),
                    )
                  : Text(widget.item.label,
                      key:   const ValueKey('n'),
                      style: _base.copyWith(
                          color: AppColors.textSecondary),
                      semanticsLabel:
                          widget.item.resolvedSemanticLabel),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration:     kNavHoverAnim,
              curve:        Curves.easeOut,
              height:       1.5,
              width:        active ? 36 : 0,
              decoration:   BoxDecoration(
                gradient:     active ? AppGradients.button : null,
                color:        active ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileNavLink
// ─────────────────────────────────────────────────────────────────────────────

class _MobileNavLink extends StatefulWidget {
  final QNavItem item;
  final void Function(String) onNavigate;
  const _MobileNavLink({required this.item, required this.onNavigate});

  @override
  State<_MobileNavLink> createState() => _MobileNavLinkState();
}

class _MobileNavLinkState extends State<_MobileNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onNavigate(widget.item.route),
        child: AnimatedContainer(
          duration: kNavHoverAnim,
          height:   kNavMobileItemH,
          padding:  const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color:        _hovered
                ? AppColors.tint10(AppColors.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(kNavItemRadius),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.item.label,
              style: AppTypography.body.copyWith(
                color:      _hovered
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MarketingCtaButton — gradient pill button, desktop inline or mobile full-width
// ─────────────────────────────────────────────────────────────────────────────

class _MarketingCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;
  const _MarketingCtaButton({
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  State<_MarketingCtaButton> createState() => _MarketingCtaButtonState();
}

class _MarketingCtaButtonState extends State<_MarketingCtaButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
             event.logicalKey == LogicalKeyboardKey.space)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor:  SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) =>
            setState(() { _hovered = false; _pressed = false; }),
        child: GestureDetector(
          onTapDown:   (_) => setState(() => _pressed = true),
          onTapUp:     (_) {
            setState(() => _pressed = false);
            widget.onPressed();
          },
          onTapCancel: ()  => setState(() => _pressed = false),
          child: AnimatedScale(
            duration: kNavHoverAnim,
            curve:    Curves.easeOutBack,
            scale:    _pressed ? 0.96 : 1.0,
            child: AnimatedContainer(
              duration: kNavHoverAnim,
              width:    widget.fullWidth ? double.infinity : null,
              height:   widget.fullWidth ? kNavMobileCtaH : kNavElementHeight,
              padding:  widget.fullWidth
                  ? const EdgeInsets.symmetric(horizontal: 24)
                  : const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient:     active
                    ? AppGradients.buttonHover
                    : AppGradients.button,
                borderRadius: AppRadius.pillBR,
                boxShadow:    active
                    ? AppShadows.buttonGlowHover
                    : AppShadows.buttonGlow,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  maxLines:  1,
                  overflow:  TextOverflow.ellipsis,
                  style: AppTypography.button.copyWith(
                    fontSize:      14,
                    fontWeight:    FontWeight.w800,
                    letterSpacing: 0.3,
                    color:         AppColors.onPrimary,
                  ),
                  semanticsLabel: 'Call to action: ${widget.label}',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileCircle
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCircle extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  const _ProfileCircle({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_ProfileCircle> createState() => _ProfileCircleState();
}

class _ProfileCircleState extends State<_ProfileCircle> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    const size   = kNavElementHeight - 2.0;

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
             event.logicalKey == LogicalKeyboardKey.space)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Tooltip(
        message:        widget.tooltip,
        preferBelow:    true,
        verticalOffset: size / 2 + 10,
        waitDuration:   const Duration(milliseconds: 800),
        child: MouseRegion(
          cursor:  SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) =>
              setState(() { _hovered = false; _pressed = false; }),
          child: GestureDetector(
            onTapDown:   (_) => setState(() => _pressed = true),
            onTapUp:     (_) {
              setState(() => _pressed = false);
              widget.onPressed();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              duration: kNavHoverAnim,
              curve:    Curves.easeOutBack,
              scale:    _pressed ? 0.90 : 1.0,
              child: AnimatedContainer(
                duration: kNavHoverAnim,
                width: size, height: size,
                decoration: BoxDecoration(
                  shape:  BoxShape.circle,
                  color:  active
                      ? AppColors.tint10(AppColors.primary)
                      : AppColors.surface,
                  border: Border.all(
                    color: active
                        ? AppColors.borderFocused
                        : AppColors.borderStrong,
                    width: active ? 1.5 : 1.0,
                  ),
                  boxShadow: active
                      ? [BoxShadow(
                          color:        AppColors.primary
                              .withValues(alpha: 0.18),
                          blurRadius:   12,
                          spreadRadius: 1,
                        )]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size:  16,
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    semanticLabel: widget.tooltip,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HamburgerButton — animated open/close for mobile header
// ─────────────────────────────────────────────────────────────────────────────

class _HamburgerButton extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onTap;
  const _HamburgerButton({required this.isOpen, required this.onTap});

  @override
  State<_HamburgerButton> createState() => _HamburgerButtonState();
}

class _HamburgerButtonState extends State<_HamburgerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _rot;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: kNavMenuAnim);
    _rot  = Tween<double>(begin: 0, end: 0.375)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_HamburgerButton old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kNavHoverAnim,
          width:  kNavElementHeight,
          height: kNavElementHeight,
          decoration: BoxDecoration(
            color:        _hovered
                ? AppColors.tint10(AppColors.primary)
                : AppColors.surface.withAlpha(200),
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(
              color: _hovered ? AppColors.primary : AppColors.border),
          ),
          child: Center(
            child: RotationTransition(
              turns: _rot,
              child: AnimatedSwitcher(
                duration: kNavHoverAnim,
                child: Icon(
                  widget.isOpen
                      ? Icons.close_rounded
                      : Icons.menu_rounded,
                  key:   ValueKey(widget.isOpen),
                  size:  18,
                  color: _hovered
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}