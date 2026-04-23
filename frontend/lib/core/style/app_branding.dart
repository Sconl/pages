// lib/core/style/app_branding.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — elevated to brand foundation layer.
//   • BrandColors / BrandCopy / BrandAssets introduced.
//   • BrandLogo rewritten — asset-first with typographic wordmark fallback.
//   • LogoShape / LogoVariant / LogoSize enums added.
//   • BrandLogoEngine added — 9 named builders (3 shapes × 3 color treatments).
//   • White/black variants derived via ColorFilter — one colored file per shape.
//   • 5-role font system: Hero / Display / Text / Accent / Signature.
//   • CONFIG BLOCK extracted → brand_config.dart. This file is now a pure engine.
//     BrandColors / BrandCopy / BrandAssets read from BrandScope or kBrandDefault.
//     Removing the config block here means a brand only edits one file: brand_config.dart.
//   • BrandColors / BrandCopy / BrandAssets changed from abstract const to
//     context-aware static helpers — BrandScope.of(context) provides the config,
//     static getters fall back to kBrandDefault for non-context usage.
//   • Added BrandColors.fromConfig() / BrandCopy.fromConfig() convenience access.
//   • _BrandLogoTypographic updated — reads from BrandScope at build time.
// ─────────────────────────────────────────────────────────────────────────────

// WHO OWNS THIS FILE:
//   The platform team. Do NOT put brand-specific values here.
//   All values come from brand_config.dart → BrandScope → kBrandDefault.
//   This file is a pure rendering and registration engine.
//
// DEPENDENCY CHAIN:
//   brand_config.dart → app_branding.dart → app_theme.dart → (canvas, decorations, motion)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────
//
// There is intentionally NO config block in this file.
// All brand values live in brand_config.dart.
// Tunable layout/fallback constants for the logo widget live below.

// ── Logo fallback sizing — typographic wordmark only ─────────────────────────
// Controls the fallback text wordmark when no asset renders.
// Asset logo sizing is controlled by width/height passed to BrandLogo directly.
const double _kLogoFontSm = 22.0;
const double _kLogoFontMd = 36.0;
const double _kLogoFontLg = 48.0;
const double _kLogoFontXl = 64.0;

const double _kLogoLetterSpacingSm = 1.0;
const double _kLogoLetterSpacingMd = 1.5;
const double _kLogoLetterSpacingLg = 3.0;
const double _kLogoLetterSpacingXl = 4.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

/// Which logo layout to render.
///
/// [icon]       — mark only, no text. App bars, tight spaces, favicon-scale.
/// [horizontal] — mark beside wordmark. Most common usage.
/// [vertical]   — mark stacked above wordmark. Splash, auth, card headers.
enum LogoShape { icon, horizontal, vertical }

/// Color treatment applied to the logo at render time.
///
/// [colored] — render the asset as-is. No filter.
/// [white]   — force all opaque pixels white via ColorFilter. Dark/colored backgrounds.
/// [black]   — force all opaque pixels black via ColorFilter. Light backgrounds.
///
/// White/black are derived from the colored asset — no separate asset files needed.
enum LogoVariant { colored, white, black }

/// Font size for the typographic fallback wordmark.
/// Irrelevant when a real asset renders — use BrandLogo.width/.height instead.
enum LogoSize { sm, md, lg, xl }


// ─────────────────────────────────────────────────────────────────────────────
// BrandColors — context-aware color access
// ─────────────────────────────────────────────────────────────────────────────
//
// Static getters read kBrandDefault — fast, no context needed, correct for
// standalone apps. For QSpace runtime theming, use Theme.of(context).colorScheme
// which gets populated from AppTheme.forConfig(runtimeConfig).
//
// fromConfig() is used internally by AppTheme.forConfig() to generate ThemeData.

abstract class BrandColors {
  /// Dominant brand color — CTA buttons, hero gradient, focus rings, active states.
  static Color get primary   => kBrandDefault.primary;

  /// Supporting accent — secondary buttons, avatar gradients, constellation lines.
  static Color get secondary => kBrandDefault.secondary;

  /// Warm accent — live badges, tertiary CTAs, notification highlights.
  static Color get tertiary  => kBrandDefault.tertiary;

  /// Access colors for a specific config — used by AppTheme.forConfig().
  static Color primaryOf  (BrandConfig c) => c.primary;
  static Color secondaryOf(BrandConfig c) => c.secondary;
  static Color tertiaryOf (BrandConfig c) => c.tertiary;
}


// ─────────────────────────────────────────────────────────────────────────────
// BrandCopy — identity strings and font role names
// ─────────────────────────────────────────────────────────────────────────────
//
// Static getters read kBrandDefault. For runtime theming, call BrandCopy.from(config).

abstract class BrandCopy {
  // ── Font roles ─────────────────────────────────────────────────────────────

  /// Brand identity + hero moments. <5% of UI. Splash, landing, big statements.
  static String get fontHero      => kBrandDefault.fontHero;

  /// Page/section structure. Headings h1–h5, card titles, modal headers.
  static String get fontDisplay   => kBrandDefault.fontDisplay;

  /// The system workhorse. Body, forms, buttons, inputs, labels — most of the UI.
  static String get fontText      => kBrandDefault.fontText;

  /// Data precision layer. Numbers, stats, timestamps, chips, badges, overlines.
  static String get fontAccent    => kBrandDefault.fontAccent;

  /// Emotional signature. Greetings, milestones, encouragement.
  /// Use sparingly — overuse destroys the effect. Target <3% of visible text.
  static String get fontSignature => kBrandDefault.fontSignature;

  // ── Brand identity ─────────────────────────────────────────────────────────

  /// Bold half of the typographic wordmark — FontWeight.w700.
  static String get wordBold  => kBrandDefault.wordBold;

  /// Light half of the typographic wordmark — FontWeight.w300.
  static String get wordLight => kBrandDefault.wordLight;

  /// Full app name — page titles, notifications, anywhere the split isn't right.
  static String get appName   => kBrandDefault.appName;

  /// Brand tagline — OG descriptions, onboarding subtitles, about screens.
  static String get tagline   => kBrandDefault.tagline;

  /// Canonical domain — link sharing, meta tags, deep link config.
  static String get domain    => kBrandDefault.domain;

  /// Copyright line — footer, legal screen, app info sheet.
  static String get copyright => kBrandDefault.copyright;

  /// Access copy for a specific config instance (runtime theming).
  static String fontTextOf     (BrandConfig c) => c.fontText;
  static String fontDisplayOf  (BrandConfig c) => c.fontDisplay;
  static String fontHeroOf     (BrandConfig c) => c.fontHero;
  static String fontAccentOf   (BrandConfig c) => c.fontAccent;
  static String fontSignatureOf(BrandConfig c) => c.fontSignature;
  static String appNameOf      (BrandConfig c) => c.appName;
}


// ─────────────────────────────────────────────────────────────────────────────
// BrandAssets — complete asset path registry
// ─────────────────────────────────────────────────────────────────────────────
//
// No inline path strings anywhere else in the app. Every asset reference
// goes through here. Context-aware version reads from BrandScope for runtime.

abstract class BrandAssets {
  // ── Animated assets ───────────────────────────────────────────────────────
  static String get headerGifLanding => kBrandDefault.headerGifLandingPath;

  // ── Logos ─────────────────────────────────────────────────────────────────
  // White and black derived at render time — one colored file per shape is enough.
  static String? get logoHorizontal => kBrandDefault.logoHorizontalPath;
  static String? get logoVertical   => kBrandDefault.logoVerticalPath;
  static String? get logoIcon       => kBrandDefault.logoIconPath;

  // ── Web / PWA ─────────────────────────────────────────────────────────────
  static String? get favicon => kBrandDefault.faviconPath;

  // ── App icons — build tooling only ───────────────────────────────────────
  static String? get appIconAndroid => kBrandDefault.appIconAndroidPath;
  static String? get appIconIos     => kBrandDefault.appIconIosPath;

  // ── Social / OG ──────────────────────────────────────────────────────────
  static String get ogImage => kBrandDefault.ogImagePath;

  // ── Feature illustrations ─────────────────────────────────────────────────
  static String get illuBookingsEmpty  => kBrandDefault.illuBookingsEmpty;
  static String get illuWellnessEmpty  => kBrandDefault.illuWellnessEmpty;
  static String get illuTrainersEmpty  => kBrandDefault.illuTrainersEmpty;
  static String get illuOnboardDiscover => kBrandDefault.illuOnboardDiscover;
  static String get illuOnboardLog     => kBrandDefault.illuOnboardLog;
  static String get illuOnboardBook    => kBrandDefault.illuOnboardBook;

  // ── Runtime-aware access (reads from BrandScope) ─────────────────────────
  static String? logoHorizontalOf(BrandConfig c) => c.logoHorizontalPath;
  static String? logoVerticalOf  (BrandConfig c) => c.logoVerticalPath;
  static String? logoIconOf      (BrandConfig c) => c.logoIconPath;
}


// ─────────────────────────────────────────────────────────────────────────────
// BrandLogoEngine — all 9 logo variants as named widget builders
// ─────────────────────────────────────────────────────────────────────────────
//
// 3 shapes × 3 color treatments = 9 named builders.
// Use these throughout the app — clearer intent than constructing BrandLogo
// with raw params every time.
//
// HOW MONO DERIVATION WORKS:
//   ColorFilter.mode(Colors.white, BlendMode.srcIn) → every filled pixel → white,
//   transparent areas stay transparent. Same principle as design-tool recolor.
//   Only one colored SVG per shape needed. No extra white/black asset files.
//
// All methods fall back to the typographic wordmark automatically when the
// asset path is null or the file fails to load.

abstract class BrandLogoEngine {
  // ── Horizontal ────────────────────────────────────────────────────────────

  static Widget horizontalColored({double? width, double? height = 32, LogoSize fallbackSize = LogoSize.md}) =>
      BrandLogo(shape: LogoShape.horizontal, variant: LogoVariant.colored, width: width, height: height, fallbackSize: fallbackSize);

  static Widget horizontalWhite({double? width, double? height = 28, LogoSize fallbackSize = LogoSize.md}) =>
      BrandLogo(shape: LogoShape.horizontal, variant: LogoVariant.white, width: width, height: height, fallbackSize: fallbackSize);

  static Widget horizontalBlack({double? width, double? height = 28, LogoSize fallbackSize = LogoSize.md}) =>
      BrandLogo(shape: LogoShape.horizontal, variant: LogoVariant.black, width: width, height: height, fallbackSize: fallbackSize);

  // ── Vertical ──────────────────────────────────────────────────────────────

  static Widget verticalColored({double? width, double? height = 80, LogoSize fallbackSize = LogoSize.lg}) =>
      BrandLogo(shape: LogoShape.vertical, variant: LogoVariant.colored, width: width, height: height, fallbackSize: fallbackSize);

  static Widget verticalWhite({double? width, double? height = 64, LogoSize fallbackSize = LogoSize.lg}) =>
      BrandLogo(shape: LogoShape.vertical, variant: LogoVariant.white, width: width, height: height, fallbackSize: fallbackSize);

  static Widget verticalBlack({double? width, double? height = 64, LogoSize fallbackSize = LogoSize.lg}) =>
      BrandLogo(shape: LogoShape.vertical, variant: LogoVariant.black, width: width, height: height, fallbackSize: fallbackSize);

  // ── Icon mark ─────────────────────────────────────────────────────────────

  static Widget iconColored({double? width = 40, double? height, LogoSize fallbackSize = LogoSize.sm}) =>
      BrandLogo(shape: LogoShape.icon, variant: LogoVariant.colored, width: width, height: height, fallbackSize: fallbackSize);

  static Widget iconWhite({double? width = 32, double? height, LogoSize fallbackSize = LogoSize.sm}) =>
      BrandLogo(shape: LogoShape.icon, variant: LogoVariant.white, width: width, height: height, fallbackSize: fallbackSize);

  static Widget iconBlack({double? width = 32, double? height, LogoSize fallbackSize = LogoSize.sm}) =>
      BrandLogo(shape: LogoShape.icon, variant: LogoVariant.black, width: width, height: height, fallbackSize: fallbackSize);
}


// ─────────────────────────────────────────────────────────────────────────────
// BrandLogo — asset-first logo widget
// ─────────────────────────────────────────────────────────────────────────────
//
// Reads asset paths from BrandScope at build time — so it works correctly
// with runtime brand configs in QSpace multi-tenant mode.
//
// Prefer BrandLogoEngine.*() over constructing this directly unless you need
// custom fallback colors or a non-standard size.

class BrandLogo extends StatelessWidget {
  final LogoShape  shape;
  final LogoVariant variant;
  final double? width;
  final double? height;
  final LogoSize fallbackSize;
  final Color? boldColor;
  final Color? lightColor;

  const BrandLogo({
    super.key,
    this.shape        = LogoShape.horizontal,
    this.variant      = LogoVariant.colored,
    this.width,
    this.height,
    this.fallbackSize = LogoSize.md,
    this.boldColor,
    this.lightColor,
  });

  String? _assetPath(BrandConfig config) {
    switch (shape) {
      case LogoShape.horizontal: return config.logoHorizontalPath;
      case LogoShape.vertical:   return config.logoVerticalPath;
      case LogoShape.icon:       return config.logoIconPath;
    }
  }

  // null = no filter = render the colored asset as-is.
  ColorFilter? get _colorFilter {
    switch (variant) {
      case LogoVariant.colored: return null;
      case LogoVariant.white:   return const ColorFilter.mode(Colors.white, BlendMode.srcIn);
      case LogoVariant.black:   return const ColorFilter.mode(Colors.black, BlendMode.srcIn);
    }
  }

  double? _computeHeight() {
    if (height != null) return height;
    switch (fallbackSize) {
      case LogoSize.sm: return 22.0;
      case LogoSize.md: return 32.0;
      case LogoSize.lg: return 48.0;
      case LogoSize.xl: return 64.0;
    }
  }

  double? _computeWidth() {
    if (width != null) return width;
    if (shape == LogoShape.icon) {
      switch (fallbackSize) {
        case LogoSize.sm: return 22.0;
        case LogoSize.md: return 32.0;
        case LogoSize.lg: return 48.0;
        case LogoSize.xl: return 64.0;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final config = BrandScope.of(context);
    final path   = _assetPath(config);

    Widget fallback() => _BrandLogoTypographic(
      size:       fallbackSize,
      boldColor:  boldColor  ?? config.logoBoldColor,
      lightColor: lightColor ?? config.logoLightColor,
      fontFamily: config.fontText,
    );

    if (path == null) return fallback();

    final cf = _colorFilter;
    final w  = _computeWidth();
    final h  = _computeHeight();

    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: w,
        height: h,
        colorFilter: cf,
        errorBuilder: (_, _, _) => fallback(),
      );
    }

    // PNG/WebP/JPG/GIF — wrap with ColorFiltered if we need tinting.
    Widget img = Image.asset(
      path,
      width: w,
      height: h,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback(),
    );

    if (cf != null) img = ColorFiltered(colorFilter: cf, child: img);
    return img;
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _BrandLogoTypographic — two-weight RichText wordmark (private fallback)
// ─────────────────────────────────────────────────────────────────────────────
//
// Used only when no asset renders. Takes fontFamily from BrandConfig rather
// than importing app_theme.dart (that would be circular).

class _BrandLogoTypographic extends StatelessWidget {
  final LogoSize size;
  final Color? boldColor;
  final Color? lightColor;
  final String fontFamily;

  const _BrandLogoTypographic({
    this.size       = LogoSize.md,
    this.boldColor,
    this.lightColor,
    this.fontFamily = 'Poppins',
  });

  double get _fontSize {
    switch (size) {
      case LogoSize.sm: return _kLogoFontSm;
      case LogoSize.md: return _kLogoFontMd;
      case LogoSize.lg: return _kLogoFontLg;
      case LogoSize.xl: return _kLogoFontXl;
    }
  }

  double get _letterSpacing {
    switch (size) {
      case LogoSize.sm: return _kLogoLetterSpacingSm;
      case LogoSize.md: return _kLogoLetterSpacingMd;
      case LogoSize.lg: return _kLogoLetterSpacingLg;
      case LogoSize.xl: return _kLogoLetterSpacingXl;
    }
  }

  TextStyle _style(FontWeight weight, Color color) => GoogleFonts.getFont(
    fontFamily,
    fontWeight:    weight,
    fontSize:      _fontSize,
    letterSpacing: _letterSpacing,
    color:         color,
    height:        1.0,
  );

  @override
  Widget build(BuildContext context) {
    final config = BrandScope.of(context);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text:  config.wordBold,
            style: _style(FontWeight.w700, boldColor  ?? config.logoBoldColor),
          ),
          TextSpan(
            text:  config.wordLight,
            style: _style(FontWeight.w300, lightColor ?? config.logoLightColor),
          ),
        ],
      ),
    );
  }
}