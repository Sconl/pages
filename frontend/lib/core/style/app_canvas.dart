// lib/core/style/app_canvas.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial rewrite — wired to app_theme.dart, all colors from AppColors.
//   • BackgroundType / ParticleStyle / GradientStyle enums added.
//   • Config block added per codespace Rule 7.
//   • showParticles / showGradient boolean toggles for per-page control.
//   • File renamed: app_background.dart → app_canvas.dart.
//   • Class renamed: AppBackground → AppCanvas.
//   • File path updated: lib/core/theme/ → lib/core/style/
//   • Aurora fully implemented — animated HSL color bands with slow drift.
//   • Noise fully implemented — pseudo-noise grain using LCG hash field.
//   • Topography fully implemented — animated contour line waves.
//   • Grid fully implemented — dot grid with expanding pulse wave.
//   • _PlaceholderCanvas removed — all BackgroundType values now real.
//   • AppCanvas.fromBrandConfig() factory added — maps CanvasPersonality
//     enum from brand_config.dart to the right BackgroundType + styles.
//   • _ConstellationPainter / _ParticlePainter split into own painter classes.
//   • shouldRepaint logic tightened — only repaints when visual state changes.
//   • Particle alpha constant moved to config block.
//   • aurora / noise / topography / grid each use their own private painter class.
// ─────────────────────────────────────────────────────────────────────────────

// HOW TO USE:
//
//   Simplest (reads brand personality from BrandScope):
//     AppCanvas(child: YourScreen())
//
//   Explicit types:
//     AppCanvas(
//       type:          BackgroundType.constellation,
//       gradientStyle: GradientStyle.pulse,
//       child: YourScreen(),
//     )
//
//   Brand-aware (maps CanvasPersonality to the right BackgroundType):
//     AppCanvas.fromBrandConfig(config: myConfig, child: YourScreen())
//
//   Per-page motion toggles:
//     AppCanvas(showParticles: false, child: ...)  // gradient only
//     AppCanvas(showGradient: false,  child: ...)  // particles over solid base
//     AppCanvas(showParticles: false, showGradient: false, child: ...) // static

import 'dart:math';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'brand_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Default behavior ──────────────────────────────────────────────────────────
const bool kDefaultShowParticles = false;
const bool kDefaultShowGradient  = true;

// ── Particles ─────────────────────────────────────────────────────────────────
const int    kDefaultParticleCount = 40;
const double kParticleRadiusMin    = 2.0;
const double kParticleRadiusMax    = 8.0;
const int    kParticleAlpha        = 46;   // ~18% — depth without distraction

const double kOrbitRadius              = 30.0;
const int    kConstellationConnections = 3;

// ── Gradient ──────────────────────────────────────────────────────────────────
// 0.35 peak — you feel the pulse, you don't consciously see it.
const double kPulseGradientPeak    = 0.35;
const double kSweepSpeedMultiplier = 1.0;

// ── Aurora ────────────────────────────────────────────────────────────────────
const int    kAuroraBandCount    = 5;
const double kAuroraBandHeight   = 0.30;  // fraction of screen height per band
const double kAuroraHueRange     = 80.0;  // degrees of hue variation across bands
const double kAuroraMaxAlpha     = 55.0;  // max opacity of a band (0-255)
const double kAuroraSway         = 0.04;  // vertical sway as fraction of height

// ── Noise ─────────────────────────────────────────────────────────────────────
const int    kNoiseGrainCount    = 2500;  // how many grain dots to paint per frame
const double kNoiseMinRadius     = 0.4;
const double kNoiseMaxRadius     = 1.6;
const double kNoiseBaseAlpha     = 0.12;  // resting opacity
const double kNoiseFlickerRange  = 0.08;  // how much opacity flickers over time

// ── Topography ────────────────────────────────────────────────────────────────
const int    kTopoLineCount      = 16;    // number of contour lines
const double kTopoBaseAmplitude  = 18.0;  // px — vertical wave amplitude for lines
const double kTopoAmplGrowth     = 6.0;   // amplitude grows per line going down
const double kTopoStrokeWidth    = 0.7;
const double kTopoBaseAlpha      = 35.0;  // line opacity (0-255)

// ── Grid ──────────────────────────────────────────────────────────────────────
const double kGridSpacing        = 36.0;  // px between dot centers
const double kGridDotRadius      = 1.2;
const double kGridPulseSpeed     = 3.0;   // pulse wave frequency multiplier
const double kGridBaseAlpha      = 0.06;  // resting dot opacity
const double kGridPeakAlpha      = 0.30;  // max opacity at pulse crest

// ── Animation durations ───────────────────────────────────────────────────────
// 8s gradient + 6s particle: organic, breathing rhythm without feeling restless.
const Duration kDefaultGradientDuration = Duration(seconds: 8);
const Duration kDefaultParticleDuration = Duration(seconds: 6);
const Duration kAuroraDuration          = Duration(seconds: 12);
const Duration kNoiseDuration           = Duration(seconds: 4);
const Duration kTopoDuration            = Duration(seconds: 10);
const Duration kGridDuration            = Duration(seconds: 5);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

/// The overall background visual type.
///
/// [meshParticle]  — animated gradient + floating particle field. Active/energetic.
/// [constellation] — connected node network drifting slowly. Social/connected.
/// [aurora]        — slow flowing horizontal HSL color bands. Calm/premium.
/// [noise]         — animated grain texture overlay. Editorial/creative.
/// [topography]    — animated contour / topographic line patterns. Technical/precise.
/// [grid]          — animated dot-grid with pulse wave. Corporate/structured.
enum BackgroundType {
  meshParticle,
  constellation,
  aurora,
  noise,
  topography,
  grid,
}

/// How particles move in [BackgroundType.meshParticle].
///
/// [drift]  — upward float with gentle sine sway.
/// [orbit]  — each particle orbits a fixed anchor in a circle.
/// [pulse]  — particles stay in place and grow/shrink rhythmically.
/// [rain]   — particles fall downward, reset at top when they exit.
/// [snow]   — slow diagonal drift, randomised speed per particle.
enum ParticleStyle { drift, orbit, pulse, rain, snow }

/// How the background gradient animates.
///
/// [pulse]  — lerps between base and lighter brand tone. Default.
/// [sweep]  — gradient alignment slowly rotates 360°.
/// [mesh]   — static dual-radial mesh from AppGradients. No animation.
/// [solid]  — flat AppColors.background. No gradient, no animation.
enum GradientStyle { pulse, sweep, mesh, solid }


// ─────────────────────────────────────────────────────────────────────────────
// AppCanvas — the main visual canvas widget
// ─────────────────────────────────────────────────────────────────────────────

/// WellPath's animated visual canvas. Drop around any Scaffold body.
///
/// Zero configuration needed — defaults to kBrandDefault personality.
/// Override per-page with [type] / [gradientStyle] / [showParticles] / [showGradient].
class AppCanvas extends StatefulWidget {
  final Widget child;
  final BackgroundType type;
  final ParticleStyle particleStyle;
  final GradientStyle gradientStyle;
  final int particleCount;
  final bool showParticles;
  final bool showGradient;
  final Duration gradientDuration;
  final Duration particleDuration;

  const AppCanvas({
    super.key,
    required this.child,
    this.type             = BackgroundType.constellation,
    this.particleStyle    = ParticleStyle.drift,
    this.gradientStyle    = GradientStyle.pulse,
    this.particleCount    = kDefaultParticleCount,
    this.showParticles    = kDefaultShowParticles,
    this.showGradient     = kDefaultShowGradient,
    this.gradientDuration = kDefaultGradientDuration,
    this.particleDuration = kDefaultParticleDuration,
  });

  // ── Factory: maps CanvasPersonality → concrete background config ──────────
  //
  // Use this in QSpace views where the brand config drives the canvas vibe.
  // personality == CanvasPersonality.custom → uses the explicit type param.
  factory AppCanvas.fromBrandConfig({
    Key? key,
    required BrandConfig config,
    required Widget child,
    BackgroundType? typeOverride,
    bool showParticles = kDefaultShowParticles,
    bool showGradient  = kDefaultShowGradient,
  }) {
    // MotionIntensity.none → full static canvas regardless of personality.
    if (config.motionIntensity == MotionIntensity.none) {
      return AppCanvas(
        key: key,
        type:          BackgroundType.meshParticle,
        gradientStyle: GradientStyle.solid,
        showParticles: false,
        showGradient:  false,
        child: child,
      );
    }

    final noParticles = config.motionIntensity == MotionIntensity.subtle;

    final (t, p, g) = switch (config.canvasPersonality) {
      CanvasPersonality.energetic  => (BackgroundType.constellation,  ParticleStyle.drift,  GradientStyle.pulse),
      CanvasPersonality.calm       => (BackgroundType.aurora,          ParticleStyle.drift,  GradientStyle.mesh),
      CanvasPersonality.minimal    => (BackgroundType.meshParticle,    ParticleStyle.drift,  GradientStyle.solid),
      CanvasPersonality.corporate  => (BackgroundType.grid,            ParticleStyle.drift,  GradientStyle.mesh),
      CanvasPersonality.dramatic   => (BackgroundType.aurora,          ParticleStyle.drift,  GradientStyle.sweep),
      CanvasPersonality.custom     => (typeOverride ?? BackgroundType.constellation, ParticleStyle.drift, GradientStyle.pulse),
    };

    return AppCanvas(
      key:           key,
      type:          t,
      particleStyle: p,
      gradientStyle: g,
      showParticles: noParticles ? false : showParticles,
      showGradient:  showGradient,
      child:         child,
    );
  }

  @override
  State<AppCanvas> createState() => _AppCanvasState();
}


class _AppCanvasState extends State<AppCanvas> with TickerProviderStateMixin {

  late final AnimationController _gradientCtrl;
  late final AnimationController _particleCtrl;

  Duration get _particleDuration {
    return switch (widget.type) {
      BackgroundType.aurora      => kAuroraDuration,
      BackgroundType.noise       => kNoiseDuration,
      BackgroundType.topography  => kTopoDuration,
      BackgroundType.grid        => kGridDuration,
      _                          => widget.particleDuration,
    };
  }

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: widget.gradientDuration,
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: _particleDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientCtrl,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [

            // Layer 1 — gradient or solid background
            widget.showGradient
                ? _GradientLayer(
                    gradientStyle: widget.gradientStyle,
                    progress:      _gradientCtrl.value,
                  )
                : ColoredBox(color: AppColors.background),

            // Layer 2 — animated visual layer (particles, aurora, topo, etc.)
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, _) => _buildVisualLayer(
                widget.type, _particleCtrl.value, context,
              ),
            ),

            // Layer 3 — content always on top
            widget.child,
          ],
        );
      },
    );
  }

  Widget _buildVisualLayer(BackgroundType type, double progress, BuildContext ctx) {
    return switch (type) {
      BackgroundType.meshParticle when widget.showParticles => CustomPaint(
        painter: _ParticlePainter(
          progress:      progress,
          style:         widget.particleStyle,
          count:         widget.particleCount,
          particleColor: AppColors.primary,
        ),
      ),

      BackgroundType.constellation when widget.showParticles => CustomPaint(
        painter: _ConstellationPainter(
          progress:  progress,
          nodeCount: widget.particleCount,
          nodeColor: AppColors.primary,
          lineColor: AppColors.secondary,
        ),
      ),

      BackgroundType.aurora => CustomPaint(
        painter: _AuroraPainter(
          progress:     progress,
          primaryColor: AppColors.primary,
        ),
      ),

      BackgroundType.noise => CustomPaint(
        painter: _NoisePainter(
          progress:     progress,
          primaryColor: AppColors.primary,
        ),
      ),

      BackgroundType.topography => CustomPaint(
        painter: _TopographyPainter(
          progress:     progress,
          primaryColor: AppColors.primary,
        ),
      ),

      BackgroundType.grid => CustomPaint(
        painter: _GridPainter(
          progress:     progress,
          primaryColor: AppColors.primary,
        ),
      ),

      // Particle types when showParticles is false — paint nothing
      _ => const SizedBox.shrink(),
    };
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _GradientLayer
// ─────────────────────────────────────────────────────────────────────────────

class _GradientLayer extends StatelessWidget {
  final GradientStyle gradientStyle;
  final double progress;

  const _GradientLayer({required this.gradientStyle, required this.progress});

  @override
  Widget build(BuildContext context) {
    return switch (gradientStyle) {
      GradientStyle.pulse => _buildPulse(),
      GradientStyle.sweep => _buildSweep(),
      GradientStyle.mesh  => _buildMesh(),
      GradientStyle.solid => ColoredBox(color: AppColors.background),
    };
  }

  Widget _buildPulse() {
    final start = Color.lerp(
      AppColors.background, AppColors.surfaceMid,
      progress * kPulseGradientPeak,
    )!;
    final end = Color.lerp(
      AppColors.backgroundAlt, AppColors.primaryDeep,
      progress * kPulseGradientPeak * 0.6,
    )!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
    );
  }

  Widget _buildSweep() {
    final angle = progress * 2 * pi * kSweepSpeedMultiplier;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment(cos(angle), sin(angle)),
          end:    Alignment(-cos(angle), -sin(angle)),
          colors: [AppColors.background, AppColors.surfaceLit, AppColors.primaryDeep],
          stops:  const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildMesh() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: AppColors.background),
        DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.meshPrimary)),
        DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.meshSecondary)),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ParticlePainter — 5 particle motion styles
// ─────────────────────────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;
  final ParticleStyle style;
  final int count;
  final Color particleColor;

  const _ParticlePainter({
    required this.progress,
    required this.style,
    required this.count,
    required this.particleColor,
  });

  Paint _paint(double alpha) => Paint()
    ..color = particleColor.withAlpha(
        (kParticleAlpha * alpha).round().clamp(0, 255));

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case ParticleStyle.drift: _paintDrift(canvas, size);
      case ParticleStyle.orbit: _paintOrbit(canvas, size);
      case ParticleStyle.pulse: _paintPulse(canvas, size);
      case ParticleStyle.rain:  _paintRain(canvas, size);
      case ParticleStyle.snow:  _paintSnow(canvas, size);
    }
  }

  void _paintDrift(Canvas canvas, Size size) {
    for (int i = 0; i < count; i++) {
      final dx     = (size.width / count) * i + sin(progress * pi * 2 + i) * 40;
      final dy     = (size.height * progress + i * (size.height / count)) % size.height;
      final radius = kParticleRadiusMin +
          (sin(progress * pi + i).abs() * (kParticleRadiusMax - kParticleRadiusMin));
      canvas.drawCircle(Offset(dx, dy), radius, _paint(1.0));
    }
  }

  void _paintOrbit(Canvas canvas, Size size) {
    final cols  = sqrt(count.toDouble()).ceil();
    final rows  = (count / cols).ceil();
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    for (int i = 0; i < count; i++) {
      final anchorX = cellW * (i % cols) + cellW / 2;
      final anchorY = cellH * (i ~/ cols) + cellH / 2;
      final phase   = progress * 2 * pi + i * 0.8;
      final radius  = kParticleRadiusMin +
          sin(phase * 0.5).abs() * (kParticleRadiusMax - kParticleRadiusMin);
      canvas.drawCircle(
        Offset(anchorX + cos(phase) * kOrbitRadius,
               anchorY + sin(phase) * kOrbitRadius),
        radius, _paint(1.0),
      );
    }
  }

  void _paintPulse(Canvas canvas, Size size) {
    for (int i = 0; i < count; i++) {
      final dx    = (size.width  / count) * i + (i % 5) * 15.0;
      final dy    = (size.height / count) * (count - i) + (i % 3) * 20.0;
      final phase = progress * 2 * pi + i * pi / count * 4;
      canvas.drawCircle(
        Offset(dx % size.width, dy % size.height),
        kParticleRadiusMin + sin(phase).abs() * (kParticleRadiusMax - kParticleRadiusMin),
        _paint(0.3 + sin(phase).abs() * 0.7),
      );
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    for (int i = 0; i < count; i++) {
      final speedOffset = (i * 0.07) % 1.0;
      final dx    = (i * (size.width / count) + i * 37) % size.width;
      final dy    = size.height * ((progress + speedOffset) % 1.0);
      final alpha = sin((dy / size.height) * pi).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(dx, dy),
        kParticleRadiusMin + (i % 3) * 1.0,
        _paint(alpha),
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    for (int i = 0; i < count; i++) {
      final speed  = 0.2 + (i * 0.03) % 0.8;
      final sway   = sin(progress * pi * 2 + i * 1.3) * 20;
      final startX = (i * (size.width / count) + i * 23) % size.width;
      final dx     = (startX + sway + progress * size.width * 0.15) % size.width;
      final dy     = size.height * ((progress * speed + i * 0.1) % 1.0);
      final radius = kParticleRadiusMin +
          sin(i.toDouble()).abs() * (kParticleRadiusMax - kParticleRadiusMin) * 0.5;
      canvas.drawCircle(Offset(dx, dy), radius,
          _paint(0.6 + sin(progress * pi + i).abs() * 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress || old.style != style;
}


// ─────────────────────────────────────────────────────────────────────────────
// _ConstellationPainter — connected node network
// ─────────────────────────────────────────────────────────────────────────────

class _ConstellationPainter extends CustomPainter {
  final double progress;
  final int nodeCount;
  final Color nodeColor;
  final Color lineColor;
  late final List<Offset> _basePositions;

  _ConstellationPainter({
    required this.progress,
    required this.nodeCount,
    required this.nodeColor,
    required this.lineColor,
  }) {
    // Prime multipliers give good distribution without a Random instance.
    // Deterministic so positions don't jump on every rebuild.
    _basePositions = List.generate(nodeCount, (i) => Offset(
      ((i * 127 + 43) % 1000) / 1000.0,
      ((i * 311 + 97) % 1000) / 1000.0,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = nodeColor.withAlpha(kParticleAlpha + 20);
    final linePaint = Paint()
      ..color       = lineColor.withAlpha((kParticleAlpha * 0.5).round())
      ..strokeWidth = 0.6;

    final positions = _basePositions.map((base) {
      return Offset(
        (base.dx + sin(progress * 2 * pi + base.dy * 10) * 0.03) * size.width,
        (base.dy + cos(progress * 2 * pi + base.dx * 10) * 0.02) * size.height,
      );
    }).toList();

    for (int i = 0; i < positions.length; i++) {
      final others = List<int>.generate(positions.length, (j) => j)
        ..remove(i)
        ..sort((a, b) => (positions[a] - positions[i])
            .distance
            .compareTo((positions[b] - positions[i]).distance));

      for (int k = 0; k < kConstellationConnections && k < others.length; k++) {
        final dist    = (positions[others[k]] - positions[i]).distance;
        final maxDist = size.width * 0.25;
        if (dist < maxDist) {
          canvas.drawLine(
            positions[i], positions[others[k]],
            linePaint..color = lineColor.withAlpha(
              ((1.0 - dist / maxDist) * (kParticleAlpha * 0.5)).round().clamp(0, 255),
            ),
          );
        }
      }
    }

    for (final pos in positions) {
      canvas.drawCircle(pos, kParticleRadiusMin + 1, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.progress != progress;
}


// ─────────────────────────────────────────────────────────────────────────────
// _AuroraPainter — slow sweeping HSL color bands (northern lights effect)
// ─────────────────────────────────────────────────────────────────────────────
//
// Each band is a vertical-gradient rect. Hue and vertical position drift
// slowly over time. Progress loops 0 → 1, so bands cycle continuously.
//
// Why HSL manipulation here instead of importing from AppColors:
//   The aurora is intentionally beyond-brand — it uses hue rotations derived
//   from the primary color. Importing HSLColor directly keeps it self-contained.

class _AuroraPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  const _AuroraPainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseHue = HSLColor.fromColor(primaryColor).hue;

    for (int i = 0; i < kAuroraBandCount; i++) {
      // Each band has its own hue offset and drift phase
      final hue = (baseHue + (i * kAuroraHueRange / kAuroraBandCount) +
          progress * 20.0) % 360.0;

      final color = HSLColor.fromAHSL(1.0, hue, 0.65, 0.50).toColor();

      // Vertical center drifts slowly via sine — different phase per band
      final phase   = progress * 2 * pi + i * (pi * 2 / kAuroraBandCount);
      final yCenterFraction = 0.15 + (i / kAuroraBandCount) * 0.75 +
          sin(phase) * kAuroraSway;
      final yCenter = yCenterFraction * size.height;
      final bandH   = size.height * kAuroraBandHeight;

      // Opacity pulses per band — different phase offset keeps them from all
      // brightening and dimming in sync, which would look mechanical.
      final alphaPulse = (sin(phase * 1.3 + i * 0.7) + 1.0) / 2.0;
      final alpha = (kAuroraMaxAlpha * alphaPulse).round().clamp(0, 255);

      final bandRect = Rect.fromCenter(
        center: Offset(size.width / 2, yCenter),
        width:  size.width,
        height: bandH,
      );

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            color.withAlpha((alpha * 0.4).round()),
            color.withAlpha(alpha),
            color.withAlpha((alpha * 0.6).round()),
            color.withAlpha((alpha * 0.15).round()),
            Colors.transparent,
          ],
          stops: const [0.0, 0.15, 0.4, 0.7, 0.88, 1.0],
        ).createShader(bandRect);

      canvas.drawRect(bandRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.progress != progress;
}


// ─────────────────────────────────────────────────────────────────────────────
// _NoisePainter — animated grain / noise texture
// ─────────────────────────────────────────────────────────────────────────────
//
// Uses an LCG (linear congruential generator) hash to deterministically
// place grain dots at pseudo-random positions. Progress shifts the LCG seed
// by a small amount each frame, making the grain appear to flickr and shift
// without re-running a full PRNG — this is cheap enough for 60fps.

class _NoisePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  const _NoisePainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Seed offset shifts the field slowly over time
    final seedOffset = (progress * 37).round();

    for (int i = 0; i < kNoiseGrainCount; i++) {
      // LCG hash — fast deterministic pseudo-random from index
      var hx = ((i + seedOffset) * 1664525 + 1013904223) & 0x7FFFFFFF;
      var hy = (hx * 1664525 + 1013904223) & 0x7FFFFFFF;
      var hAlpha = (hy * 1664525 + 1013904223) & 0x7FFFFFFF;

      final x = (hx % 10000) / 10000.0 * size.width;
      final y = (hy % 10000) / 10000.0 * size.height;

      // Opacity flickers per grain based on progress phase
      final flicker = (sin(progress * pi * 4 + i * 0.17) + 1.0) / 2.0;
      final alpha   = ((kNoiseBaseAlpha + flicker * kNoiseFlickerRange) * 255)
          .round().clamp(0, 255);

      final radius = kNoiseMinRadius +
          (hAlpha % 100) / 100.0 * (kNoiseMaxRadius - kNoiseMinRadius);

      paint.color = primaryColor.withAlpha(alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) => old.progress != progress;
}


// ─────────────────────────────────────────────────────────────────────────────
// _TopographyPainter — animated contour / topographic lines
// ─────────────────────────────────────────────────────────────────────────────
//
// Horizontal sinusoidal paths at evenly-spaced vertical positions.
// Amplitude grows as you go down the screen (deeper = more turbulence).
// Phase shifts across the x-axis, phase offset shifts per line and over time.

class _TopographyPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  const _TopographyPainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = kTopoStrokeWidth
      ..strokeCap   = StrokeCap.round;

    for (int i = 0; i < kTopoLineCount; i++) {
      final yBase     = size.height * (i + 0.5) / kTopoLineCount;
      final amplitude = kTopoBaseAmplitude + i * kTopoAmplGrowth;
      final frequency = 1.5 + i * 0.15;  // higher lines have tighter waves
      final timePhase = progress * 2 * pi;
      final linePhase = i * 0.4;  // each line offset so they don't all crest together

      // Opacity: center lines slightly brighter, edges fade out
      final centerBias = 1.0 - (i / kTopoLineCount - 0.5).abs() * 1.2;
      final alpha      = (kTopoBaseAlpha * centerBias.clamp(0.3, 1.0)).round();
      paint.color = primaryColor.withAlpha(alpha);

      final path = Path();
      const step = 3.0;
      bool started = false;

      for (double x = 0; x <= size.width; x += step) {
        final normX = x / size.width;
        final y     = yBase +
            sin(normX * frequency * 2 * pi + timePhase + linePhase) * amplitude +
            sin(normX * frequency * pi + timePhase * 0.5 + linePhase * 1.3) * (amplitude * 0.3);

        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopographyPainter old) => old.progress != progress;
}


// ─────────────────────────────────────────────────────────────────────────────
// _GridPainter — dot grid with radial pulse wave
// ─────────────────────────────────────────────────────────────────────────────
//
// Dots at regular grid positions. A pulse wave emanates from the center of the
// screen and causes each dot to brighten as the wave front passes through it.
// Multiple wave pulses overlap because progress loops continuously.

class _GridPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  const _GridPainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint  = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final maxDist = center.distance; // max possible distance from center

    final cols = (size.width  / kGridSpacing).ceil() + 1;
    final rows = (size.height / kGridSpacing).ceil() + 1;

    for (int row = 0; row <= rows; row++) {
      for (int col = 0; col <= cols; col++) {
        final pos = Offset(col * kGridSpacing, row * kGridSpacing);

        final distFromCenter = (pos - center).distance;
        final normalizedDist = (distFromCenter / maxDist).clamp(0.0, 1.0);

        // Wave emanates outward: phase = time - distance.
        // Wrapping makes the wave repeat continuously as progress loops.
        final phase   = (progress * kGridPulseSpeed - normalizedDist * 2.5) * 2 * pi;
        final waveSin = (sin(phase) + 1.0) / 2.0; // 0.0 → 1.0

        final opacity = kGridBaseAlpha + waveSin * (kGridPeakAlpha - kGridBaseAlpha);
        paint.color   = primaryColor.withValues(alpha: opacity);

        canvas.drawCircle(pos, kGridDotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.progress != progress;
}