// lib/core/style/app_style.dart

// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — barrel file for the complete QSpace style system.
//     One import to access every token, widget, and utility in lib/core/style/.
// ─────────────────────────────────────────────────────────────────────────────

// WHO OWNS THIS FILE:
//   The platform team. Add new files here when they join lib/core/style/.
//   Do not put any logic or values in this file — pure re-exports only.
//
// USAGE:
//   import 'package:qspace_pages/core/style/app_style.dart';
//
//   That single line makes available:
//     BrandConfig, kBrandDefault, BrandScope           → brand_config.dart
//     BrandColors, BrandCopy, BrandAssets              → app_branding.dart
//     BrandLogo, BrandLogoEngine, LogoShape, …         → app_branding.dart
//     AppColors, AppGradients, AppSpacing, AppRadius   → app_theme.dart
//     AppBreakpoints, AppZIndex, AppElevation          → app_theme.dart
//     AppSemanticColors, AppDurations, AppTypography   → app_theme.dart
//     AppTheme                                         → app_theme.dart
//     AppCanvas, BackgroundType, GradientStyle, …      → app_canvas.dart
//     AppShadows, AppDecorations, AppTextStyles        → app_decorations.dart
//     AppMotionDefaults, TypingHeadline                → app_motion.dart
//     AnimatedGradientBorder, AppPageTransitions       → app_motion.dart
//     AppLoader, AppShimmer, AppStagger                → app_motion.dart
//     AppReveal, AppRevealController, AppScale         → app_motion.dart

export 'brand_config.dart';
export 'app_branding.dart';
export 'app_theme.dart';
export 'app_canvas.dart';
export 'app_decorations.dart';
export 'app_motion.dart';