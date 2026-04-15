// lib/experience/spaces/space_admin/screens/screen_admin_brand.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — read-only brand token preview. Shows the live
//     kBrandDefault values via BrandColors / BrandCopy / AppColors.
//     Editing is a Cycle 3 feature once the admin editor + backend are live.
//     No writes happen here — this is purely presentational.
// ─────────────────────────────────────────────────────────────────────────────
//
// READ-ONLY: This screen never writes to the manifest.
// When the admin editor ships (Cycle 3), this becomes an editable form
// using QAdminForm + AdminMapper from lib/core/admin/.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kPagePad       = 32.0;
const double _kMaxWidth      = 880.0;
const double _kSwatchSize    = 56.0;
const double _kSwatchBorderR = 10.0;
const double _kSectionGap    = 36.0;
const double _kFontSampleSize = 22.0;

// ── Copy ──────────────────────────────────────────────────────────────────────
const String _kEditNote =
    'Brand editing is available from Cycle 3. This screen shows the '
    'current resolved values from kBrandDefault in brand_config.dart.';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


class ScreenAdminBrand extends StatelessWidget {
  const ScreenAdminBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kPagePad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  title: 'Brand',
                  subtitle: 'Live resolved values from kBrandDefault.',
                ),
                const SizedBox(height: 16),

                // Edit note callout
                _InfoBanner(message: _kEditNote),
                const SizedBox(height: _kSectionGap),

                // Colors
                _AdminSection(
                  label: 'Color Seeds',
                  child: _ColorSection(),
                ),
                const SizedBox(height: _kSectionGap),

                // Typography roles
                _AdminSection(
                  label: 'Font Roles',
                  child: _FontSection(),
                ),
                const SizedBox(height: _kSectionGap),

                // Canvas + motion
                _AdminSection(
                  label: 'Canvas & Motion',
                  child: _CanvasSection(),
                ),
                const SizedBox(height: _kSectionGap),

                // Identity copy
                _AdminSection(
                  label: 'Brand Identity',
                  child: _IdentitySection(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ColorSection — 3 color swatches with hex values
// ─────────────────────────────────────────────────────────────────────────────

class _ColorSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Reading from AppColors which reads kBrandDefault
    final swatches = [
      ('Primary',   AppColors.primary,   '#9933FF', 'H:270° S:100% L:60% — Deep Violet'),
      ('Secondary', AppColors.secondary, '#0F91D2', 'H:200° S:87%  L:44% — Digital Blue'),
      ('Tertiary',  AppColors.tertiary,  '#FAAF2E', 'H:38°  S:95%  L:58% — Kenyan Amber'),
    ];

    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: swatches.map((s) => _ColorSwatch(
            label: s.$1,
            color: s.$2,
            hex:   s.$3,
            desc:  s.$4,
          )).toList(),
        ),
        const SizedBox(height: 16),
        // Derived palette preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Derived Palette', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniSwatch('Background',   AppColors.background),
                  _MiniSwatch('Surface',      AppColors.surface),
                  _MiniSwatch('Surface Mid',  AppColors.surfaceMid),
                  _MiniSwatch('Surface Lit',  AppColors.surfaceLit),
                  _MiniSwatch('Primary Light',AppColors.primaryLight),
                  _MiniSwatch('Primary Dark', AppColors.primaryDark),
                  _MiniSwatch('Success',      AppColors.success),
                  _MiniSwatch('Warning',      AppColors.warning),
                  _MiniSwatch('Error',        AppColors.error),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final String hex;
  final String desc;

  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.hex,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color swatch
          Container(
            width: _kSwatchSize,
            height: _kSwatchSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(_kSwatchBorderR),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.h5.copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              // Tap to copy hex
              GestureDetector(
                onTap: () => _copyHex(context),
                child: Text(
                  hex,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 180,
                child: Text(desc,
                    style: AppTypography.caption.copyWith(fontSize: 9),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyHex(BuildContext context) {
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$hex copied', style: AppTypography.bodySmall),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _MiniSwatch extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniSwatch(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 9)),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _FontSection — 5 font roles with sample text
// ─────────────────────────────────────────────────────────────────────────────

class _FontSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roles = [
      (label: 'fontHero',      name: BrandCopy.fontHero,      sample: 'Brand & Hero'),
      (label: 'fontDisplay',   name: BrandCopy.fontDisplay,   sample: 'Headings & Titles'),
      (label: 'fontText',      name: BrandCopy.fontText,      sample: 'Body & Buttons'),
      (label: 'fontAccent',    name: BrandCopy.fontAccent,    sample: '42,000 · 99.9%'),
      (label: 'fontSignature', name: BrandCopy.fontSignature, sample: 'Welcome back'),
    ];

    return Column(
      children: roles.map((r) => _FontRow(
        roleLabel:  r.label,
        fontName:   r.name,
        sampleText: r.sample,
      )).toList(),
    );
  }
}

class _FontRow extends StatelessWidget {
  final String roleLabel;
  final String fontName;
  final String sampleText;

  const _FontRow({
    required this.roleLabel,
    required this.fontName,
    required this.sampleText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          // Role label badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              roleLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Font name
          SizedBox(
            width: 140,
            child: Text(
              fontName,
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Sample — rendered in the actual font
          Expanded(
            child: Text(
              sampleText,
              style: TextStyle(
                fontFamily: fontName,
                fontSize: _kFontSampleSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _CanvasSection — canvas personality + motion intensity
// ─────────────────────────────────────────────────────────────────────────────

class _CanvasSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = BrandScope.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _TokenRow(label: 'Canvas Personality', value: config.canvasPersonality.name),
          Divider(height: 1, color: AppColors.border),
          _TokenRow(label: 'Motion Intensity', value: config.motionIntensity.name),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _IdentitySection — wordBold, wordLight, tagline, domain, copyright
// ─────────────────────────────────────────────────────────────────────────────

class _IdentitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _TokenRow(label: 'Word Bold',  value: BrandCopy.wordBold),
          Divider(height: 1, color: AppColors.border),
          _TokenRow(label: 'Word Light', value: BrandCopy.wordLight),
          Divider(height: 1, color: AppColors.border),
          _TokenRow(label: 'App Name',   value: BrandCopy.appName),
          Divider(height: 1, color: AppColors.border),
          _TokenRow(label: 'Tagline',    value: BrandCopy.tagline),
          Divider(height: 1, color: AppColors.border),
          _TokenRow(label: 'Domain',     value: BrandCopy.domain),
          Divider(height: 1, color: AppColors.border),
          _TokenRow(label: 'Copyright',  value: BrandCopy.copyright, isLast: true),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _TokenRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTypography.caption.copyWith(
              color: AppColors.textMuted, fontWeight: FontWeight.w600,
            )),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            )),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Shared layout helpers
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        borderRadius: AppRadius.cardBR,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary, height: 1.5,
            )),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _AdminSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _AdminSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.overline),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}