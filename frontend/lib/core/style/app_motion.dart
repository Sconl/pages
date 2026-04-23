// lib/core/style/app_motion.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — AppMotionDefaults, TypingTextConfig, TypingHeadline,
//     AnimatedGradientBorder, AppPageTransitions, AppLoader.
//   • AppShimmer, AppStagger, AppReveal+AppRevealController, AppScale added.
//   • AppPageTransitions.zoom + slideUp added.
//   • BorderTriggerMode enum added — interactive (hover/focus) or periodic
//     (self-firing attention pulse). Passed to AnimatedGradientBorder.
//   • AnimatedGradientBorder updated — supports both trigger modes. Periodic
//     mode auto-fires on a timer; interactive mode respects isActive externally.
//   • AnimatedGradientSurface added — container with continuously animated
//     gradient background. Use for CTA banners and hero feature surfaces.
//   • ParallaxConfig added — speed factor, direction, maxOffset, enabled flag.
//     Pre-built configs: background / midground / foreground / heroBackground.
//   • ParallaxLayer added — translates a child at a fraction of scroll speed,
//     creating depth. Drop into a Stack above a SingleChildScrollView.
//   • Unused imports (app_branding, app_decorations) removed — all tokens
//     accessed through app_theme.dart only, avoiding unused import warnings.
//   • All unnecessary_underscores lint warnings fixed — (_, __) → (_, _).
// ─────────────────────────────────────────────────────────────────────────────

// DEPENDENCY CHAIN:
//   brand_config → app_branding → app_theme → app_motion

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_theme.dart'; // AppColors, AppGradients, AppSpacing, AppDurations, AppTypography

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Typing ────────────────────────────────────────────────────────────────────
const Duration _kTypingInterval       = Duration(milliseconds: 72);
const Duration _kDeletingInterval     = Duration(milliseconds: 42);
const Duration _kHoldAfterTyped       = Duration(milliseconds: 1550);
const Duration _kHoldAfterCleared     = Duration(milliseconds: 260);
const Duration _kCursorBlink          = Duration(milliseconds: 700);
const Duration _kTickDuration         = Duration(milliseconds: 40);
const double   _kTypingFontSize       = 56;
const FontWeight _kTypingFontWeight   = FontWeight.w800;
const double   _kCursorWidth          = 4;
const double   _kCursorHeight         = 44;
const double   _kCursorBottomPadding  = 6;
const double   _kHeadlineBlockHeight  = 104;

// ── Animated gradient border ──────────────────────────────────────────────────
const double   _kBorderArcFraction     = 0.30;
const double   _kBorderStrokeWidth     = 1.5;
const Duration _kBorderLoopDuration    = Duration(milliseconds: 2200);
const Duration _kBorderFadeDuration    = Duration(milliseconds: 240);
const Duration _kBorderTriggerInterval = Duration(seconds: 5);
const Duration _kBorderActiveDuration  = Duration(milliseconds: 2000);

// ── Animated gradient surface ─────────────────────────────────────────────────
const Duration _kSurfaceGradientDuration = Duration(seconds: 5);

// ── Parallax ──────────────────────────────────────────────────────────────────
const double _kParallaxFactor    = 0.30; // background moves at 30% of scroll speed
const double _kParallaxMaxOffset = 200.0;

// ── Page transitions ──────────────────────────────────────────────────────────
const Duration _kPageTransitionDuration = Duration(milliseconds: 280);

// ── Loader ────────────────────────────────────────────────────────────────────
const double _kLoaderSizeSm = 20.0;
const double _kLoaderSizeMd = 32.0;
const double _kLoaderSizeLg = 48.0;
const double _kLoaderStroke =  2.5;

// ── Shimmer ───────────────────────────────────────────────────────────────────
const Duration _kShimmerDuration = Duration(milliseconds: 1400);

// ── Stagger ───────────────────────────────────────────────────────────────────
const Duration _kStaggerItemDelay    = Duration(milliseconds: 60);
const Duration _kStaggerItemDuration = Duration(milliseconds: 320);
const double   _kStaggerSlideOffset  = 20.0;

// ── Reveal ────────────────────────────────────────────────────────────────────
const Duration _kRevealDuration    = Duration(milliseconds: 350);
const double   _kRevealSlideOffset = 16.0;

// ── Scale ─────────────────────────────────────────────────────────────────────
const Duration _kScaleDuration = Duration(milliseconds: 200);
const double   _kScaleFrom     = 0.85;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// AppMotionDefaults
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppMotionDefaults {
  static const Duration fast           = AppDurations.fast;
  static const Duration normal         = AppDurations.normal;
  static const Duration slow           = AppDurations.slow;
  static const Duration pageTransition = _kPageTransitionDuration;
  static const Duration borderFade     = _kBorderFadeDuration;
  static const Duration borderLoop     = _kBorderLoopDuration;
  static const Duration shimmer        = _kShimmerDuration;
  static const Duration staggerItem    = _kStaggerItemDuration;
  static const Duration reveal         = _kRevealDuration;

  static const Curve easeInOut     = Curves.easeInOut;
  static const Curve easeOut       = Curves.easeOut;
  static const Curve spring        = Curves.easeOutBack;
  static const Curve decelerate    = Curves.decelerate;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}


// ─────────────────────────────────────────────────────────────────────────────
// TypingTextConfig
// ─────────────────────────────────────────────────────────────────────────────

class TypingTextConfig {
  final List<String> phrases;
  final Duration typingInterval;
  final Duration deletingInterval;
  final Duration holdAfterTyped;
  final Duration holdAfterCleared;
  final Duration cursorBlinkDuration;
  final Duration tickDuration;
  final double fontSize;
  final FontWeight fontWeight;
  final double cursorWidth;
  final double cursorHeight;
  final double cursorBottomPadding;
  final double headlineBlockHeight;

  const TypingTextConfig({
    required this.phrases,
    this.typingInterval      = _kTypingInterval,
    this.deletingInterval    = _kDeletingInterval,
    this.holdAfterTyped      = _kHoldAfterTyped,
    this.holdAfterCleared    = _kHoldAfterCleared,
    this.cursorBlinkDuration = _kCursorBlink,
    this.tickDuration        = _kTickDuration,
    this.fontSize            = _kTypingFontSize,
    this.fontWeight          = _kTypingFontWeight,
    this.cursorWidth         = _kCursorWidth,
    this.cursorHeight        = _kCursorHeight,
    this.cursorBottomPadding = _kCursorBottomPadding,
    this.headlineBlockHeight = _kHeadlineBlockHeight,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// TypingHeadline
// ─────────────────────────────────────────────────────────────────────────────

class TypingHeadline extends StatefulWidget {
  final TypingTextConfig config;
  const TypingHeadline({super.key, required this.config});

  @override
  State<TypingHeadline> createState() => _TypingHeadlineState();
}

class _TypingHeadlineState extends State<TypingHeadline>
    with SingleTickerProviderStateMixin {

  late final AnimationController _cursorCtrl;
  Timer? _timer;
  int _phraseIndex = 0;
  int _charIndex   = 0;
  bool _deleting   = false;
  Duration _elapsed = Duration.zero;
  String _displayed = '';

  TypingTextConfig get _cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(vsync: this, duration: _cfg.cursorBlinkDuration)
      ..repeat(reverse: true);
    _timer = Timer.periodic(_cfg.tickDuration, (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final phrase = _cfg.phrases[_phraseIndex];
    _elapsed += _cfg.tickDuration;
    setState(() {
      if (!_deleting) {
        if (_charIndex < phrase.length) {
          if (_elapsed >= _cfg.typingInterval) {
            _charIndex++;
            _displayed = phrase.substring(0, _charIndex);
            _elapsed   = Duration.zero;
          }
        } else if (_elapsed >= _cfg.holdAfterTyped) {
          _deleting = true;
          _elapsed  = Duration.zero;
        }
      } else {
        if (_charIndex > 0) {
          if (_elapsed >= _cfg.deletingInterval) {
            _charIndex--;
            _displayed = phrase.substring(0, _charIndex);
            _elapsed   = Duration.zero;
          }
        } else if (_elapsed >= _cfg.holdAfterCleared) {
          _deleting    = false;
          _phraseIndex = (_phraseIndex + 1) % _cfg.phrases.length;
          _charIndex   = 0;
          _displayed   = '';
          _elapsed     = Duration.zero;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cfg.headlineBlockHeight,
      child: Center(
        child: ShaderMask(
          shaderCallback: (b) => AppGradients.button.createShader(b),
          blendMode: BlendMode.srcIn,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _displayed,
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  fontSize:   _cfg.fontSize,
                  height:     1.1,
                  fontWeight: _cfg.fontWeight,
                  color:      AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              FadeTransition(
                opacity: _cursorCtrl,
                child: Padding(
                  padding: EdgeInsets.only(bottom: _cfg.cursorBottomPadding),
                  child: Container(
                    width:  _cfg.cursorWidth,
                    height: _cfg.cursorHeight,
                    decoration: BoxDecoration(
                      color:        AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(_cfg.cursorWidth / 2),
                    ),
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


// ─────────────────────────────────────────────────────────────────────────────
// BorderTriggerMode
// ─────────────────────────────────────────────────────────────────────────────

/// Controls when [AnimatedGradientBorder] activates its arc animation.
///
/// [interactive] — activates when [AnimatedGradientBorder.isActive] is true.
///                 Drive it with a hover/focus state from outside the widget.
/// [periodic]    — self-fires on a timer. [isActive] is ignored. Use this for
///                 primary CTAs where you want an organic attention pulse.
enum BorderTriggerMode { interactive, periodic }


// ─────────────────────────────────────────────────────────────────────────────
// AnimatedGradientBorder
// ─────────────────────────────────────────────────────────────────────────────
//
// Wraps any widget and paints a gradient arc traveling the border edge.
//
// USAGE — interactive (hover):
//   MouseRegion(
//     onEnter: (_) => setState(() => _hovered = true),
//     onExit:  (_) => setState(() => _hovered = false),
//     child: AnimatedGradientBorder(
//       isActive: _hovered, borderRadius: AppRadius.cardBR, child: myCard,
//     ),
//   )
//
// USAGE — periodic (CTA attention pulse):
//   AnimatedGradientBorder(
//     triggerMode: BorderTriggerMode.periodic,
//     borderRadius: AppRadius.pillBR,
//     child: myButton,
//   )

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final BorderRadius borderRadius;
  final double strokeWidth;
  final Gradient? gradient;
  final double arcFraction;
  final Duration loopDuration;
  final Duration fadeDuration;
  final bool showStaticBorder;
  final Color staticBorderColor;
  final BorderTriggerMode triggerMode;
  final Duration triggerInterval;
  final Duration activeDuration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.borderRadius,
    this.isActive           = false,
    this.strokeWidth        = _kBorderStrokeWidth,
    this.gradient,
    this.arcFraction        = _kBorderArcFraction,
    this.loopDuration       = _kBorderLoopDuration,
    this.fadeDuration       = _kBorderFadeDuration,
    this.showStaticBorder   = true,
    this.staticBorderColor  = AppColors.border,
    this.triggerMode        = BorderTriggerMode.interactive,
    this.triggerInterval    = _kBorderTriggerInterval,
    this.activeDuration     = _kBorderActiveDuration,
  });

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with TickerProviderStateMixin {

  late final AnimationController _fadeCtrl;
  late final AnimationController _loopCtrl;
  late final Animation<double>   _fadeAnim;
  Timer? _periodicTimer;
  bool _cycleRunning = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: widget.fadeDuration);
    _loopCtrl = AnimationController(vsync: this, duration: widget.loopDuration);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    if (widget.triggerMode == BorderTriggerMode.periodic) {
      // Short initial delay so page load doesn't immediately flash.
      Timer(const Duration(milliseconds: 1200), () {
        if (mounted) _runCycle();
      });
      _periodicTimer = Timer.periodic(widget.triggerInterval, (_) {
        if (mounted && !_cycleRunning) _runCycle();
      });
    } else if (widget.isActive) {
      _activate();
    }
  }

  void _runCycle() {
    if (_cycleRunning) return;
    _cycleRunning = true;
    _activate();
    Future.delayed(widget.activeDuration, () {
      if (mounted) {
        _deactivate();
        _cycleRunning = false;
      }
    });
  }

  void _activate()   { _loopCtrl.repeat(); _fadeCtrl.forward(); }
  void _deactivate() {
    _fadeCtrl.reverse().whenComplete(() {
      if (mounted) _loopCtrl.stop();
    });
  }

  @override
  void didUpdateWidget(AnimatedGradientBorder old) {
    super.didUpdateWidget(old);
    if (widget.triggerMode == BorderTriggerMode.periodic) return;
    if (widget.isActive == old.isActive) return;
    widget.isActive ? _activate() : _deactivate();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _fadeCtrl.dispose();
    _loopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppGradients.button;
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnim, _loopCtrl]),
      builder: (_, child) => CustomPaint(
        painter: _GradientBorderPainter(
          loopT:        _loopCtrl.value,
          opacity:      _fadeAnim.value,
          arcFraction:  widget.arcFraction,
          strokeWidth:  widget.strokeWidth,
          gradient:     gradient,
          borderRadius: widget.borderRadius,
          staticColor:  widget.staticBorderColor,
          showStatic:   widget.showStaticBorder,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double loopT;
  final double opacity;
  final double arcFraction;
  final double strokeWidth;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final Color staticColor;
  final bool showStatic;

  const _GradientBorderPainter({
    required this.loopT,       required this.opacity,
    required this.arcFraction, required this.strokeWidth,
    required this.gradient,    required this.borderRadius,
    required this.staticColor, required this.showStatic,
  });

  RRect _rrect(Size size) {
    final i = strokeWidth / 2;
    return borderRadius.toRRect(
        Rect.fromLTWH(i, i, size.width - i * 2, size.height - i * 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect  = _rrect(size);

    if (showStatic) {
      canvas.drawRRect(rrect, Paint()
        ..color       = staticColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
    }
    if (opacity <= 0.0) return;

    final metric = (Path()..addRRect(rrect)).computeMetrics().first;
    final total  = metric.length;
    final arcLen = total * arcFraction.clamp(0.0, 1.0);
    final start  = (loopT * total) % total;
    final end    = start + arcLen;

    final arc = end <= total
        ? metric.extractPath(start, end)
        : (metric.extractPath(start, total)
          ..addPath(metric.extractPath(0, end % total), Offset.zero));

    canvas.saveLayer(bounds,
        Paint()..color = Color.fromARGB(
            (255 * opacity.clamp(0.0, 1.0)).round(), 255, 255, 255));
    canvas.drawPath(arc, Paint()
      ..shader      = gradient.createShader(bounds)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.6
      ..strokeCap   = StrokeCap.round
      ..strokeJoin  = StrokeJoin.round);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) =>
      old.loopT != loopT || old.opacity != opacity;
}


// ─────────────────────────────────────────────────────────────────────────────
// AnimatedGradientSurface
// ─────────────────────────────────────────────────────────────────────────────
//
// A container whose gradient alignment shifts continuously, giving the surface
// warmth and life without distracting the eye. Use for CTA banners, hero
// feature card backgrounds, and promotional sections.
//
// USAGE:
//   AnimatedGradientSurface(
//     borderRadius: AppRadius.cardBR,
//     child: myContent,
//   )

class AnimatedGradientSurface extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AnimatedGradientSurface({
    super.key,
    required this.child,
    this.colors,
    this.duration     = _kSurfaceGradientDuration,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  State<AnimatedGradientSurface> createState() =>
      _AnimatedGradientSurfaceState();
}

class _AnimatedGradientSurfaceState extends State<AnimatedGradientSurface>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors ??
        [AppColors.primaryDeep, AppColors.primary, AppColors.primaryDark];

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final t     = _anim.value;
        final begin = Alignment.lerp(Alignment.topLeft, Alignment.centerRight, t * 0.4)!;
        final end   = Alignment.lerp(Alignment.bottomRight, Alignment.centerLeft, t * 0.4)!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin, end: end,
              colors: c,
              stops: const [0.0, 0.45, 1.0],
            ),
            borderRadius: widget.borderRadius,
            border:       widget.border,
            boxShadow:    widget.boxShadow,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// ParallaxConfig
// ─────────────────────────────────────────────────────────────────────────────
//
// Controls how a [ParallaxLayer] responds to scroll offset.
//
// DEPTH FACTOR GUIDE:
//   0.15 — nearly-fixed background (hero images, canvas)
//   0.30 — standard landing-page depth (recommended default)
//   0.55 — mid-ground floating elements
//   0.80 — shallow foreground elements
//   1.00 — matches scroll speed (no parallax effect)

class ParallaxConfig {
  final double factor;
  final double maxOffset;
  final Axis direction;
  final bool enabled;

  const ParallaxConfig({
    this.factor    = _kParallaxFactor,
    this.maxOffset = _kParallaxMaxOffset,
    this.direction = Axis.vertical,
    this.enabled   = true,
  });

  static const background    = ParallaxConfig(factor: 0.30);
  static const midground     = ParallaxConfig(factor: 0.55);
  static const foreground    = ParallaxConfig(factor: 0.80);
  static const heroBackground = ParallaxConfig(factor: 0.15, maxOffset: 80);
}


// ─────────────────────────────────────────────────────────────────────────────
// ParallaxLayer
// ─────────────────────────────────────────────────────────────────────────────
//
// Translates [child] at a fraction of scroll speed for depth.
// As the user scrolls down N px, the child translates upward N × factor px.
//
// USAGE — inside a Stack with a SingleChildScrollView:
//
//   Stack(children: [
//     Positioned.fill(
//       child: ParallaxLayer(
//         scrollController: _scrollCtrl,
//         config: ParallaxConfig.background,
//         child: AppCanvas(child: const SizedBox.expand()),
//       ),
//     ),
//     SingleChildScrollView(controller: _scrollCtrl, child: pageContent),
//   ])
//
// Must be inside a widget with bounded size (Positioned.fill / SizedBox.expand).

class ParallaxLayer extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;
  final ParallaxConfig config;

  const ParallaxLayer({
    super.key,
    required this.child,
    required this.scrollController,
    this.config = ParallaxConfig.background,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.enabled) return child;

    return AnimatedBuilder(
      animation: scrollController,
      builder: (_, innerChild) {
        final rawOffset  = scrollController.hasClients ? scrollController.offset : 0.0;
        final clamped    = (rawOffset * config.factor).clamp(0.0, config.maxOffset);
        final translate  = config.direction == Axis.vertical
            ? Offset(0, -clamped)
            : Offset(-clamped, 0);
        return Transform.translate(offset: translate, child: innerChild);
      },
      child: child,
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AppShimmer — loading skeleton shimmer wrapper
// ─────────────────────────────────────────────────────────────────────────────
//
// Wraps any placeholder widget tree in a sweeping gradient shimmer.
// The child provides structure — the shimmer provides the moving highlight.
//
// USAGE:
//   AppShimmer(
//     child: Container(height: 20, width: 180, color: AppColors.surface),
//   )

class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration       = _kShimmerDuration,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..repeat();
    _anim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor      ?? AppColors.surface;
    final high = widget.highlightColor ?? AppColors.surfaceLit;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin:  Alignment(_anim.value - 1, 0),
          end:    Alignment(_anim.value,     0),
          colors: [base, high, high, base],
          stops:  const [0.0, 0.35, 0.65, 1.0],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AppStagger — staggered list reveal
// ─────────────────────────────────────────────────────────────────────────────
//
// Reveals children one after another with a configurable delay and slide.
// Auto-starts on mount. Force a replay by providing a new key.

class AppStagger extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final double slideOffset;
  final Curve curve;
  final Axis direction;

  const AppStagger({
    super.key,
    required this.children,
    this.itemDelay    = _kStaggerItemDelay,
    this.itemDuration = _kStaggerItemDuration,
    this.slideOffset  = _kStaggerSlideOffset,
    this.curve        = Curves.easeOut,
    this.direction    = Axis.vertical,
  });

  @override
  State<AppStagger> createState() => _AppStaggerState();
}

class _AppStaggerState extends State<AppStagger> with TickerProviderStateMixin {
  final List<AnimationController> _ctrl  = [];
  final List<Animation<double>>   _fade  = [];
  final List<Animation<double>>   _slide = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.children.length; i++) {
      final c = AnimationController(vsync: this, duration: widget.itemDuration);
      _ctrl.add(c);
      _fade.add(CurvedAnimation(parent: c, curve: widget.curve));
      _slide.add(
        Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
          CurvedAnimation(parent: c, curve: widget.curve),
        ),
      );
      Future.delayed(widget.itemDelay * i, () { if (mounted) c.forward(); });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.children.length, (i) => AnimatedBuilder(
        animation: _ctrl[i],
        builder: (_, child) {
          final offset = widget.direction == Axis.vertical
              ? Offset(0, _slide[i].value)
              : Offset(_slide[i].value, 0);
          return Opacity(
            opacity: _fade[i].value.clamp(0.0, 1.0),
            child: Transform.translate(offset: offset, child: child),
          );
        },
        child: widget.children[i],
      )),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AppRevealController + AppReveal — controller-driven fade + slide
// ─────────────────────────────────────────────────────────────────────────────
//
// Unlike AppStagger (auto), AppReveal is triggered by controller.forward().
// Use for tab-switch reveals, route-arrival animations, or scroll-triggered
// section reveals.

class AppRevealController extends AnimationController {
  AppRevealController({required super.vsync}) : super(duration: _kRevealDuration);
}

class AppReveal extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final double slideOffset;
  final Axis direction;
  final Curve curve;

  const AppReveal({
    super.key,
    required this.controller,
    required this.child,
    this.slideOffset = _kRevealSlideOffset,
    this.direction   = Axis.vertical,
    this.curve       = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    final fade  = CurvedAnimation(parent: controller, curve: curve);
    final slide = Tween<double>(begin: slideOffset, end: 0.0).animate(fade);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final offset = direction == Axis.vertical
            ? Offset(0, slide.value)
            : Offset(slide.value, 0);
        return Opacity(
          opacity: fade.value.clamp(0.0, 1.0),
          child: Transform.translate(offset: offset, child: child),
        );
      },
      child: child,
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AppScale — scale-in on mount
// ─────────────────────────────────────────────────────────────────────────────
//
// Scales child from scaleFrom → 1.0 with a simultaneous fade.
// easeOutBack default gives a confident slight overshoot.
// Use for dialogs, badges, notification toasts, and tooltips appearing.

class AppScale extends StatefulWidget {
  final Widget child;
  final double scaleFrom;
  final Duration duration;
  final Curve curve;

  const AppScale({
    super.key,
    required this.child,
    this.scaleFrom = _kScaleFrom,
    this.duration  = _kScaleDuration,
    this.curve     = Curves.easeOutBack,
  });

  @override
  State<AppScale> createState() => _AppScaleState();
}

class _AppScaleState extends State<AppScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: widget.duration)..forward();
    final curved = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _scale = Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(curved);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, child) => Opacity(
      opacity: _fade.value.clamp(0.0, 1.0),
      child: Transform.scale(scale: _scale.value, child: child),
    ),
    child: widget.child,
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// AppPageTransitions — GoRouter page transition builders
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppPageTransitions {

  /// Subtle upward fade — default for most navigations.
  static Page<void> fadeSlide(BuildContext ctx, GoRouterState s, Widget child,
      {Duration duration = _kPageTransitionDuration}) =>
      CustomTransitionPage<void>(
        key: s.pageKey, child: child,
        transitionDuration: duration, reverseTransitionDuration: duration,
        transitionsBuilder: (_, animation, _, child) {
          final fade  = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final slide = Tween<Offset>(
              begin: const Offset(0, 0.04), end: Offset.zero).animate(fade);
          return FadeTransition(opacity: fade,
              child: SlideTransition(position: slide, child: child));
        },
      );

  /// Horizontal slide — sibling screens at the same nav level.
  static Page<void> slide(BuildContext ctx, GoRouterState s, Widget child,
      {Duration duration = _kPageTransitionDuration, bool fromRight = true}) =>
      CustomTransitionPage<void>(
        key: s.pageKey, child: child,
        transitionDuration: duration, reverseTransitionDuration: duration,
        transitionsBuilder: (_, animation, _, child) {
          final c  = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final sl = Tween<Offset>(
              begin: Offset(fromRight ? 0.06 : -0.06, 0), end: Offset.zero).animate(c);
          return FadeTransition(opacity: c,
              child: SlideTransition(position: sl, child: child));
        },
      );

  /// Plain fade — modal-style overlays and dialogs pushed as routes.
  static Page<void> fade(BuildContext ctx, GoRouterState s, Widget child,
      {Duration duration = _kPageTransitionDuration}) =>
      CustomTransitionPage<void>(
        key: s.pageKey, child: child,
        transitionDuration: duration, reverseTransitionDuration: duration,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
      );

  /// Subtle zoom in — modal destinations. Scales 95% → 100% with fade.
  static Page<void> zoom(BuildContext ctx, GoRouterState s, Widget child,
      {Duration duration = _kPageTransitionDuration}) =>
      CustomTransitionPage<void>(
        key: s.pageKey, child: child,
        transitionDuration: duration, reverseTransitionDuration: duration,
        transitionsBuilder: (_, animation, _, child) {
          final c = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return FadeTransition(opacity: c,
              child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(c),
                  child: child));
        },
      );

  /// Slide up — bottom-to-top for sheets promoted to routes.
  static Page<void> slideUp(BuildContext ctx, GoRouterState s, Widget child,
      {Duration duration = _kPageTransitionDuration}) =>
      CustomTransitionPage<void>(
        key: s.pageKey, child: child,
        transitionDuration: duration, reverseTransitionDuration: duration,
        transitionsBuilder: (_, animation, _, child) {
          final c  = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final sl = Tween<Offset>(
              begin: const Offset(0, 0.08), end: Offset.zero).animate(c);
          return FadeTransition(opacity: c,
              child: SlideTransition(position: sl, child: child));
        },
      );
}


// ─────────────────────────────────────────────────────────────────────────────
// AppLoader — branded gradient loading indicator
// ─────────────────────────────────────────────────────────────────────────────

class AppLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Gradient? gradient;

  const AppLoader({
    super.key,
    this.size        = _kLoaderSizeMd,
    this.strokeWidth = _kLoaderStroke,
    this.gradient,
  });

  const AppLoader.small({super.key, this.gradient})
      : size = _kLoaderSizeSm, strokeWidth = _kLoaderStroke - 0.5;

  const AppLoader.large({super.key, this.gradient})
      : size = _kLoaderSizeLg, strokeWidth = _kLoaderStroke + 0.5;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppGradients.button;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _LoaderPainter(
          progress:    _ctrl.value,
          strokeWidth: widget.strokeWidth,
          gradient:    gradient,
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  const _LoaderPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect   = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track ring
    canvas.drawCircle(center, radius, Paint()
      ..color       = AppColors.border
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    // ~252° gradient arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 2 * math.pi - math.pi / 2,
      math.pi * 1.4,
      false,
      Paint()
        ..shader      = gradient.createShader(rect)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap   = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter old) => old.progress != progress;
}