// lib/core/style/app_theme.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — universal reusable theme template — Sconl Peter
//   • Color engine generates full palette from 3 brand seeds automatically
//   • 60-30-10 split enforced structurally, not by convention
//   • Gradient logic built in for buttons, backgrounds, surfaces, modals
//   • WCAG contrast checker built in — onColor() always picks readable text
//   • Fixed deprecated Color channel APIs → .r/.g/.b/.a (Flutter 3.27+)
//   • Replaced all withOpacity() calls with withValues(alpha:) throughout
//   • Brand seeds moved → brand_config.dart. Engine reads BrandColors.
//   • Font family moved → brand_config.dart. Engine reads BrandCopy.
//   • AppDecorations / AppShadows / AppTextStyles extracted → app_decorations.dart
//   • AppTypography updated — 5-font role system, explicit role per style.
//   • AppTheme.forConfig(BrandConfig) added — generates ThemeData from any
//     BrandConfig at runtime. QSpace multi-tenant: no recompile between brands.
//   • AppBreakpoints added — responsive layout helpers (xs → xxl).
//   • AppZIndex added — layering constants for Stack / Overlay usage.
//   • AppElevation added — elevation scale tokens.
//   • AppSemanticColors added — named semantic tokens (danger, caution, etc.)
//     for consistent meaning across the system.
//   • _ColorEngine refactored — accepts BrandConfig param so forConfig() can
//     generate isolated palettes without mutating global state.
// ─────────────────────────────────────────────────────────────────────────────

// HOW TO USE IN A NEW PROJECT:
//   1. Open brand_config.dart — that is the only file you edit.
//   2. Set BrandColors / BrandCopy / asset paths there.
//   3. Done — everything here regenerates from those inputs.
//
// RUNTIME THEMING (QSpace multi-tenant):
//   AppTheme.forConfig(runtimeConfig).dark  → ThemeData for dark mode
//   AppTheme.forConfig(runtimeConfig).light → ThemeData for light mode
//   Pass either to MaterialApp.theme.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_branding.dart';
import 'brand_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK — layout, spacing, and shape constants ONLY
// ─────────────────────────────────────────────────────────────────────────────
//
// Colors / fonts → brand_config.dart. Shape + spacing → here.

// ── Spacing scale ─────────────────────────────────────────────────────────────
const double _kSpacingBase = 4.0;

// ── Shape ─────────────────────────────────────────────────────────────────────
const double _kRadiusXs    = 4.0;
const double _kRadiusSm    = 8.0;
const double _kRadiusInput = 10.0;
const double _kRadiusCard  = 14.0;
const double _kRadiusModal = 20.0;
const double _kRadiusPill  = 50.0;

// ── Responsive breakpoints ────────────────────────────────────────────────────
const double _kBpXs  = 320.0;   // small phones
const double _kBpSm  = 480.0;   // large phones
const double _kBpMd  = 768.0;   // tablet portrait
const double _kBpLg  = 1024.0;  // tablet landscape / small desktop
const double _kBpXl  = 1280.0;  // standard desktop
const double _kBpXxl = 1536.0;  // large desktop

// Max content width per breakpoint — prevents line lengths becoming unreadable
const double _kMaxContentMd  = 720.0;
const double _kMaxContentLg  = 960.0;
const double _kMaxContentXl  = 1200.0;
const double _kMaxContentXxl = 1440.0;

// Adaptive page padding values (horizontal)
const double _kPadPageMobile  = 20.0;
const double _kPadPageTablet  = 40.0;
const double _kPadPageDesktop = 80.0;

// ── Color engine constants ────────────────────────────────────────────────────
const double _kDarkSurfaceStep           = 0.065;
const double _kLightSurfaceStep          = 0.040;
const double _kDarkBackgroundSaturation  = 0.22;
const double _kLightBackgroundSaturation = 0.08;
// +12° on gradient end stop — gives buttons depth, simulates a top-left light source.
const double _kGradientHueShift = 12.0;

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// _ColorEngine — derives full palette from 3 brand seeds
// ─────────────────────────────────────────────────────────────────────────────
//
// Accepts a BrandConfig so AppTheme.forConfig() can run it against any config
// without relying on global state. AppColors.* statics use kBrandDefault.

class _ColorEngine {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const _ColorEngine({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  factory _ColorEngine.fromConfig(BrandConfig c) => _ColorEngine(
    primary:   c.primary,
    secondary: c.secondary,
    tertiary:  c.tertiary,
  );

  // ── HSL helpers ────────────────────────────────────────────────────────────

  static HSLColor _hsl(Color c) => HSLColor.fromColor(c);

  static Color lighten(Color c, double amount) {
    final h = _hsl(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color darken(Color c, double amount) {
    final h = _hsl(c);
    return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  // ignore: unused_element
  static Color saturate(Color c, double amount) {
    final h = _hsl(c);
    return h.withSaturation((h.saturation + amount).clamp(0.0, 1.0)).toColor();
  }

  // ignore: unused_element
  static Color desaturate(Color c, double amount) {
    final h = _hsl(c);
    return h.withSaturation((h.saturation - amount).clamp(0.0, 1.0)).toColor();
  }

  static Color rotateHue(Color c, double degrees) {
    final h = _hsl(c);
    return h.withHue((h.hue + degrees) % 360.0).toColor();
  }

  static Color fromHSL(double hue, double sat, double light) =>
      HSLColor.fromAHSL(1.0, hue, sat, light).toColor();

  // Flutter 3.27+: .r/.g/.b/.a return double 0.0–1.0.
  static Color mix(Color a, Color b, double t) {
    int ch(double av, double bv) =>
        ((av + (bv - av) * t) * 255.0).round().clamp(0, 255);
    return Color.fromARGB(ch(a.a, b.a), ch(a.r, b.r), ch(a.g, b.g), ch(a.b, b.b));
  }

  // WCAG linearisation — .r/.g/.b are already 0.0–1.0.
  static double _luminance(Color c) {
    double lin(double s) =>
        s <= 0.04045 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  }

  static double contrastRatio(Color fg, Color bg) {
    final l1 = _luminance(fg);
    final l2 = _luminance(bg);
    return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
  }

  // WCAG AA compliant text color for a given background.
  static Color onColor(Color bg) {
    final darkText      = mix(darken(bg, 0.65), const Color(0xFF000000), 0.55);
    final whiteContrast = contrastRatio(const Color(0xFFFFFFFF), bg);
    return whiteContrast >= 4.5 ? const Color(0xFFFFFFFF) : darkText;
  }

  // ── Dark background family ─────────────────────────────────────────────────

  Color get darkBackground =>
      fromHSL(_hsl(primary).hue, _kDarkBackgroundSaturation, 0.050);

  Color get darkBackgroundAlt =>
      fromHSL(_hsl(primary).hue, _kDarkBackgroundSaturation, 0.072);

  Color get darkSurface =>
      fromHSL(_hsl(primary).hue, _kDarkBackgroundSaturation,
          0.050 + _kDarkSurfaceStep);

  Color get darkSurfaceMid =>
      fromHSL(_hsl(primary).hue, _kDarkBackgroundSaturation,
          0.050 + _kDarkSurfaceStep * 2);

  Color get darkSurfaceLit =>
      fromHSL(_hsl(primary).hue, _kDarkBackgroundSaturation,
          0.050 + _kDarkSurfaceStep * 3);

  // ── Accent variants ────────────────────────────────────────────────────────

  Color get primaryLight => lighten(primary, 0.15);
  Color get primaryDark  => darken(primary, 0.15);
  Color get primaryDeep  => darken(primary, 0.30);

  Color get secondaryLight => lighten(secondary, 0.15);
  Color get secondaryDark  => darken(secondary, 0.15);

  Color get tertiaryLight => lighten(tertiary, 0.15);
  Color get tertiaryDark  => darken(tertiary, 0.15);

  // ── Light mode family ──────────────────────────────────────────────────────

  Color get lightBackground =>
      fromHSL(_hsl(primary).hue, _kLightBackgroundSaturation, 0.970);

  Color get lightSurface =>
      fromHSL(_hsl(primary).hue, _kLightBackgroundSaturation + 0.04,
          0.970 - _kLightSurfaceStep);

  Color get lightSurfaceMid =>
      fromHSL(_hsl(primary).hue, _kLightBackgroundSaturation + 0.07,
          0.970 - _kLightSurfaceStep * 2);

  Color get lightPrimary {
    Color c = primary;
    for (int i = 0; i < 30; i++) {
      if (contrastRatio(c, lightBackground) >= 4.5) return c;
      c = darken(c, 0.02);
    }
    return c;
  }

  // ── Gradient color lists ───────────────────────────────────────────────────

  List<Color> get buttonColors => [
    primary,
    darken(rotateHue(primary, _kGradientHueShift), 0.12),
  ];

  List<Color> get buttonHoverColors => [
    lighten(rotateHue(primary, -_kGradientHueShift * 0.5), 0.12),
    primary,
  ];

  List<Color> get heroColors => [primaryLight, primary, darkBackground];

  List<Color> get surfaceColors => [darkSurfaceLit, darkSurface];

  List<Color> get secondaryButtonColors => [
    secondary,
    darken(rotateHue(secondary, _kGradientHueShift), 0.12),
  ];
}

// Default engine instance — reads from kBrandDefault.
// AppColors.* statics use this. Fast and const-compatible.
final _ColorEngine _defaultEngine = _ColorEngine.fromConfig(kBrandDefault);


// ─────────────────────────────────────────────────────────────────────────────
// APP COLORS
// ─────────────────────────────────────────────────────────────────────────────
//
// Static getters → read from kBrandDefault via _defaultEngine.
// For runtime theming, access colors through Theme.of(context).colorScheme —
// which is populated by AppTheme.forConfig(runtimeConfig).

abstract class AppColors {

  static Color get background    => _defaultEngine.darkBackground;
  static Color get backgroundAlt => _defaultEngine.darkBackgroundAlt;

  static Color get surface       => _defaultEngine.darkSurface;
  static Color get surfaceMid    => _defaultEngine.darkSurfaceMid;
  static Color get surfaceLit    => _defaultEngine.darkSurfaceLit;

  static Color get primary      => BrandColors.primary;
  static Color get primaryLight => _defaultEngine.primaryLight;
  static Color get primaryDark  => _defaultEngine.primaryDark;
  static Color get primaryDeep  => _defaultEngine.primaryDeep;

  static Color get secondary      => BrandColors.secondary;
  static Color get secondaryLight => _defaultEngine.secondaryLight;
  static Color get secondaryDark  => _defaultEngine.secondaryDark;

  static Color get tertiary      => BrandColors.tertiary;
  static Color get tertiaryLight => _defaultEngine.tertiaryLight;
  static Color get tertiaryDark  => _defaultEngine.tertiaryDark;

  static Color get lightBackground => _defaultEngine.lightBackground;
  static Color get lightSurface    => _defaultEngine.lightSurface;
  static Color get lightSurfaceMid => _defaultEngine.lightSurfaceMid;
  static Color get lightPrimary    => _defaultEngine.lightPrimary;

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x8AFFFFFF);
  static const Color textMuted     = Color(0x3DFFFFFF);
  static const Color textHint      = Color(0x61FFFFFF);

  // Light mode text
  static Color get lightTextPrimary   => _ColorEngine.darken(BrandColors.primary, 0.62);
  static Color get lightTextSecondary => _ColorEngine.mix(lightTextPrimary, const Color(0xFF888888), 0.5);

  // On-colors — WCAG AA compliant text for use on brand color backgrounds
  static Color get onPrimary   => _ColorEngine.onColor(BrandColors.primary);
  static Color get onSecondary => _ColorEngine.onColor(BrandColors.secondary);
  static Color get onTertiary  => _ColorEngine.onColor(BrandColors.tertiary);

  // Status — fixed values, not derived from brand (semantic meaning must be stable)
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error   = Color(0xFFFF5252);
  static const Color info    = Color(0xFF40C4FF);

  static Color get live => BrandColors.tertiary;

  // Borders
  static const Color border        = Color(0x1FFFFFFF);
  static const Color borderStrong  = Color(0x33FFFFFF);
  static Color get borderFocused   => BrandColors.primary;
  static const Color borderError   = Color(0xFFFF5252);

  // Utility
  static const Color scrim       = Color(0xCC000000);
  static const Color transparent = Color(0x00000000);

  // Tint helpers — used widely in chip/banner/badge backgrounds
  static Color tint10(Color c) => c.withValues(alpha: 0.10);
  static Color tint20(Color c) => c.withValues(alpha: 0.20);
  static Color tint30(Color c) => c.withValues(alpha: 0.30);

  // Runtime-config version — used by AppTheme.forConfig()
  static Color backgroundOf   (BrandConfig c) => _ColorEngine.fromConfig(c).darkBackground;
  static Color surfaceOf      (BrandConfig c) => _ColorEngine.fromConfig(c).darkSurface;
  static Color surfaceLitOf   (BrandConfig c) => _ColorEngine.fromConfig(c).darkSurfaceLit;
  static Color primaryDeepOf  (BrandConfig c) => _ColorEngine.fromConfig(c).primaryDeep;
  static Color lightPrimaryOf (BrandConfig c) => _ColorEngine.fromConfig(c).lightPrimary;
}


// ─────────────────────────────────────────────────────────────────────────────
// APP SEMANTIC COLORS
// ─────────────────────────────────────────────────────────────────────────────
//
// Named for meaning, not appearance. These map status states to the appropriate
// base color. Consistent semantics = developers don't guess which color means
// "this action is destructive."

abstract class AppSemanticColors {
  static Color get danger     => AppColors.error;    // destructive actions, form errors
  static Color get caution    => AppColors.warning;  // reversible but risky actions
  static Color get positive   => AppColors.success;  // completed, confirmed, healthy
  static Color get neutral    => AppColors.info;     // informational, no action needed
  static Color get liveActive => AppColors.live;     // real-time / actively running

  static Color get dangerBg   => AppColors.tint10(AppColors.error);
  static Color get cautionBg  => AppColors.tint10(AppColors.warning);
  static Color get positiveBg => AppColors.tint10(AppColors.success);
  static Color get neutralBg  => AppColors.tint10(AppColors.info);
}


// ─────────────────────────────────────────────────────────────────────────────
// APP GRADIENTS
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppGradients {

  static LinearGradient get primary => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: _defaultEngine.heroColors, stops: const [0.0, 0.35, 1.0],
  );

  static LinearGradient get button => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: _defaultEngine.buttonColors,
  );

  static LinearGradient get buttonHover => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: _defaultEngine.buttonHoverColors,
  );

  static LinearGradient get secondary => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: _defaultEngine.secondaryButtonColors,
  );

  static LinearGradient get avatar => LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primaryDark],
  );

  static LinearGradient get surface => LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: _defaultEngine.surfaceColors,
  );

  static RadialGradient get meshPrimary => RadialGradient(
    center: const Alignment(-0.65, -0.35), radius: 1.3,
    colors: [AppColors.primary.withValues(alpha: 0.18), Colors.transparent],
  );

  static RadialGradient get meshSecondary => RadialGradient(
    center: const Alignment(0.75, 0.55), radius: 1.0,
    colors: [AppColors.secondary.withValues(alpha: 0.09), Colors.transparent],
  );

  // Runtime-config versions
  static LinearGradient buttonFor(BrandConfig c) {
    final e = _ColorEngine.fromConfig(c);
    return LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: e.buttonColors,
    );
  }

  static LinearGradient primaryFor(BrandConfig c) {
    final e = _ColorEngine.fromConfig(c);
    return LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: e.heroColors, stops: const [0.0, 0.35, 1.0],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// APP SPACING
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppSpacing {
  static double get xs   => _kSpacingBase * 1;   //  4
  static double get sm   => _kSpacingBase * 2;   //  8
  static double get md   => _kSpacingBase * 4;   // 16
  static double get lg   => _kSpacingBase * 6;   // 24
  static double get xl   => _kSpacingBase * 8;   // 32
  static double get xxl  => _kSpacingBase * 12;  // 48
  static double get xxxl => _kSpacingBase * 16;  // 64

  static EdgeInsets get pagePadding  => EdgeInsets.symmetric(horizontal: md, vertical: lg);
  static EdgeInsets get cardPadding  => EdgeInsets.all(md);
  static EdgeInsets get inputPadding => EdgeInsets.symmetric(horizontal: md, vertical: sm + 4);
  static EdgeInsets get chipPadding  => EdgeInsets.symmetric(horizontal: sm, vertical: xs - 1);
  static EdgeInsets get listTilePad  => EdgeInsets.symmetric(horizontal: md, vertical: sm);
}


// ─────────────────────────────────────────────────────────────────────────────
// APP RADIUS
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppRadius {
  static double get xs    => _kRadiusXs;
  static double get sm    => _kRadiusSm;
  static double get input => _kRadiusInput;
  static double get card  => _kRadiusCard;
  static double get modal => _kRadiusModal;
  static double get pill  => _kRadiusPill;

  static BorderRadius get xsBR    => BorderRadius.circular(xs);
  static BorderRadius get smBR    => BorderRadius.circular(sm);
  static BorderRadius get inputBR => BorderRadius.circular(input);
  static BorderRadius get cardBR  => BorderRadius.circular(card);
  static BorderRadius get modalBR => BorderRadius.circular(modal);
  static BorderRadius get pillBR  => BorderRadius.circular(pill);
  static BorderRadius get modalTopBR => BorderRadius.vertical(top: Radius.circular(modal));
}


// ─────────────────────────────────────────────────────────────────────────────
// APP BREAKPOINTS — responsive layout helpers
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppBreakpoints {
  static const double xs  = _kBpXs;
  static const double sm  = _kBpSm;
  static const double md  = _kBpMd;
  static const double lg  = _kBpLg;
  static const double xl  = _kBpXl;
  static const double xxl = _kBpXxl;

  static double screenWidth(BuildContext ctx) => MediaQuery.sizeOf(ctx).width;
  static double screenHeight(BuildContext ctx) => MediaQuery.sizeOf(ctx).height;

  static bool isMobile (BuildContext ctx) => screenWidth(ctx) < md;
  static bool isTablet (BuildContext ctx) => screenWidth(ctx) >= md && screenWidth(ctx) < lg;
  static bool isDesktop(BuildContext ctx) => screenWidth(ctx) >= lg;

  // How many columns to use for a grid layout — safe default for most cases.
  static int gridColumns(BuildContext ctx) {
    final w = screenWidth(ctx);
    if (w >= xl)  return 4;
    if (w >= lg)  return 3;
    if (w >= md)  return 2;
    return 1;
  }

  // Horizontal padding that grows with screen width.
  static EdgeInsets pagePadding(BuildContext ctx) {
    if (isDesktop(ctx)) return EdgeInsets.symmetric(horizontal: _kPadPageDesktop, vertical: AppSpacing.xxl);
    if (isTablet(ctx))  return EdgeInsets.symmetric(horizontal: _kPadPageTablet,  vertical: AppSpacing.xl);
    return EdgeInsets.symmetric(horizontal: _kPadPageMobile, vertical: AppSpacing.lg);
  }

  // Max-width container — centers content on wide screens without letting
  // line lengths reach eye-straining lengths.
  static double maxContentWidth(BuildContext ctx) {
    final w = screenWidth(ctx);
    if (w >= xxl) return _kMaxContentXxl;
    if (w >= xl)  return _kMaxContentXl;
    if (w >= lg)  return _kMaxContentLg;
    if (w >= md)  return _kMaxContentMd;
    return double.infinity;
  }

  // Convenience widget — centers content and constrains max width.
  static Widget constrain(BuildContext ctx, Widget child) =>
      Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth(ctx)),
        child: child,
      ));
}


// ─────────────────────────────────────────────────────────────────────────────
// APP Z-INDEX — layering constants for Stack / Overlay
// ─────────────────────────────────────────────────────────────────────────────
//
// Flutter doesn't have a native z-index, but Stack renders children in order.
// These constants document the intended visual layering order across the app.
// Use them when building custom Overlay or Stack-based layouts.

abstract class AppZIndex {
  static const int base     = 0;   // default page content
  static const int card     = 1;   // cards floating above base
  static const int fab      = 5;   // floating action buttons
  static const int sticky   = 10;  // sticky headers
  static const int drawer   = 50;  // side drawers
  static const int overlay  = 100; // semi-transparent overlays
  static const int modal    = 200; // modals / bottom sheets
  static const int toast    = 300; // snackbars / toasts
  static const int tooltip  = 400; // tooltips (always on top)
}


// ─────────────────────────────────────────────────────────────────────────────
// APP ELEVATION — elevation scale tokens
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppElevation {
  static const double none     = 0.0;
  static const double card     = 1.0;  // subtle lift for cards on surface
  static const double dropdown = 2.0;  // dropdowns / popups
  static const double drawer   = 4.0;  // side drawers
  static const double modal    = 8.0;  // full modals
  static const double appBar   = 0.0;  // flat appbars (preferred)
}


// ─────────────────────────────────────────────────────────────────────────────
// APP DURATIONS
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppDurations {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast    = Duration(milliseconds: 150);
  static const Duration normal  = Duration(milliseconds: 280);
  static const Duration slow    = Duration(milliseconds: 420);
  static const Duration xslow   = Duration(milliseconds: 600);
  static const Duration stagger = Duration(milliseconds: 60);
}


// ─────────────────────────────────────────────────────────────────────────────
// APP TYPOGRAPHY
// ─────────────────────────────────────────────────────────────────────────────
//
// Each style explicitly names its font role. Swap a font in brand_config.dart
// and every style using that role updates automatically — nothing changes here.
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ Role        → Styles                                                    │
// │ fontHero    → brandBold, brandLight                                     │
// │ fontDisplay → h1 – h5                                                   │
// │ fontText    → bodyLarge, body, bodySmall, button, buttonSm,             │
// │               input, inputLabel, helper                                 │
// │ fontAccent  → caption, overline, chip, badge                            │
// │ fontSignature → signature                                               │
// └─────────────────────────────────────────────────────────────────────────┘

abstract class AppTypography {

  // ── Hero ──────────────────────────────────────────────────────────────────
  static TextStyle get brandBold  => _f(FontWeight.w700, 36, font: BrandCopy.fontHero,    ls: -1.5);
  static TextStyle get brandLight => _f(FontWeight.w300, 36, font: BrandCopy.fontHero,    ls: -1.5, color: AppColors.textSecondary);

  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle get h1 => _f(FontWeight.w700, 28, font: BrandCopy.fontDisplay, ls: -0.5);
  static TextStyle get h2 => _f(FontWeight.w700, 22, font: BrandCopy.fontDisplay, ls: -0.3);
  static TextStyle get h3 => _f(FontWeight.w600, 18, font: BrandCopy.fontDisplay);
  static TextStyle get h4 => _f(FontWeight.w600, 15, font: BrandCopy.fontDisplay);
  static TextStyle get h5 => _f(FontWeight.w600, 13, font: BrandCopy.fontDisplay);

  // ── Text ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _f(FontWeight.w400, 16, h: 1.6);
  static TextStyle get body      => _f(FontWeight.w400, 14, h: 1.6);
  static TextStyle get bodySmall => _f(FontWeight.w300, 13, h: 1.5, color: AppColors.textSecondary);

  static TextStyle get button   => _f(FontWeight.w700, 15, ls: 0.3, color: AppColors.onPrimary);
  static TextStyle get buttonSm => _f(FontWeight.w700, 13, ls: 0.3, color: AppColors.onPrimary);

  static TextStyle get input      => _f(FontWeight.w400, 14);
  static TextStyle get inputLabel => _f(FontWeight.w300, 13, color: AppColors.textSecondary);
  static TextStyle get helper     => _f(FontWeight.w300, 12, color: AppColors.textSecondary);

  // ── Accent ────────────────────────────────────────────────────────────────
  static TextStyle get caption  => _f(FontWeight.w300, 11, font: BrandCopy.fontAccent, color: AppColors.textMuted);
  static TextStyle get overline => _f(FontWeight.w700, 10, font: BrandCopy.fontAccent, ls: 2.5, color: AppColors.textMuted);
  static TextStyle get chip     => _f(FontWeight.w600, 10, font: BrandCopy.fontAccent, color: AppColors.primary);
  static TextStyle get badge    => _f(FontWeight.w700,  9, font: BrandCopy.fontAccent, ls: 0.5);

  // ── Signature — emotional moments only ────────────────────────────────────
  // <3% of visible UI text. Greetings, milestones, warm empty states.
  static TextStyle get signature => _f(FontWeight.w400, 18, font: BrandCopy.fontSignature, h: 1.5, color: AppColors.textSecondary);

  // Internal style builder.
  // font defaults to fontText — the workhorse. Override per style using the role names.
  static TextStyle _f(
    FontWeight w,
    double size, {
    String? font,
    double? ls,
    double? h,
    Color? color,
  }) =>
      GoogleFonts.getFont(
        font ?? BrandCopy.fontText,
        fontWeight:    w,
        fontSize:      size,
        letterSpacing: ls,
        height:        h,
        color:         color ?? AppColors.textPrimary,
      );

  // Runtime-config version — used by AppTheme.forConfig().
  static TextStyle buildStyle(
    FontWeight w,
    double size,
    BrandConfig config, {
    String? fontRole,
    double? ls,
    double? h,
    Color? color,
  }) =>
      GoogleFonts.getFont(
        fontRole ?? config.fontText,
        fontWeight:    w,
        fontSize:      size,
        letterSpacing: ls,
        height:        h,
        color:         color ?? AppColors.textPrimary,
      );
}


// ─────────────────────────────────────────────────────────────────────────────
// APP THEME — ThemeData generation
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {

  // ── Runtime config factory ────────────────────────────────────────────────
  //
  // QSpace multi-tenant entry point. Call this with the BrandConfig produced
  // by the merge engine. Returns an object with .dark and .light ThemeData.
  //
  // Usage:
  //   final themes = AppTheme.forConfig(runtimeConfig);
  //   MaterialApp(theme: themes.light, darkTheme: themes.dark, ...)
  static ({ThemeData dark, ThemeData light}) forConfig(BrandConfig config) =>
      (dark: _buildDark(config), light: _buildLight(config));

  // ── Static convenience getters (use kBrandDefault) ────────────────────────

  static ThemeData get dark  => _buildDark(kBrandDefault);
  static ThemeData get light => _buildLight(kBrandDefault);

  // ─────────────────────────────────────────────────────────────────────────
  // Dark theme generator
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData _buildDark(BrandConfig c) {
    final e         = _ColorEngine.fromConfig(c);

    // Inline AppColors-style getters for this config
    final background  = e.darkBackground;
    final surface     = e.darkSurface;
    final surfaceMid  = e.darkSurfaceMid;
    final surfaceLit  = e.darkSurfaceLit;
    final primaryDeep = e.primaryDeep;
    final primaryLight = e.primaryLight;
    final onPrimary    = _ColorEngine.onColor(c.primary);
    final onSecondary  = _ColorEngine.onColor(c.secondary);
    final onTertiary   = _ColorEngine.onColor(c.tertiary);
    const textPrimary   = Color(0xFFFFFFFF);
    const textSecondary = Color(0x8AFFFFFF);
    const textMuted     = Color(0x3DFFFFFF);
    const textHint      = Color(0x61FFFFFF);
    const border        = Color(0x1FFFFFFF);
    const borderStrong  = Color(0x33FFFFFF);

    return ThemeData.dark(useMaterial3: true).copyWith(
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        brightness:              Brightness.dark,
        primary:                 c.primary,
        onPrimary:               onPrimary,
        primaryContainer:        primaryDeep,
        onPrimaryContainer:      primaryLight,
        secondary:               c.secondary,
        onSecondary:             onSecondary,
        secondaryContainer:      surfaceLit,
        onSecondaryContainer:    textPrimary,
        tertiary:                c.tertiary,
        onTertiary:              onTertiary,
        error:                   AppColors.error,
        onError:                 Colors.white,
        surface:                 surface,
        onSurface:               textPrimary,
        surfaceContainerHighest: surfaceLit,
        outline:                 border,
        outlineVariant:          borderStrong,
        scrim:                   AppColors.scrim,
        shadow:                  background,
      ),

      scaffoldBackgroundColor: background,

      appBarTheme: AppBarTheme(
        backgroundColor:        background,
        foregroundColor:        textPrimary,
        elevation:              AppElevation.appBar,
        scrolledUnderElevation: 0,
        centerTitle:            false,
        systemOverlayStyle:     SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.buildStyle(
          FontWeight.w600, 18, c, fontRole: c.fontDisplay,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      surface,
        selectedItemColor:    c.primary,
        unselectedItemColor:  textMuted,
        elevation:            0,
        type:                 BottomNavigationBarType.fixed,
        selectedLabelStyle:   AppTypography.chip,
        unselectedLabelStyle: AppTypography.caption,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor:  c.primary.withValues(alpha: 0.20),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? c.primary : textMuted,
        )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? AppTypography.chip.copyWith(color: c.primary)
              : AppTypography.caption,
        ),
      ),

      cardTheme: CardThemeData(
        color:     surface,
        elevation: AppElevation.none,
        margin:    EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBR,
          side: const BorderSide(color: border),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: onPrimary,
          elevation:       AppElevation.none,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 7,
          ),
          shape:       RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          textStyle:   AppTypography.button,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side:            BorderSide(color: c.primary, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 7,
          ),
          shape:       RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          textStyle:   AppTypography.button.copyWith(color: c.primary),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: AppTypography.bodySmall.copyWith(color: c.primary),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:             true,
        fillColor:          surface,
        contentPadding:     AppSpacing.inputPadding,
        labelStyle:         AppTypography.inputLabel,
        floatingLabelStyle: AppTypography.inputLabel.copyWith(color: c.primary),
        hintStyle:          AppTypography.input.copyWith(color: textHint),
        errorStyle:         AppTypography.helper.copyWith(color: AppColors.error),
        helperStyle:        AppTypography.helper,
        prefixIconColor:    textMuted,
        suffixIconColor:    textMuted,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.primary.withValues(alpha: 0.10),
        selectedColor:   c.primary.withValues(alpha: 0.20),
        labelStyle:      AppTypography.chip,
        side:            BorderSide(color: c.primary.withValues(alpha: 0.20)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: AppSpacing.chipPadding,
      ),

      dividerTheme: const DividerThemeData(
        color: border, thickness: 1, space: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor:  surfaceLit,
        elevation:        AppElevation.none,
        shape:            RoundedRectangleBorder(borderRadius: AppRadius.modalBR),
        titleTextStyle:   AppTypography.h3,
        contentTextStyle: AppTypography.body,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:      surfaceMid,
        modalBackgroundColor: surfaceMid,
        elevation:            AppElevation.none,
        shape:                RoundedRectangleBorder(borderRadius: AppRadius.modalTopBR),
        dragHandleColor:      borderStrong,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  surfaceLit,
        contentTextStyle: AppTypography.bodySmall.copyWith(color: textPrimary),
        behavior:         SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        actionTextColor: c.primary,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color:              c.primary,
        linearTrackColor:   surface,
        circularTrackColor: surface,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? c.primary : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? c.primary.withValues(alpha: 0.20)
              : surface,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? c.primary : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(onPrimary),
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? c.primary : textMuted,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor:        c.primary,
        inactiveTrackColor:      surface,
        thumbColor:              c.primary,
        overlayColor:            c.primary.withValues(alpha: 0.10),
        valueIndicatorColor:     c.primary,
        valueIndicatorTextStyle: AppTypography.badge.copyWith(color: onPrimary),
      ),

      listTileTheme: ListTileThemeData(
        tileColor:         Colors.transparent,
        selectedTileColor: c.primary.withValues(alpha: 0.10),
        iconColor:         textMuted,
        textColor:         textPrimary,
        subtitleTextStyle: AppTypography.bodySmall,
        titleTextStyle:    AppTypography.body,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      ),

      iconTheme: const IconThemeData(color: textSecondary, size: 22),

      tabBarTheme: TabBarThemeData(
        labelColor:           c.primary,
        unselectedLabelColor: textMuted,
        labelStyle:           AppTypography.chip.copyWith(fontSize: 13),
        unselectedLabelStyle: AppTypography.caption.copyWith(fontSize: 13),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor:  border,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: onPrimary,
        elevation:       AppElevation.none,
        shape:           const CircleBorder(),
      ),

      textTheme: GoogleFonts.getTextTheme(
        c.fontText,
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge:   AppTypography.h1.copyWith(fontSize: 32),
        displayMedium:  AppTypography.h1,
        displaySmall:   AppTypography.h2,
        headlineLarge:  AppTypography.h2,
        headlineMedium: AppTypography.h3,
        headlineSmall:  AppTypography.h4,
        titleLarge:     AppTypography.h4,
        titleMedium:    AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        titleSmall:     AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        bodyLarge:      AppTypography.bodyLarge,
        bodyMedium:     AppTypography.body,
        bodySmall:      AppTypography.bodySmall,
        labelLarge:     AppTypography.button,
        labelMedium:    AppTypography.chip,
        labelSmall:     AppTypography.caption,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Light theme generator
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData _buildLight(BrandConfig c) {
    final e            = _ColorEngine.fromConfig(c);
    final lightBg      = e.lightBackground;
    final lightSurface = e.lightSurface;
    final lightSurfMid = e.lightSurfaceMid;
    final lightPrimary = e.lightPrimary;
    final lightText    = _ColorEngine.darken(c.primary, 0.62);
    final lightTextSec = _ColorEngine.mix(lightText, const Color(0xFF888888), 0.5);
    final onLightPrim  = _ColorEngine.onColor(lightPrimary);

    return ThemeData.light(useMaterial3: true).copyWith(
      brightness: Brightness.light,

      colorScheme: ColorScheme.light(
        brightness:  Brightness.light,
        primary:     lightPrimary,
        onPrimary:   onLightPrim,
        secondary:   c.secondary,
        onSecondary: _ColorEngine.onColor(c.secondary),
        tertiary:    c.tertiary,
        onTertiary:  _ColorEngine.onColor(c.tertiary),
        surface:     lightBg,
        onSurface:   lightText,
        error:       AppColors.error,
        onError:     Colors.white,
        outline:     lightSurfMid,
      ),

      scaffoldBackgroundColor: lightBg,

      appBarTheme: AppBarTheme(
        backgroundColor:    lightBg,
        foregroundColor:    lightText,
        elevation:          AppElevation.appBar,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.buildStyle(
          FontWeight.w600, 18, c, fontRole: c.fontDisplay, color: lightText,
        ),
        iconTheme: IconThemeData(color: lightText),
      ),

      cardTheme: CardThemeData(
        color:     lightSurface,
        elevation: AppElevation.none,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBR,
          side:         BorderSide(color: lightSurfMid),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: onLightPrim,
          elevation:       AppElevation.none,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 7,
          ),
          shape:       RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          textStyle:   AppTypography.button.copyWith(color: onLightPrim),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:             true,
        fillColor:          lightSurface,
        contentPadding:     AppSpacing.inputPadding,
        labelStyle:         AppTypography.inputLabel.copyWith(color: lightTextSec),
        floatingLabelStyle: AppTypography.inputLabel.copyWith(color: lightPrimary),
        hintStyle:          AppTypography.input.copyWith(color: lightTextSec),
        errorStyle:         AppTypography.helper.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: lightSurfMid),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: lightSurfMid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: lightSurfMid, thickness: 1, space: 0,
      ),

      iconTheme: IconThemeData(color: lightTextSec, size: 22),

      textTheme: GoogleFonts.getTextTheme(
        c.fontText,
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge:   AppTypography.h1.copyWith(fontSize: 32, color: lightText),
        displayMedium:  AppTypography.h1.copyWith(color: lightText),
        headlineLarge:  AppTypography.h2.copyWith(color: lightText),
        headlineMedium: AppTypography.h3.copyWith(color: lightText),
        headlineSmall:  AppTypography.h4.copyWith(color: lightText),
        bodyLarge:      AppTypography.bodyLarge.copyWith(color: lightText),
        bodyMedium:     AppTypography.body.copyWith(color: lightText),
        bodySmall:      AppTypography.bodySmall.copyWith(color: lightTextSec),
        labelLarge:     AppTypography.button,
        labelMedium:    AppTypography.chip.copyWith(color: lightPrimary),
        labelSmall:     AppTypography.caption.copyWith(color: lightTextSec),
      ),
    );
  }
}


// Returned by AppTheme.forConfig() as a named Dart 3 record: (dark: ThemeData, light: ThemeData).
// Usage: final themes = AppTheme.forConfig(config); MaterialApp(theme: themes.light, darkTheme: themes.dark)