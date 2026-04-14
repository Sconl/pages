// lib/core/style/brand_config.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — extracted from app_branding.dart CONFIG BLOCK.
//     Now the single source of truth for all brand-specific values across
//     the entire design system. Every other style file reads from this.
//   • Added BrandConfig immutable data class — holds all brand tokens.
//   • Added kBrandDefault — the static const instance a brand fills in.
//   • Added BrandScope — InheritedWidget for runtime config injection.
//     QSpace merge engine creates a BrandConfig at runtime from client
//     overlay JSON and passes it in here. Zero recompile per tenant.
//   • Added BrandConfig.fromManifest() — parses QSpace overlay.json.
//   • Added BrandConfig.copyWith() — non-destructive mutation for overrides.
//   • Added CanvasPersonality enum — high-level brand vibe selector
//     (maps to concrete BackgroundType / GradientStyle in app_canvas.dart).
//   • Added MotionIntensity enum — accessibility + preference level.
//   • Added QSpaceFeatureFlags — per-suite feature toggles.
// ─────────────────────────────────────────────────────────────────────────────

// WHO OWNS THIS FILE:
//   The branding team. This is the ONLY file that should differ between brands.
//   For a new brand on QSpace, either:
//     A) Update kBrandDefault (standalone app compile) — OR —
//     B) Supply a client overlay.json and let QSpace's merge engine call
//        BrandConfig.fromManifest() at runtime. No recompile needed.
//
// RULE:
//   If a value is brand-specific (a color, font name, logo path, copy string),
//   it belongs here. If it's a derived value or a layout decision, it belongs
//   in the file that uses it (app_theme, app_canvas, etc.).
//
// DEPENDENCY CHAIN:
//   brand_config.dart
//       ↓
//   app_branding.dart  →  app_theme.dart  →  app_canvas.dart
//                                          →  app_decorations.dart
//                                          →  app_motion.dart
//       ↓
//   app_style.dart (barrel — imports all of the above)

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK — fill this in for your brand
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the TEMPLATE. These values ship with WellPath as the default.
// To brand QSpace for a new client:
//   • Standalone compile: update the values below, nothing else.
//   • QSpace multi-tenant: supply a client overlay.json — BrandConfig.fromManifest()
//     creates a runtime instance without touching this file at all.
//
// Steps to configure a new brand from scratch:
//   1. Set 3 color seeds (primary, secondary, tertiary)
//   2. Set 5 font roles (hero, display, text, accent, signature)
//   3. Drop logo SVGs into assets/logos/ and update the 3 paths
//   4. Set identity copy (appName, tagline, domain, copyright, wordBold/Light)
//   5. Pick canvas personality and motion intensity
//   6. Register asset paths in pubspec.yaml under flutter: assets:
//   Done — everything downstream regenerates from these inputs.

// ── Brand color seeds ─────────────────────────────────────────────────────────
// Three seeds. The entire palette — dark mode, light mode, gradients,
// tints, on-colors — derives from these three values in app_theme.dart.
//
// Primary   → dominant identity. Hero gradient, CTA buttons, focus rings.
// Secondary → supporting accent. Info chips, constellation lines, secondary CTAs.
// Tertiary  → warm accent. Live badges, notification highlights, tertiary CTAs.
const Color _kPrimary   = Color(0xFF9933FF); // Deep Violet  — H:270°, S:100%, L:60%
const Color _kSecondary = Color(0xFF0F91D2); // Digital Blue — H:200°, S:87%,  L:44%
const Color _kTertiary  = Color(0xFFFAAF2E); // Kenyan Amber — H:38°,  S:95%,  L:58%

// ── Font roles ────────────────────────────────────────────────────────────────
// Five roles. Swap per role without touching any widget.
const String _kFontHero      = 'Plus Jakarta Sans'; // brand moments, splash, hero
const String _kFontDisplay   = 'Barlow';            // page/section headings
const String _kFontText      = 'Inter';             // body, buttons, inputs (the workhorse)
const String _kFontAccent    = 'JetBrains Mono';    // numbers, stats, timestamps, badges
const String _kFontSignature = 'Niconne';           // greetings, milestones, emotional moments

// ── Logo asset paths ──────────────────────────────────────────────────────────
// One colored file per shape. White/black are derived at render time via
// ColorFilter — you don't need separate mono asset files.
// Formats: SVG preferred. PNG/WebP/JPG also work.
// null = not yet created — BrandLogo falls back to typographic wordmark.
const String _kLogoHorizontal = 'assets/logos/20260326_wellpath_logo_horizontal_primary_color.svg';
const String _kLogoVertical   = 'assets/logos/20260326_wellpath_logo_vertical_primary_color.svg';
const String _kLogoIcon       = 'assets/logos/20260326_wellpath_logo_icon_primary_color.svg';

// ── Supplemental asset paths (all optional) ───────────────────────────────────
const String? _kFavicon        = null; // web/index.html — not a runtime asset
const String? _kAppIconAndroid = null; // flutter_launcher_icons build-time only
const String? _kAppIconIos     = null; // flutter_launcher_icons build-time only
const String  _kOgImage        = 'assets/brand/wellpath_og_1200x630.png';

// ── Animated assets ───────────────────────────────────────────────────────────
const String _kHeaderGifLanding =
    'animated-gifs/20260312_asset_animated_text_wellpath_landing_page_header_v1.0.0.gif';

// ── Feature illustrations ─────────────────────────────────────────────────────
const String _kIlluBookingsEmpty  = 'assets/illustrations/empty_bookings.svg';
const String _kIlluWellnessEmpty  = 'assets/illustrations/empty_wellness.svg';
const String _kIlluTrainersEmpty  = 'assets/illustrations/empty_trainers.svg';
const String _kIlluOnboardDiscover = 'assets/illustrations/onboard_discover.svg';
const String _kIlluOnboardLog     = 'assets/illustrations/onboard_log.svg';
const String _kIlluOnboardBook    = 'assets/illustrations/onboard_book.svg';

// ── Brand identity copy ───────────────────────────────────────────────────────
const String _kWordBold  = 'Well';
const String _kWordLight = 'Path';
const String _kAppName   = 'WellPath';
const String _kTagline   = 'Your fitness journey, connected.';
const String _kDomain    = 'wellpath-fitness.web.app';
const String _kCopyright = '© 2026 WellPath';

// ── Logo fallback colors — typographic fallback only ─────────────────────────
// Only used when no logo asset renders. Mirrors AppColors.textPrimary/Secondary.
// Hardcoded here to avoid circular dependency with app_theme.dart.
const Color _kLogoBoldColor  = Color(0xFFFFFFFF);   // white
const Color _kLogoLightColor = Color(0x8AFFFFFF);   // white 54%

// ── Canvas & motion defaults ──────────────────────────────────────────────────
const CanvasPersonality _kCanvasPersonality = CanvasPersonality.energetic;
const MotionIntensity   _kMotionIntensity   = MotionIntensity.full;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

/// High-level brand canvas "vibe."
/// Maps to concrete BackgroundType / ParticleStyle / GradientStyle in app_canvas.dart.
///
/// [energetic]  — constellation + drift. For active, social, fitness apps.
/// [calm]       — pulse gradient + no particles. Meditative, wellness, spa.
/// [minimal]    — solid background. Clean SaaS, productivity, B2B.
/// [corporate]  — mesh gradient + grid. Enterprise, finance, professional.
/// [dramatic]   — aurora. Creative agencies, portfolio, premium brand.
/// [custom]     — respects the explicit BackgroundType/ParticleStyle passed to AppCanvas.
enum CanvasPersonality {
  energetic,
  calm,
  minimal,
  corporate,
  dramatic,
  custom,
}

/// How much animation the brand uses.
///
/// [none]   — completely static. Best for accessibility (prefers-reduced-motion).
/// [subtle] — gentle gradient transitions only. No particles.
/// [full]   — full animated canvas with particles. Default.
enum MotionIntensity { none, subtle, full }

// ─────────────────────────────────────────────────────────────────────────────
// QSpaceFeatureFlags
// ─────────────────────────────────────────────────────────────────────────────
//
// Suite and client level feature toggles. The QSpace merge engine writes
// these from the resolved manifest. In standalone mode, set them here directly.
//
// These gates are checked at the UI layer to show/hide sections and flows.
// They don't replace server-side auth — they're UX toggles, not security.

class QSpaceFeatureFlags {
  final bool trialSignup;
  final bool pricingTable;
  final bool apiDocs;
  final bool blogSection;
  final bool testimonials;
  final bool liveChat;
  final bool darkModeToggle;
  final bool multiLanguage;
  final bool analyticsConsent;

  const QSpaceFeatureFlags({
    this.trialSignup    = true,
    this.pricingTable   = true,
    this.apiDocs        = false,
    this.blogSection    = false,
    this.testimonials   = true,
    this.liveChat       = false,
    this.darkModeToggle = true,
    this.multiLanguage  = false,
    this.analyticsConsent = true,
  });

  factory QSpaceFeatureFlags.fromJson(Map<String, dynamic> json) {
    return QSpaceFeatureFlags(
      trialSignup:      json['trialSignup']      as bool? ?? true,
      pricingTable:     json['pricingTable']      as bool? ?? true,
      apiDocs:          json['apiDocs']           as bool? ?? false,
      blogSection:      json['blogSection']       as bool? ?? false,
      testimonials:     json['testimonials']      as bool? ?? true,
      liveChat:         json['liveChat']          as bool? ?? false,
      darkModeToggle:   json['darkModeToggle']    as bool? ?? true,
      multiLanguage:    json['multiLanguage']     as bool? ?? false,
      analyticsConsent: json['analyticsConsent']  as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'trialSignup':      trialSignup,
    'pricingTable':     pricingTable,
    'apiDocs':          apiDocs,
    'blogSection':      blogSection,
    'testimonials':     testimonials,
    'liveChat':         liveChat,
    'darkModeToggle':   darkModeToggle,
    'multiLanguage':    multiLanguage,
    'analyticsConsent': analyticsConsent,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// BrandConfig — the immutable data model for a brand
// ─────────────────────────────────────────────────────────────────────────────
//
// This is passed through BrandScope down the widget tree. At the top of every
// MaterialApp, either use kBrandDefault (standalone) or inject a runtime
// instance from BrandConfig.fromManifest() (QSpace multi-tenant).

@immutable
class BrandConfig {
  // Colors
  final Color primary;
  final Color secondary;
  final Color tertiary;

  // Font roles
  final String fontHero;
  final String fontDisplay;
  final String fontText;
  final String fontAccent;
  final String fontSignature;

  // Logo paths — nullable = not yet created, BrandLogo falls back to wordmark
  final String? logoHorizontalPath;
  final String? logoVerticalPath;
  final String? logoIconPath;

  // Supplemental asset paths
  final String? faviconPath;
  final String? appIconAndroidPath;
  final String? appIconIosPath;
  final String ogImagePath;
  final String headerGifLandingPath;

  // Feature illustrations
  final String illuBookingsEmpty;
  final String illuWellnessEmpty;
  final String illuTrainersEmpty;
  final String illuOnboardDiscover;
  final String illuOnboardLog;
  final String illuOnboardBook;

  // Identity copy
  final String wordBold;
  final String wordLight;
  final String appName;
  final String tagline;
  final String domain;
  final String copyright;

  // Logo typographic fallback colors — only matter if logo assets are missing
  final Color logoBoldColor;
  final Color logoLightColor;

  // Canvas & motion preferences
  final CanvasPersonality canvasPersonality;
  final MotionIntensity   motionIntensity;

  // QSpace feature toggles
  final QSpaceFeatureFlags features;

  const BrandConfig({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.fontHero,
    required this.fontDisplay,
    required this.fontText,
    required this.fontAccent,
    required this.fontSignature,
    this.logoHorizontalPath,
    this.logoVerticalPath,
    this.logoIconPath,
    this.faviconPath,
    this.appIconAndroidPath,
    this.appIconIosPath,
    this.ogImagePath          = 'assets/brand/og_1200x630.png',
    this.headerGifLandingPath = '',
    this.illuBookingsEmpty    = 'assets/illustrations/empty_bookings.svg',
    this.illuWellnessEmpty    = 'assets/illustrations/empty_wellness.svg',
    this.illuTrainersEmpty    = 'assets/illustrations/empty_trainers.svg',
    this.illuOnboardDiscover  = 'assets/illustrations/onboard_discover.svg',
    this.illuOnboardLog       = 'assets/illustrations/onboard_log.svg',
    this.illuOnboardBook      = 'assets/illustrations/onboard_book.svg',
    required this.wordBold,
    required this.wordLight,
    required this.appName,
    required this.tagline,
    required this.domain,
    required this.copyright,
    this.logoBoldColor    = const Color(0xFFFFFFFF),
    this.logoLightColor   = const Color(0x8AFFFFFF),
    this.canvasPersonality = CanvasPersonality.energetic,
    this.motionIntensity   = MotionIntensity.full,
    this.features = const QSpaceFeatureFlags(),
  });

  // ── QSpace merge engine entry point ────────────────────────────────────────
  //
  // The merge engine calls this after deepMerge(canon, suite, developer, client).
  // The resulting BrandConfig is handed to BrandScope at the MaterialApp root.
  // There is NO recompile between tenants — each tenant gets their own config.
  //
  // Expected keys in merged JSON:
  //   brand.colors.primary / secondary / tertiary (hex strings)
  //   brand.fonts.hero / display / text / accent / signature
  //   brand.logo.horizontal / vertical / icon (asset paths or CDN URLs)
  //   brand.copy.appName / tagline / domain / copyright / wordBold / wordLight
  //   brand.canvas.personality (string: energetic / calm / minimal / corporate / dramatic)
  //   brand.motion.intensity (string: none / subtle / full)
  //   features.* (booleans)
  factory BrandConfig.fromManifest(Map<String, dynamic> manifest) {
    final brand    = (manifest['brand']    as Map<String, dynamic>?) ?? {};
    final colors   = (brand['colors']      as Map<String, dynamic>?) ?? {};
    final fonts    = (brand['fonts']       as Map<String, dynamic>?) ?? {};
    final logo     = (brand['logo']        as Map<String, dynamic>?) ?? {};
    final copy     = (brand['copy']        as Map<String, dynamic>?) ?? {};
    final canvas   = (brand['canvas']      as Map<String, dynamic>?) ?? {};
    final motion   = (brand['motion']      as Map<String, dynamic>?) ?? {};
    final features = (manifest['features'] as Map<String, dynamic>?) ?? {};

    return BrandConfig(
      primary:   _hexColor(colors['primary'],   _kPrimary),
      secondary: _hexColor(colors['secondary'], _kSecondary),
      tertiary:  _hexColor(colors['tertiary'],  _kTertiary),

      fontHero:      fonts['hero']      as String? ?? _kFontHero,
      fontDisplay:   fonts['display']   as String? ?? _kFontDisplay,
      fontText:      fonts['text']      as String? ?? _kFontText,
      fontAccent:    fonts['accent']    as String? ?? _kFontAccent,
      fontSignature: fonts['signature'] as String? ?? _kFontSignature,

      logoHorizontalPath: logo['horizontal'] as String?,
      logoVerticalPath:   logo['vertical']   as String?,
      logoIconPath:       logo['icon']       as String?,

      wordBold:  copy['wordBold']  as String? ?? _kWordBold,
      wordLight: copy['wordLight'] as String? ?? _kWordLight,
      appName:   copy['appName']   as String? ?? _kAppName,
      tagline:   copy['tagline']   as String? ?? _kTagline,
      domain:    copy['domain']    as String? ?? _kDomain,
      copyright: copy['copyright'] as String? ?? _kCopyright,

      canvasPersonality: _parsePersonality(canvas['personality'] as String?),
      motionIntensity:   _parseMotion(motion['intensity']        as String?),
      features: QSpaceFeatureFlags.fromJson(features),
    );
  }

  // Creates a modified copy — useful for overlaying client overrides onto
  // a suite manifest without mutating the original.
  BrandConfig copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    String? fontHero,
    String? fontDisplay,
    String? fontText,
    String? fontAccent,
    String? fontSignature,
    String? logoHorizontalPath,
    String? logoVerticalPath,
    String? logoIconPath,
    String? faviconPath,
    String? appIconAndroidPath,
    String? appIconIosPath,
    String? ogImagePath,
    String? headerGifLandingPath,
    String? illuBookingsEmpty,
    String? illuWellnessEmpty,
    String? illuTrainersEmpty,
    String? illuOnboardDiscover,
    String? illuOnboardLog,
    String? illuOnboardBook,
    String? wordBold,
    String? wordLight,
    String? appName,
    String? tagline,
    String? domain,
    String? copyright,
    Color? logoBoldColor,
    Color? logoLightColor,
    CanvasPersonality? canvasPersonality,
    MotionIntensity? motionIntensity,
    QSpaceFeatureFlags? features,
  }) {
    return BrandConfig(
      primary:              primary              ?? this.primary,
      secondary:            secondary            ?? this.secondary,
      tertiary:             tertiary             ?? this.tertiary,
      fontHero:             fontHero             ?? this.fontHero,
      fontDisplay:          fontDisplay          ?? this.fontDisplay,
      fontText:             fontText             ?? this.fontText,
      fontAccent:           fontAccent           ?? this.fontAccent,
      fontSignature:        fontSignature        ?? this.fontSignature,
      logoHorizontalPath:   logoHorizontalPath   ?? this.logoHorizontalPath,
      logoVerticalPath:     logoVerticalPath     ?? this.logoVerticalPath,
      logoIconPath:         logoIconPath         ?? this.logoIconPath,
      faviconPath:          faviconPath          ?? this.faviconPath,
      appIconAndroidPath:   appIconAndroidPath   ?? this.appIconAndroidPath,
      appIconIosPath:       appIconIosPath       ?? this.appIconIosPath,
      ogImagePath:          ogImagePath          ?? this.ogImagePath,
      headerGifLandingPath: headerGifLandingPath ?? this.headerGifLandingPath,
      illuBookingsEmpty:    illuBookingsEmpty    ?? this.illuBookingsEmpty,
      illuWellnessEmpty:    illuWellnessEmpty    ?? this.illuWellnessEmpty,
      illuTrainersEmpty:    illuTrainersEmpty    ?? this.illuTrainersEmpty,
      illuOnboardDiscover:  illuOnboardDiscover  ?? this.illuOnboardDiscover,
      illuOnboardLog:       illuOnboardLog       ?? this.illuOnboardLog,
      illuOnboardBook:      illuOnboardBook      ?? this.illuOnboardBook,
      wordBold:             wordBold             ?? this.wordBold,
      wordLight:            wordLight            ?? this.wordLight,
      appName:              appName              ?? this.appName,
      tagline:              tagline              ?? this.tagline,
      domain:               domain               ?? this.domain,
      copyright:            copyright            ?? this.copyright,
      logoBoldColor:        logoBoldColor        ?? this.logoBoldColor,
      logoLightColor:       logoLightColor       ?? this.logoLightColor,
      canvasPersonality:    canvasPersonality    ?? this.canvasPersonality,
      motionIntensity:      motionIntensity      ?? this.motionIntensity,
      features:             features             ?? this.features,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandConfig &&
          primary   == other.primary   &&
          secondary == other.secondary &&
          tertiary  == other.tertiary  &&
          fontText  == other.fontText  &&
          appName   == other.appName   &&
          canvasPersonality == other.canvasPersonality &&
          motionIntensity   == other.motionIntensity;

  @override
  int get hashCode => Object.hash(
    primary, secondary, tertiary, fontText, appName,
    canvasPersonality, motionIntensity,
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Color _hexColor(dynamic value, Color fallback) {
    if (value == null || value is! String) return fallback;
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6 && hex.length != 8) return fallback;
    final intVal = int.tryParse(
      hex.length == 6 ? 'FF$hex' : hex,
      radix: 16,
    );
    return intVal != null ? Color(intVal) : fallback;
  }

  static CanvasPersonality _parsePersonality(String? v) {
    return CanvasPersonality.values.firstWhere(
      (e) => e.name == v,
      orElse: () => _kCanvasPersonality,
    );
  }

  static MotionIntensity _parseMotion(String? v) {
    return MotionIntensity.values.firstWhere(
      (e) => e.name == v,
      orElse: () => _kMotionIntensity,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// kBrandDefault — the static default instance
// ─────────────────────────────────────────────────────────────────────────────
//
// This is what every static AppColors.* / BrandCopy.* getter reads from.
// For standalone use (WellPath, any single-brand app): fill in the CONFIG
// BLOCK above and this instance is correct automatically.
//
// For QSpace multi-tenant: this is the fallback when no BrandScope is found
// in the tree. The merge engine supplies the live config via BrandScope.

const BrandConfig kBrandDefault = BrandConfig(
  primary:   _kPrimary,
  secondary: _kSecondary,
  tertiary:  _kTertiary,

  fontHero:      _kFontHero,
  fontDisplay:   _kFontDisplay,
  fontText:      _kFontText,
  fontAccent:    _kFontAccent,
  fontSignature: _kFontSignature,

  logoHorizontalPath: _kLogoHorizontal,
  logoVerticalPath:   _kLogoVertical,
  logoIconPath:       _kLogoIcon,

  faviconPath:        _kFavicon,
  appIconAndroidPath: _kAppIconAndroid,
  appIconIosPath:     _kAppIconIos,
  ogImagePath:        _kOgImage,
  headerGifLandingPath: _kHeaderGifLanding,

  illuBookingsEmpty:   _kIlluBookingsEmpty,
  illuWellnessEmpty:   _kIlluWellnessEmpty,
  illuTrainersEmpty:   _kIlluTrainersEmpty,
  illuOnboardDiscover: _kIlluOnboardDiscover,
  illuOnboardLog:      _kIlluOnboardLog,
  illuOnboardBook:     _kIlluOnboardBook,

  wordBold:  _kWordBold,
  wordLight: _kWordLight,
  appName:   _kAppName,
  tagline:   _kTagline,
  domain:    _kDomain,
  copyright: _kCopyright,

  logoBoldColor:  _kLogoBoldColor,
  logoLightColor: _kLogoLightColor,

  canvasPersonality: _kCanvasPersonality,
  motionIntensity:   _kMotionIntensity,

  features: QSpaceFeatureFlags(),
);

// ─────────────────────────────────────────────────────────────────────────────
// BrandScope — runtime config injection via InheritedWidget
// ─────────────────────────────────────────────────────────────────────────────
//
// STANDALONE APP USAGE:
//   Don't use BrandScope at all. kBrandDefault is read directly.
//   MaterialApp gets AppTheme.dark (or .light) — that's it.
//
// QSPACE MULTI-TENANT USAGE:
//   final config = BrandConfig.fromManifest(mergedManifest);
//   BrandScope(
//     config: config,
//     child: MaterialApp(
//       theme: AppTheme.forConfig(config).dark,
//       home: ...,
//     ),
//   )
//
// Reading the config in a widget:
//   final config = BrandScope.of(context);  // never returns null — falls back to kBrandDefault
//
// Widgets that need the live config (BrandLogo, BrandAssets) call BrandScope.of(context).
// Color tokens come through Theme.of(context).colorScheme (proper Flutter pattern for
// runtime themes) rather than AppColors.* statics (which read kBrandDefault).

class BrandScope extends InheritedWidget {
  final BrandConfig config;

  const BrandScope({
    super.key,
    required this.config,
    required super.child,
  });

  // Always returns a config — falls back to kBrandDefault if no scope is in the tree.
  // This means widgets work correctly whether or not a BrandScope exists above them.
  static BrandConfig of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<BrandScope>()
            ?.config ??
        kBrandDefault;
  }

  @override
  bool updateShouldNotify(BrandScope old) => config != old.config;
}