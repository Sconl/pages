// lib/core/style/app_decorations.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — AppDecorations, AppShadows, AppTextStyles extracted
//     from app_theme.dart. Pure relocation — identical values and behavior.
//   • AppDecorations.glass added — frosted glassmorphism for dark backgrounds.
//   • AppDecorations.glassMild added — lighter frosted variant for subtle lift.
//   • AppDecorations.gradientCard added — card with mesh gradient fill.
//   • AppDecorations.activeBorder added — focused / selected state decoration.
//   • AppDecorations.highlightBanner added — neutral/informational banner.
//   • AppDecorations.liveIndicator added — pulsing tertiary accent for live state.
//   • AppDecorations.dangerBorder added — red border for danger confirmation dialogs.
//   • AppShadows.glass added — soft shadow for glassmorphism cards.
//   • AppShadows.inset added — subtle inset shadow for pressed states.
//   • AppTextStyles updated — added skeleton, liveLabel, inputError, inputSuccess.
// ─────────────────────────────────────────────────────────────────────────────

// WHAT LIVES HERE:
//
//   AppShadows      — reusable BoxShadow lists for cards, buttons, modals, inputs
//   AppDecorations  — reusable BoxDecorations for cards, buttons, chips, banners
//   AppTextStyles   — semantic text style aliases (screenTitle, cardTitle, etc.)
//
// WHAT DOESN'T LIVE HERE:
//
//   Core color, gradient, spacing, radius, and typography primitives → app_theme.dart.
//   This file composes them into higher-level component decorations.
//
// IMPORT PATTERN:
//   import 'app_theme.dart';
//   import 'app_decorations.dart';

import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────
//
// Glass blur values — used in BackdropFilter.blur() at component level.
// Declared here so any glassmorphism component uses the same blur radius.
// app_decorations can't apply blur itself (that's a widget-level operation),
// but these constants document the intended blur radius for consuming widgets.

const double kGlassBlurStrong = 20.0;
const double kGlassBlurMild   = 10.0;

// Glass fill opacities — how opaque the glass background is.
const double kGlassFillAlpha  = 0.12; // strong glass card
const double kGlassFillMild   = 0.06; // mild glass card

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// APP SHADOWS
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppShadows {

  static List<BoxShadow> get card => [
    BoxShadow(
      color:      AppColors.background.withValues(alpha: 0.55),
      blurRadius: 20,
      offset:     const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get modal => [
    BoxShadow(
      color:      Colors.black.withValues(alpha: 0.50),
      blurRadius: 40,
      offset:     const Offset(0, 16),
    ),
  ];

  // Soft glow used under glassmorphism cards — doesn't overpower the frosted look.
  static List<BoxShadow> get glass => [
    BoxShadow(
      color:      Colors.black.withValues(alpha: 0.30),
      blurRadius: 24,
      offset:     const Offset(0, 8),
    ),
    BoxShadow(
      color:      AppColors.primary.withValues(alpha: 0.04),
      blurRadius: 40,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get buttonGlow => [
    BoxShadow(
      color:      AppColors.primaryDeep.withValues(alpha: 0.55),
      blurRadius: 24,
      offset:     const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get buttonGlowHover => [
    BoxShadow(
      color:      AppColors.primaryDeep.withValues(alpha: 0.70),
      blurRadius: 32,
      offset:     const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get secondaryGlow => [
    BoxShadow(
      color:      AppColors.secondaryDark.withValues(alpha: 0.50),
      blurRadius: 24,
      offset:     const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get inputFocus => [
    BoxShadow(
      color:        AppColors.primary.withValues(alpha: 0.18),
      blurRadius:   12,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get successGlow => [
    BoxShadow(
      color:      AppColors.success.withValues(alpha: 0.28),
      blurRadius: 16,
      offset:     const Offset(0, 4),
    ),
  ];

  // Subtle inset shadow for pressed states — gives buttons tactile depth.
  // Apply in addition to the base shadow when WidgetState.pressed.
  static List<BoxShadow> get inset => [
    BoxShadow(
      color:        Colors.black.withValues(alpha: 0.20),
      blurRadius:   4,
      spreadRadius: -2,
      offset:       const Offset(0, 2),
    ),
  ];
}


// ─────────────────────────────────────────────────────────────────────────────
// APP DECORATIONS
// ─────────────────────────────────────────────────────────────────────────────
//
// BoxDecorations for component surfaces.
//
// GLASSMORPHISM USAGE:
//   Glassmorphism requires a BackdropFilter widget around the card — BoxDecoration
//   alone cannot produce blur. Use the constants kGlassBlurStrong / kGlassBlurMild
//   from the config block above as the blur radius. Example:
//
//   ClipRRect(
//     borderRadius: AppRadius.cardBR,
//     child: BackdropFilter(
//       filter: ImageFilter.blur(
//         sigmaX: kGlassBlurStrong, sigmaY: kGlassBlurStrong,
//       ),
//       child: Container(
//         decoration: AppDecorations.glass,
//         child: YourCardContent(),
//       ),
//     ),
//   )
//
// GRADIENT BUTTON PATTERN:
//   ElevatedButton doesn't support gradients natively. Wrap it:
//
//   Container(
//     decoration: AppDecorations.primaryButton,
//     child: ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.transparent,
//         shadowColor:     Colors.transparent,
//       ),
//       onPressed: onPressed,
//       child: Text('Label'),
//     ),
//   )

abstract class AppDecorations {

  // ── Cards ─────────────────────────────────────────────────────────────────

  static BoxDecoration get card => BoxDecoration(
    color:        AppColors.surface,
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.border),
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    gradient:     AppGradients.surface,
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.border),
  );

  // Gradient card — brand gradient fill at low opacity, sits above the canvas.
  static BoxDecoration get gradientCard => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [
        AppColors.primary.withValues(alpha: 0.12),
        AppColors.secondary.withValues(alpha: 0.06),
      ],
    ),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
  );

  // Glassmorphism — frosted glass card. Needs BackdropFilter parent (see above).
  // kGlassBlurStrong = 20px blur radius — use that in the BackdropFilter call.
  static BoxDecoration get glass => BoxDecoration(
    color:        Colors.white.withValues(alpha: kGlassFillAlpha),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: Colors.white.withValues(alpha: 0.14)),
    boxShadow:    AppShadows.glass,
  );

  // Milder glass — less opaque, for layered glass effects.
  static BoxDecoration get glassMild => BoxDecoration(
    color:        Colors.white.withValues(alpha: kGlassFillMild),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: Colors.white.withValues(alpha: 0.08)),
    boxShadow:    AppShadows.glass,
  );

  // ── Modals / popups ───────────────────────────────────────────────────────

  static BoxDecoration get modal => BoxDecoration(
    color:        AppColors.surfaceLit,
    borderRadius: AppRadius.modalBR,
    border:       Border.all(color: AppColors.borderStrong),
    boxShadow:    AppShadows.modal,
  );

  static BoxDecoration get popup => BoxDecoration(
    color:        AppColors.surfaceMid,
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.border),
    boxShadow:    AppShadows.card,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────

  static BoxDecoration get primaryButton => BoxDecoration(
    gradient:     AppGradients.button,
    borderRadius: AppRadius.pillBR,
    boxShadow:    AppShadows.buttonGlow,
  );

  static BoxDecoration get primaryButtonHover => BoxDecoration(
    gradient:     AppGradients.buttonHover,
    borderRadius: AppRadius.pillBR,
    boxShadow:    AppShadows.buttonGlowHover,
  );

  static BoxDecoration get secondaryButton => BoxDecoration(
    gradient:     AppGradients.secondary,
    borderRadius: AppRadius.pillBR,
    boxShadow:    AppShadows.secondaryGlow,
  );

  static BoxDecoration get outlinedButton => BoxDecoration(
    color:        Colors.transparent,
    borderRadius: AppRadius.pillBR,
    border:       Border.all(color: AppColors.primary, width: 1.5),
  );

  // ── Input states ──────────────────────────────────────────────────────────

  // Active/focused border state — use on custom inputs where the theme border
  // doesn't apply (e.g., custom text area, date picker trigger).
  static BoxDecoration get activeBorder => BoxDecoration(
    color:        AppColors.surface,
    borderRadius: AppRadius.inputBR,
    border:       Border.all(color: AppColors.primary, width: 1.5),
    boxShadow:    AppShadows.inputFocus,
  );

  static BoxDecoration get dangerBorder => BoxDecoration(
    color:        AppColors.surface,
    borderRadius: AppRadius.inputBR,
    border:       Border.all(color: AppColors.error, width: 1.5),
  );

  // ── Avatar / Profile ──────────────────────────────────────────────────────

  static BoxDecoration get avatar => BoxDecoration(
    gradient:     AppGradients.avatar,
    borderRadius: AppRadius.cardBR,
  );

  // ── Chips ─────────────────────────────────────────────────────────────────

  static BoxDecoration get chip => BoxDecoration(
    color:        AppColors.tint10(AppColors.primary),
    borderRadius: BorderRadius.circular(AppSpacing.sm),
    border:       Border.all(color: AppColors.tint20(AppColors.primary)),
  );

  static BoxDecoration get chipSecondary => BoxDecoration(
    color:        AppColors.tint10(AppColors.secondary),
    borderRadius: BorderRadius.circular(AppSpacing.sm),
    border:       Border.all(color: AppColors.tint20(AppColors.secondary)),
  );

  // ── Status banners ────────────────────────────────────────────────────────

  static BoxDecoration get successBanner => BoxDecoration(
    color:        AppColors.tint10(AppColors.success),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.tint20(AppColors.success)),
  );

  static BoxDecoration get errorBanner => BoxDecoration(
    color:        AppColors.tint10(AppColors.error),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.tint20(AppColors.error)),
  );

  static BoxDecoration get warningBanner => BoxDecoration(
    color:        AppColors.tint10(AppColors.warning),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.tint20(AppColors.warning)),
  );

  static BoxDecoration get infoBanner => BoxDecoration(
    color:        AppColors.tint10(AppColors.info),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.tint20(AppColors.info)),
  );

  // Neutral highlight — brand tint, for tips, onboarding callouts, feature highlights.
  static BoxDecoration get highlightBanner => BoxDecoration(
    color:        AppColors.tint10(AppColors.primary),
    borderRadius: AppRadius.cardBR,
    border:       Border.all(color: AppColors.tint20(AppColors.primary)),
  );

  // Live state decoration — tertiary accent, for live sessions / active states.
  static BoxDecoration get liveIndicator => BoxDecoration(
    color:        AppColors.tint10(AppColors.live),
    borderRadius: BorderRadius.circular(AppSpacing.sm),
    border:       Border.all(color: AppColors.tint20(AppColors.live)),
  );

  // ── Screen-level ──────────────────────────────────────────────────────────

  static BoxDecoration get screenBackground => BoxDecoration(
    color: AppColors.background,
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// APP TEXT STYLES — semantic text style aliases
// ─────────────────────────────────────────────────────────────────────────────
//
// Named for their use context, not their visual properties. Update one of
// these and every widget using it updates automatically.

abstract class AppTextStyles {

  // ── Screen / Page ─────────────────────────────────────────────────────────
  static TextStyle get screenTitle   => AppTypography.h2;
  static TextStyle get sectionHeader => AppTypography.overline;

  // ── Card ──────────────────────────────────────────────────────────────────
  static TextStyle get cardTitle    => AppTypography.h4;
  static TextStyle get cardSubtitle => AppTypography.bodySmall;

  // ── Metrics / Data ────────────────────────────────────────────────────────
  static TextStyle get metricValue => AppTypography.h3.copyWith(
    color: AppColors.primary, fontWeight: FontWeight.w700,
  );
  static TextStyle get metricLabel => AppTypography.caption;

  // ── Auth / Onboarding ─────────────────────────────────────────────────────
  static TextStyle get authHeading    => AppTypography.h2;
  static TextStyle get authSubheading => AppTypography.bodySmall;

  // ── Interactive ───────────────────────────────────────────────────────────
  static TextStyle get link => AppTypography.bodySmall.copyWith(
    color: AppColors.primary, fontWeight: FontWeight.w500,
  );

  // ── Form feedback ─────────────────────────────────────────────────────────
  static TextStyle get errorText => AppTypography.helper.copyWith(
    color: AppColors.error,
  );
  static TextStyle get successText => AppTypography.helper.copyWith(
    color: AppColors.success,
  );
  static TextStyle get warningText => AppTypography.helper.copyWith(
    color: AppColors.warning,
  );
  static TextStyle get inputError   => AppTypography.helper.copyWith(color: AppColors.error);
  static TextStyle get inputSuccess => AppTypography.helper.copyWith(color: AppColors.success);

  // ── Timestamps / Metadata ─────────────────────────────────────────────────
  static TextStyle get timestamp => AppTypography.caption;

  // ── Notifications ─────────────────────────────────────────────────────────
  static TextStyle get notifTitle => AppTypography.body.copyWith(
    fontWeight: FontWeight.w700,
  );
  static TextStyle get notifBody => AppTypography.bodySmall;

  // ── Status ────────────────────────────────────────────────────────────────
  static TextStyle get statusLive => AppTypography.badge.copyWith(
    color: AppColors.live, letterSpacing: 1,
  );
  static TextStyle get liveLabel => AppTypography.badge.copyWith(
    color: AppColors.live, letterSpacing: 1.5,
  );

  // ── Loading skeleton placeholder ──────────────────────────────────────────
  // Use this as the textStyle on Text() inside a shimmer — the shimmer gradient
  // paints over it, so color and content don't matter, only size.
  static TextStyle get skeleton => AppTypography.body.copyWith(
    color: AppColors.surface,
    background: Paint()..color = AppColors.surface,
  );
}