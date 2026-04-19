// lib/experience/spaces/space_admin/screens/screen_admin_features.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — admin controls for space_dev screens + feature flags.
//     Section A: section-level visibility (3 toggles)
//     Section B: component-level visibility (6 toggles)
//     Section C: QSpaceFeatureFlags display (read-only for now)
//     Bottom: "Preview Dev Screen" button uses AdminPanelControllerScope to
//       open the shared preview panel instead of Navigator.push — consistent
//       with the rest of the admin UX.
//     "Restore Defaults" resets all dev screen settings in one tap.
//   • Removed Navigator.push ScreenRoadmapHome pattern — preview panel
//     is the canonical preview mechanism across all admin screens.
//   • File path corrected to screens/ folder per Canon v2.0.0.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/dev_screen_settings.dart';
import '../widgets/admin_preview_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kPagePad      = 32.0;
const double _kMaxWidth     = 880.0;
const double _kSectionGap   = 32.0;
const double _kPreviewBtnH  = 52.0;

// ── Copy ──────────────────────────────────────────────────────────────────────
const String _kPreviewBtnLabel  = 'Open Brand Preview Panel';
const String _kRestoreLabel     = 'Restore Defaults';
const String _kFeatureFlagsNote =
    'Feature flag editing is available in Cycle 3. '
    'Values below reflect the current QSpaceFeatureFlags defaults.';

// ── Feature flags display data — (label, enabled) ────────────────────────────
// Sourced from QSpaceFeatureFlags() defaults. Not editable yet.
const _kFeatureFlags = [
  ('Trial Signup',      true),
  ('Pricing Table',     true),
  ('Testimonials',      true),
  ('Analytics Consent', true),
  ('Dark Mode Toggle',  true),
  ('API Docs',          false),
  ('Blog Section',      false),
  ('Live Chat',         false),
  ('Multi-Language',    false),
];

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


class ScreenAdminFeatures extends StatelessWidget {
  const ScreenAdminFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    // Reading settings here makes this widget rebuild on every notifyListeners()
    // call — keeps toggle state in sync without setState().
    final settings = DevScreenSettingsScope.of(context);

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
                  title: 'Features & Dev Screen',
                  subtitle: 'Control what appears on space_dev screens in real time.',
                ),
                const SizedBox(height: _kSectionGap),

                // Section A — section-level visibility gates
                _AdminSection(
                  label: 'Roadmap Screen — Section Visibility',
                  child: _SectionToggles(settings: settings),
                ),
                const SizedBox(height: _kSectionGap),

                // Section B — component-level gates
                _AdminSection(
                  label: 'Roadmap Screen — Component Visibility',
                  child: _ComponentToggles(settings: settings),
                ),
                const SizedBox(height: _kSectionGap),

                // Restore defaults
                _RestoreDefaultsButton(settings: settings),
                const SizedBox(height: _kSectionGap),

                // Section C — feature flags (read-only until Cycle 3)
                _AdminSection(
                  label: 'Feature Flags',
                  child: _FeatureFlagsSection(),
                ),
                const SizedBox(height: _kSectionGap),

                // Preview panel CTA — opens the shared brand preview panel.
                // In a future cycle this could open a space_dev screen preview instead.
                _PreviewButton(
                  onPressed: () => AdminPanelControllerScope.of(context).open(),
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
// _SectionToggles
// ─────────────────────────────────────────────────────────────────────────────

class _SectionToggles extends StatelessWidget {
  final DevScreenSettings settings;
  const _SectionToggles({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _ToggleRow(
            label: 'Core Section',
            description: 'Identity, architecture layers, branch status',
            value: settings.showSectionCore,
            onChanged: settings.setSectionCore,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Context Section',
            description: 'Roadmap, phase cards, countdown, progress bar',
            value: settings.showSectionContext,
            onChanged: settings.setSectionContext,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Connect Section',
            description: 'Active step, commit target, distribution models',
            value: settings.showSectionConnect,
            onChanged: settings.setSectionConnect,
            isLast: true,
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ComponentToggles
// ─────────────────────────────────────────────────────────────────────────────

class _ComponentToggles extends StatelessWidget {
  final DevScreenSettings settings;
  const _ComponentToggles({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _ToggleRow(
            label: 'Branch Status',
            description: 'Branch name + current phase pills in section_core',
            value: settings.showBranchStatus,
            onChanged: settings.setBranchStatus,
            // Dim — still toggleable, just won't do anything visible until
            // the parent section is re-enabled.
            dimmed: !settings.showSectionCore,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Architecture Layers',
            description: 'Layer badge row (canon, suite, client, etc.)',
            value: settings.showArchLayers,
            onChanged: settings.setArchLayers,
            dimmed: !settings.showSectionCore,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Countdown Timer',
            description: 'Live MVP countdown badge in section_context header',
            value: settings.showCountdown,
            onChanged: settings.setCountdown,
            dimmed: !settings.showSectionContext,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Progress Bar',
            description: 'Overall sprint progress bar below the ROADMAP label',
            value: settings.showProgressBar,
            onChanged: settings.setProgressBar,
            dimmed: !settings.showSectionContext,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Phase Cards',
            description: 'Horizontal scrolling phase card list',
            value: settings.showPhaseCards,
            onChanged: settings.setPhaseCards,
            dimmed: !settings.showSectionContext,
          ),
          Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            label: 'Distribution Models',
            description: 'Model 1 / 2 / 3 badges in section_connect',
            value: settings.showDistModels,
            onChanged: settings.setDistModels,
            dimmed: !settings.showSectionConnect,
            isLast: true,
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _RestoreDefaultsButton
// ─────────────────────────────────────────────────────────────────────────────

class _RestoreDefaultsButton extends StatelessWidget {
  final DevScreenSettings settings;
  const _RestoreDefaultsButton({required this.settings});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        settings.resetToDefaults();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dev screen settings restored to defaults.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.surfaceLit,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.cardBR,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restore_outlined, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              _kRestoreLabel,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _FeatureFlagsSection
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureFlagsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(message: _kFeatureFlagsNote),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: _kFeatureFlags.asMap().entries.map((entry) {
              final i    = entry.key;
              final flag = entry.value;
              return Column(
                children: [
                  _FlagRow(label: flag.$1, enabled: flag.$2),
                  if (i < _kFeatureFlags.length - 1)
                    Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FlagRow extends StatelessWidget {
  final String label;
  final bool enabled;
  const _FlagRow({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16,
            color: enabled ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: enabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.success.withValues(alpha: 0.10)
                  : AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              enabled ? 'ON' : 'OFF',
              style: AppTypography.caption.copyWith(
                color: enabled ? AppColors.success : AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _PreviewButton
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PreviewButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kPreviewBtnH,
      child: DecoratedBox(
        decoration: AppDecorations.primaryButton,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          ),
          icon: const Icon(Icons.preview_outlined, size: 18, color: Colors.white),
          label: Text(_kPreviewBtnLabel, style: AppTypography.button),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ToggleRow — reusable admin toggle with label + description + dimming
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;
  final bool dimmed;

  const _ToggleRow({
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
    this.isLast  = false,
    this.dimmed  = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: dimmed ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: AppTypography.caption.copyWith(
                      color: dimmed ? AppColors.textMuted : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            inactiveThumbColor: AppColors.textMuted,
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