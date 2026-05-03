// qspace_resources/lib/src/logos/logos.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-05-03 — Full rewrite. Organized by system (Pages, Pay, Pulse).
//                  QSpacePagesLogo has real asset paths matching actual files.
//                  QSpacePayLogo + QSpacePulseLogo declared as null placeholders.
//                  Naming convention and import guide documented in-file.
//                  Renamed from *Logos → *Logo (one logo, multiple variations).
//   • 2026-05-03 — Initial: QSpacePagesLogos with real paths, Pay/Pulse as
//                  null stubs.
// ─────────────────────────────────────────────────────────────────────────────
//
// WHO OWNS THIS FILE:
//   The QSpace platform team. One entry per system. Add systems as QSpace grows.
//
// NAMING CONVENTION FOR ASSET FILES:
//   {YYYYMMDD}_{system_slug}_logo_{layout}_{variant}.{ext}
//
//   layouts:  horizontal  — mark beside wordmark (app bars, headers, emails)
//             vertical    — mark stacked above wordmark (splash, auth, cards)
//             icon        — mark only, no wordmark (favicons, tight spaces)
//
//   variants: primary_color — render the asset as-is (colored SVG)
//             white / black — DO NOT create separate files for these.
//                             Apply a ColorFilter at render time:
//                             ColorFilter.mode(Colors.white, BlendMode.srcIn)
//                             ColorFilter.mode(Colors.black, BlendMode.srcIn)
//
//   Example: 20260503_qspace_pages_logo_horizontal_primary_color.svg
//
// CLASS NAMING:
//   Each system gets one abstract class named QSpace{System}Logo (singular).
//   It is one logo with three layout variations — not three separate logos.
//
// ADDING A NEW SYSTEM:
//   1. Create logo SVG files in assets/logos/ following the naming convention.
//   2. Register paths in pubspec.yaml under flutter: assets:.
//   3. Add a new abstract class below (copy QSpacePayLogo as the template).
//   4. Set the path constants — never leave an existing-asset field as null.
//
// USAGE — QSpace Pages (assets exist):
//   import 'package:qspace_resources/qspace_resources.dart';
//   SvgPicture.asset(QSpacePagesLogo.horizontal);                 // colored
//   SvgPicture.asset(                                              // white variant
//     QSpacePagesLogo.icon,
//     colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//   );
//
// USAGE — QSpace Pay / Pulse (null-safe guard until assets land):
//   if (QSpacePayLogo.horizontal != null) {
//     SvgPicture.asset(QSpacePayLogo.horizontal!);
//   }
//
// BrandLogo widget (app_branding.dart) handles null automatically —
// it falls back to the typographic wordmark when a path is null.

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// Package-scoped asset prefix. All paths go through this so a package rename
// is a single-line change here rather than a find-and-replace across the file.
const String _kPkg = 'packages/qspace_resources/assets/logos/';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// QSpace Pages
// ─────────────────────────────────────────────────────────────────────────────
//
// Assets confirmed present. All three layouts ship as colored SVGs.
// White/black variants are derived at render time via ColorFilter.
//
// Usage in QSpace Pages (main app):
//   import 'package:qspace_resources/qspace_resources.dart';
//   SvgPicture.asset(QSpacePagesLogo.horizontal);
//   // For BrandConfig, see brand_config.dart — it references these paths.

abstract class QSpacePagesLogo {
  // Mark beside wordmark — default for app bars, landing pages, emails.
  static const String horizontal =
      '${_kPkg}20260503_qspace_pages_logo_horizontal_primary_color.svg';

  // Mark stacked above wordmark — auth screens, splash, card headers.
  static const String vertical =
      '${_kPkg}20260503_qspace_pages_logo_vertical_primary_color.svg';

  // Mark only, no wordmark — favicons, tight spaces, avatar fallbacks.
  static const String icon =
      '${_kPkg}20260503_qspace_pages_logo_icon_primary_color.svg';
}


// ─────────────────────────────────────────────────────────────────────────────
// QSpace Pay
// ─────────────────────────────────────────────────────────────────────────────
//
// Assets pending. Add files matching the naming convention, then replace
// the null values with the correct paths. Null → BrandLogo falls back gracefully.
//
// Expected filenames when ready:
//   20260503_qspace_pay_logo_horizontal_primary_color.svg
//   20260503_qspace_pay_logo_vertical_primary_color.svg
//   20260503_qspace_pay_logo_icon_primary_color.svg

abstract class QSpacePayLogo {
  static const String? horizontal = null; // TODO: add asset
  static const String? vertical   = null; // TODO: add asset
  static const String? icon       = null; // TODO: add asset
}


// ─────────────────────────────────────────────────────────────────────────────
// QSpace Pulse
// ─────────────────────────────────────────────────────────────────────────────
//
// Assets pending. Same procedure as QSpacePayLogo above.
//
// Expected filenames when ready:
//   20260503_qspace_pulse_logo_horizontal_primary_color.svg
//   20260503_qspace_pulse_logo_vertical_primary_color.svg
//   20260503_qspace_pulse_logo_icon_primary_color.svg

abstract class QSpacePulseLogo {
  static const String? horizontal = null; // TODO: add asset
  static const String? vertical   = null; // TODO: add asset
  static const String? icon       = null; // TODO: add asset
}