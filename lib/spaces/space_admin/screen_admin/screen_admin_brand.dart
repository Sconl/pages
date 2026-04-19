// lib/experience/spaces/space_admin/screens/screen_admin_brand.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Full redesign — now reads from AND writes to AdminBrandDraft.
//   • 60-30-10 color visualization bar at the top of the Color System section.
//   • Per-color cards with large swatch, hex copy button, role guidance copy,
//     and Edit button that opens _ColorPickerDialog.
//   • Per-font rows now show an inline TextStyle sample and an edit field.
//   • Identity + canvas/motion sections are now editable (TextField +
//     DropdownButton). Changes write to AdminBrandDraft on every keystroke.
//   • Unsaved-changes banner appears when draft diverges from live config.
//   • Preview button opens AdminPanelControllerScope panel.
//   • Generate Config Snippet button shows the paste-ready brand_config.dart
//     CONFIG BLOCK in a dialog with a copy-to-clipboard action.
//   • Discard button resets draft to live state with confirmation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/admin_brand_draft.dart';
import '../../../../core/style/brand_config.dart';
import '../widgets/admin_preview_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kPagePad          = 32.0;
const double _kMaxWidth         = 920.0;
const double _kSectionGap       = 36.0;
const double _kColorSwatchSize  = 88.0;
const double _kColorCardR       = 12.0;
const double _kPaletteBarH      = 64.0;  // 60-30-10 bar height
const double _kPaletteBarR      = 10.0;  // bar corner radius
const double _kFontSampleSize   = 20.0;
const double _kActionBtnH       = 48.0;

// ── 60-30-10 guidance copy ────────────────────────────────────────────────────
const String _kPrimaryGuidance =
    '60% — Dominant brand identity. Hero sections, primary CTAs, focus rings, '
    'navigation highlights. The most recognizable color of your brand. '
    'Use confidently across large surfaces.';
const String _kSecondaryGuidance =
    '30% — Supporting accent. Info chips, secondary CTAs, constellation lines, '
    'complementary UI elements. Should contrast with Primary without competing. '
    'Use to guide attention after Primary.';
const String _kTertiaryGuidance =
    '10% — Warm accent. Use sparingly — live badges, notification highlights, '
    'special callouts, and tertiary CTAs. Overusing it dilutes its impact. '
    'Reserve for truly important moments.';

// ── Font guidance copy ────────────────────────────────────────────────────────
const Map<String, String> _kFontGuidance = {
  'fontHero':
    'Brand moments — splash screen, hero section wordmark, and large display '
    'text. Should feel distinctive and expressive. Only used at large sizes.',
  'fontDisplay':
    'Page and section headings. Clear, authoritative, readable at large sizes. '
    'Used for h1–h4 across all screens.',
  'fontText':
    'Body copy, buttons, inputs, labels. Your workhorse font — used everywhere. '
    'Prioritize readability and rendering quality across sizes.',
  'fontAccent':
    'Numbers, statistics, timestamps, technical badges. Monospaced or structured '
    'fonts work best here. Great for data-heavy UI and code samples.',
  'fontSignature':
    'Emotional moments — greetings, milestones, personal messages, and milestone '
    'celebratory text. Used sparingly for warmth. Should feel human and warm.',
};

// ── Edit note ─────────────────────────────────────────────────────────────────
const String _kEditNote =
    'Changes are saved as a draft. Use "Preview" to see them applied, '
    '"Generate Snippet" to export the brand_config.dart CONFIG BLOCK, '
    'and "Discard" to revert to the last published state.';

// ── Color picker presets — 24 swatches across the spectrum + neutrals ─────────
const List<Color> _kColorPresets = [
  // Violets / Purples
  Color(0xFF9933FF), Color(0xFF6E1FF7), Color(0xFF4C00D9),
  Color(0xFFAD5CFF), Color(0xFFD4A0FF),
  // Blues
  Color(0xFF0F91D2), Color(0xFF1565C0), Color(0xFF0288D1),
  Color(0xFF4FC3F7), Color(0xFF0D47A1),
  // Greens
  Color(0xFF00897B), Color(0xFF2E7D32), Color(0xFF43A047),
  Color(0xFF00E676), Color(0xFF00BFA5),
  // Reds / Pinks
  Color(0xFFE53935), Color(0xFFD81B60), Color(0xFFAD1457),
  Color(0xFFFF4081), Color(0xFFFF7043),
  // Yellows / Ambers
  Color(0xFFFAAF2E), Color(0xFFFBC02D), Color(0xFFFF8F00),
  // Neutral
  Color(0xFF607D8B),
];

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// ScreenAdminBrand
// ─────────────────────────────────────────────────────────────────────────────

class ScreenAdminBrand extends StatefulWidget {
  const ScreenAdminBrand({super.key});

  @override
  State<ScreenAdminBrand> createState() => _ScreenAdminBrandState();
}

class _ScreenAdminBrandState extends State<ScreenAdminBrand> {

  // TextEditingControllers for identity + font fields.
  // Initialized once from AdminBrandDraft in didChangeDependencies.
  // When discard is called, _syncControllers() brings them back in line.
  late TextEditingController _wordBoldCtrl;
  late TextEditingController _wordLightCtrl;
  late TextEditingController _appNameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _domainCtrl;
  late TextEditingController _copyrightCtrl;
  late TextEditingController _fontHeroCtrl;
  late TextEditingController _fontDisplayCtrl;
  late TextEditingController _fontTextCtrl;
  late TextEditingController _fontAccentCtrl;
  late TextEditingController _fontSignatureCtrl;

  AdminBrandDraft? _draft;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDraft = AdminBrandDraftScope.of(context);
    if (!_initialized) {
      _wordBoldCtrl      = TextEditingController(text: newDraft.draftWordBold);
      _wordLightCtrl     = TextEditingController(text: newDraft.draftWordLight);
      _appNameCtrl       = TextEditingController(text: newDraft.draftAppName);
      _taglineCtrl       = TextEditingController(text: newDraft.draftTagline);
      _domainCtrl        = TextEditingController(text: newDraft.draftDomain);
      _copyrightCtrl     = TextEditingController(text: newDraft.draftCopyright);
      _fontHeroCtrl      = TextEditingController(text: newDraft.draftFontHero);
      _fontDisplayCtrl   = TextEditingController(text: newDraft.draftFontDisplay);
      _fontTextCtrl      = TextEditingController(text: newDraft.draftFontText);
      _fontAccentCtrl    = TextEditingController(text: newDraft.draftFontAccent);
      _fontSignatureCtrl = TextEditingController(text: newDraft.draftFontSignature);
      _initialized = true;
    }
    _draft = newDraft;
  }

  @override
  void dispose() {
    _wordBoldCtrl.dispose();
    _wordLightCtrl.dispose();
    _appNameCtrl.dispose();
    _taglineCtrl.dispose();
    _domainCtrl.dispose();
    _copyrightCtrl.dispose();
    _fontHeroCtrl.dispose();
    _fontDisplayCtrl.dispose();
    _fontTextCtrl.dispose();
    _fontAccentCtrl.dispose();
    _fontSignatureCtrl.dispose();
    super.dispose();
  }

  // Brings all controllers back in sync after a discard.
  void _syncControllers(AdminBrandDraft draft) {
    _wordBoldCtrl.text      = draft.draftWordBold;
    _wordLightCtrl.text     = draft.draftWordLight;
    _appNameCtrl.text       = draft.draftAppName;
    _taglineCtrl.text       = draft.draftTagline;
    _domainCtrl.text        = draft.draftDomain;
    _copyrightCtrl.text     = draft.draftCopyright;
    _fontHeroCtrl.text      = draft.draftFontHero;
    _fontDisplayCtrl.text   = draft.draftFontDisplay;
    _fontTextCtrl.text      = draft.draftFontText;
    _fontAccentCtrl.text    = draft.draftFontAccent;
    _fontSignatureCtrl.text = draft.draftFontSignature;
  }

  void _openColorPicker(BuildContext context, Color current, void Function(Color) onPick) {
    showDialog<Color>(
      context: context,
      builder: (_) => _ColorPickerDialog(initialColor: current),
    ).then((picked) {
      if (picked != null) onPick(picked);
    });
  }

  Future<void> _handleDiscard(BuildContext context, AdminBrandDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLit,
        title: Text('Discard Changes?', style: AppTypography.h4),
        content: Text(
          'All unsaved edits will be lost and the brand will revert to the last published state.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep Editing', style: AppTypography.bodySmall),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: AppTypography.button),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      draft.discardDraft();
      _syncControllers(draft);
      setState(() {});
    }
  }

  void _handleGenerateSnippet(BuildContext context, AdminBrandDraft draft) {
    final snippet = draft.generateConfigSnippet();
    showDialog(
      context: context,
      builder: (_) => _SnippetDialog(snippet: snippet),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reading draft here means this screen rebuilds on every setter call.
    final draft = AdminBrandDraftScope.of(context);

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
                  subtitle: 'Edit and preview brand tokens. Changes are drafts until you generate the config snippet.',
                ),
                const SizedBox(height: 16),

                // Edit note
                _InfoBanner(message: _kEditNote),
                const SizedBox(height: 12),

                // Unsaved changes banner — only visible when draft differs from live
                if (draft.hasDraftChanges)
                  _DraftChangesBanner(
                    onPreview: () => AdminPanelControllerScope.of(context).open(),
                    onGenerate: () => _handleGenerateSnippet(context, draft),
                    onDiscard: () => _handleDiscard(context, draft),
                  ),

                if (draft.hasDraftChanges) const SizedBox(height: 12),
                const SizedBox(height: _kSectionGap - 12),

                // ── Color System ───────────────────────────────────────────
                _AdminSection(
                  label: 'Color System',
                  child: _ColorSystemSection(
                    draft: draft,
                    onEditColor: (current, onPick) =>
                        _openColorPicker(context, current, onPick),
                  ),
                ),
                const SizedBox(height: _kSectionGap),

                // ── Typography ─────────────────────────────────────────────
                _AdminSection(
                  label: 'Typography Roles',
                  child: _TypographySection(
                    draft: draft,
                    heroCtrl:      _fontHeroCtrl,
                    displayCtrl:   _fontDisplayCtrl,
                    textCtrl:      _fontTextCtrl,
                    accentCtrl:    _fontAccentCtrl,
                    signatureCtrl: _fontSignatureCtrl,
                  ),
                ),
                const SizedBox(height: _kSectionGap),

                // ── Canvas & Motion ────────────────────────────────────────
                _AdminSection(
                  label: 'Canvas & Motion',
                  child: _CanvasMotionSection(draft: draft),
                ),
                const SizedBox(height: _kSectionGap),

                // ── Brand Identity ─────────────────────────────────────────
                _AdminSection(
                  label: 'Brand Identity',
                  child: _IdentitySection(
                    draft: draft,
                    wordBoldCtrl:  _wordBoldCtrl,
                    wordLightCtrl: _wordLightCtrl,
                    appNameCtrl:   _appNameCtrl,
                    taglineCtrl:   _taglineCtrl,
                    domainCtrl:    _domainCtrl,
                    copyrightCtrl: _copyrightCtrl,
                  ),
                ),
                const SizedBox(height: _kSectionGap),

                // ── Action bar ─────────────────────────────────────────────
                _ActionBar(
                  hasDraftChanges: draft.hasDraftChanges,
                  onPreview:  () => AdminPanelControllerScope.of(context).open(),
                  onGenerate: () => _handleGenerateSnippet(context, draft),
                  onDiscard:  () => _handleDiscard(context, draft),
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
// _ColorSystemSection — 60-30-10 bar + three color cards
// ─────────────────────────────────────────────────────────────────────────────

class _ColorSystemSection extends StatelessWidget {
  final AdminBrandDraft draft;
  final void Function(Color current, void Function(Color) onPick) onEditColor;

  const _ColorSystemSection({
    required this.draft,
    required this.onEditColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 60-30-10 visualization bar
        _SixtyThirtyTen(
          primary: draft.draftPrimary,
          secondary: draft.draftSecondary,
          tertiary: draft.draftTertiary,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap any segment to edit that color directly.',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 24),

        // Primary card
        _ColorTokenCard(
          label: 'Primary',
          role: '60% Dominant',
          color: draft.draftPrimary,
          guidance: _kPrimaryGuidance,
          onEdit: () => onEditColor(draft.draftPrimary, draft.setPrimary),
        ),
        const SizedBox(height: 12),

        // Secondary card
        _ColorTokenCard(
          label: 'Secondary',
          role: '30% Supporting',
          color: draft.draftSecondary,
          guidance: _kSecondaryGuidance,
          onEdit: () => onEditColor(draft.draftSecondary, draft.setSecondary),
        ),
        const SizedBox(height: 12),

        // Tertiary card
        _ColorTokenCard(
          label: 'Tertiary',
          role: '10% Accent',
          color: draft.draftTertiary,
          guidance: _kTertiaryGuidance,
          onEdit: () => onEditColor(draft.draftTertiary, draft.setTertiary),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SixtyThirtyTen — proportional color bar visualization
// ─────────────────────────────────────────────────────────────────────────────

class _SixtyThirtyTen extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const _SixtyThirtyTen({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kPaletteBarH,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kPaletteBarR),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 6,
            child: _BarSegment(color: primary, label: '60%\nPrimary'),
          ),
          Flexible(
            flex: 3,
            child: _BarSegment(color: secondary, label: '30%\nSecondary'),
          ),
          Flexible(
            flex: 1,
            child: _BarSegment(color: tertiary, label: '10%'),
          ),
        ],
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  final Color color;
  final String label;
  const _BarSegment({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ColorTokenCard — single color card with swatch, hex copy, guidance, edit
// ─────────────────────────────────────────────────────────────────────────────

class _ColorTokenCard extends StatelessWidget {
  final String label;
  final String role;
  final Color color;
  final String guidance;
  final VoidCallback onEdit;

  const _ColorTokenCard({
    required this.label,
    required this.role,
    required this.color,
    required this.guidance,
    required this.onEdit,
  });

  String get _hexString {
    final argb = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${argb.substring(2)}';
  }

  void _copyHex(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _hexString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_hexString copied to clipboard',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surfaceLit,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_kColorCardR),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large swatch
          GestureDetector(
            onTap: onEdit,
            child: Tooltip(
              message: 'Click to edit color',
              child: Container(
                width: _kColorSwatchSize,
                height: _kColorSwatchSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.edit_outlined, size: 20, color: Colors.white70),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTypography.h5.copyWith(fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        role,
                        style: AppTypography.caption.copyWith(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Hex value with copy button
                Row(
                  children: [
                    Text(
                      _hexString,
                      style: AppTypography.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontFamily: BrandCopy.fontAccent,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _copyHex(context),
                      child: Tooltip(
                        message: 'Copy hex',
                        child: Icon(Icons.copy_outlined, size: 13, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Guidance text
                Text(
                  guidance,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),

                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.colorize_outlined, size: 13, color: color),
                        const SizedBox(width: 6),
                        Text(
                          'Pick Color',
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ColorPickerDialog — hex input + preset grid
// ─────────────────────────────────────────────────────────────────────────────

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {

  late Color _selected;
  late TextEditingController _hexCtrl;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
    _hexCtrl  = TextEditingController(text: _toHex(_selected));
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  String _toHex(Color c) {
    final argb = c.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${argb.substring(2)}';
  }

  Color? _parseHex(String raw) {
    final clean = raw.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final v = int.tryParse('FF$clean', radix: 16);
      return v != null ? Color(v) : null;
    }
    if (clean.length == 8) {
      final v = int.tryParse(clean, radix: 16);
      return v != null ? Color(v) : null;
    }
    return null;
  }

  void _onHexChanged(String value) {
    final parsed = _parseHex(value);
    setState(() {
      if (parsed != null) {
        _selected  = parsed;
        _hexError  = null;
      } else {
        _hexError = 'Enter a valid hex (e.g. #9933FF)';
      }
    });
  }

  void _selectPreset(Color c) {
    setState(() {
      _selected = c;
      _hexCtrl.text = _toHex(c);
      _hexError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceLit,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      title: Text('Pick a Color', style: AppTypography.h4),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live preview swatch
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: _selected,
                borderRadius: AppRadius.smBR,
                border: Border.all(color: _selected.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: _selected.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hex input
            TextField(
              controller: _hexCtrl,
              onChanged: _onHexChanged,
              style: AppTypography.bodySmall.copyWith(fontFamily: BrandCopy.fontAccent),
              decoration: InputDecoration(
                labelText: 'Hex Code',
                labelStyle: AppTypography.caption,
                hintText: '#9933FF',
                errorText: _hexError,
                filled: true,
                fillColor: AppColors.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBR,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBR,
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBR,
                  borderSide: BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            Text('Presets', style: AppTypography.overline),
            const SizedBox(height: 8),

            // 4-column preset grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kColorPresets.map((c) {
                final isActive = _selected == c;
                return GestureDetector(
                  onTap: () => _selectPreset(c),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.transparent,
                        width: isActive ? 2 : 0,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 6)]
                          : null,
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.bodySmall),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selected,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          ),
          onPressed: _hexError == null
              ? () => Navigator.pop(context, _selected)
              : null,
          child: Text('Apply', style: AppTypography.button),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _TypographySection — 5 font rows with sample rendering + edit field
// ─────────────────────────────────────────────────────────────────────────────

class _TypographySection extends StatelessWidget {
  final AdminBrandDraft draft;
  final TextEditingController heroCtrl;
  final TextEditingController displayCtrl;
  final TextEditingController textCtrl;
  final TextEditingController accentCtrl;
  final TextEditingController signatureCtrl;

  const _TypographySection({
    required this.draft,
    required this.heroCtrl,
    required this.displayCtrl,
    required this.textCtrl,
    required this.accentCtrl,
    required this.signatureCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        label:   'fontHero',
        roleKey: 'fontHero',
        ctrl:    heroCtrl,
        sample:  '${draft.draftWordBold}${draft.draftWordLight}',
        setter:  draft.setFontHero,
        current: draft.draftFontHero,
      ),
      (
        label:   'fontDisplay',
        roleKey: 'fontDisplay',
        ctrl:    displayCtrl,
        sample:  'Page Heading',
        setter:  draft.setFontDisplay,
        current: draft.draftFontDisplay,
      ),
      (
        label:   'fontText',
        roleKey: 'fontText',
        ctrl:    textCtrl,
        sample:  'Body copy and buttons',
        setter:  draft.setFontText,
        current: draft.draftFontText,
      ),
      (
        label:   'fontAccent',
        roleKey: 'fontAccent',
        ctrl:    accentCtrl,
        sample:  '42,000 · 99.9%',
        setter:  draft.setFontAccent,
        current: draft.draftFontAccent,
      ),
      (
        label:   'fontSignature',
        roleKey: 'fontSignature',
        ctrl:    signatureCtrl,
        sample:  'Welcome back',
        setter:  draft.setFontSignature,
        current: draft.draftFontSignature,
      ),
    ];

    return Column(
      children: rows.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _FontRow(
          label:    r.label,
          roleKey:  r.roleKey,
          ctrl:     r.ctrl,
          sample:   r.sample,
          fontName: r.current,
          onChanged: (val) {
            if (val.trim().isNotEmpty) r.setter(val.trim());
          },
        ),
      )).toList(),
    );
  }
}

class _FontRow extends StatelessWidget {
  final String label;
  final String roleKey;
  final TextEditingController ctrl;
  final String sample;
  final String fontName;
  final ValueChanged<String> onChanged;

  const _FontRow({
    required this.label,
    required this.roleKey,
    required this.ctrl,
    required this.sample,
    required this.fontName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
                ),
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Editable font name
              Expanded(
                child: TextField(
                  controller: ctrl,
                  onChanged: onChanged,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Font family name',
                    hintStyle: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Live sample — rendered in the specified font family
          Text(
            sample,
            style: TextStyle(
              fontFamily: fontName,
              fontSize: _kFontSampleSize,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Guidance
          Text(
            _kFontGuidance[roleKey] ?? '',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _CanvasMotionSection — dropdowns for personality + motion
// ─────────────────────────────────────────────────────────────────────────────

class _CanvasMotionSection extends StatelessWidget {
  final AdminBrandDraft draft;
  const _CanvasMotionSection({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _DropdownRow<CanvasPersonality>(
            label: 'Canvas Personality',
            guidance:
                'Controls the animated background on public pages. energetic = '
                'constellation particles. calm = aurora. minimal = solid. '
                'corporate = grid. dramatic = aurora sweep.',
            value: draft.draftCanvasPersonality,
            items: CanvasPersonality.values,
            displayName: (v) => v.name,
            onChanged: draft.setCanvasPersonality,
          ),
          Divider(height: 24, color: AppColors.border),
          _DropdownRow<MotionIntensity>(
            label: 'Motion Intensity',
            guidance:
                'full = animated canvas + particles (default). subtle = gentle '
                'gradient only. none = completely static — best for accessibility.',
            value: draft.draftMotionIntensity,
            items: MotionIntensity.values,
            displayName: (v) => v.name,
            onChanged: draft.setMotionIntensity,
          ),
        ],
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final String guidance;
  final T value;
  final List<T> items;
  final String Function(T) displayName;
  final ValueChanged<T> onChanged;

  const _DropdownRow({
    required this.label,
    required this.guidance,
    required this.value,
    required this.items,
    required this.displayName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.body.copyWith(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    guidance,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<T>(
              value: value,
              dropdownColor: AppColors.surfaceLit,
              style: AppTypography.bodySmall.copyWith(fontSize: 12),
              underline: Container(height: 1, color: AppColors.border),
              items: items.map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(displayName(item)),
              )).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ],
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _IdentitySection — editable identity copy fields
// ─────────────────────────────────────────────────────────────────────────────

class _IdentitySection extends StatelessWidget {
  final AdminBrandDraft draft;
  final TextEditingController wordBoldCtrl;
  final TextEditingController wordLightCtrl;
  final TextEditingController appNameCtrl;
  final TextEditingController taglineCtrl;
  final TextEditingController domainCtrl;
  final TextEditingController copyrightCtrl;

  const _IdentitySection({
    required this.draft,
    required this.wordBoldCtrl,
    required this.wordLightCtrl,
    required this.appNameCtrl,
    required this.taglineCtrl,
    required this.domainCtrl,
    required this.copyrightCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          _IdentityRow(
            label: 'Word Bold',
            guidance: 'The bold/weighted part of the two-tone wordmark. e.g. "Well" in WellPath.',
            ctrl: wordBoldCtrl,
            onChanged: draft.setWordBold,
          ),
          Divider(height: 1, color: AppColors.border),
          _IdentityRow(
            label: 'Word Light',
            guidance: 'The lighter part of the wordmark. e.g. "Path" in WellPath.',
            ctrl: wordLightCtrl,
            onChanged: draft.setWordLight,
          ),
          Divider(height: 1, color: AppColors.border),
          _IdentityRow(
            label: 'App Name',
            guidance: 'The full app name used in titles, meta tags, and onboarding.',
            ctrl: appNameCtrl,
            onChanged: draft.setAppName,
          ),
          Divider(height: 1, color: AppColors.border),
          _IdentityRow(
            label: 'Tagline',
            guidance: 'One-line brand promise. Used below the wordmark on hero sections.',
            ctrl: taglineCtrl,
            onChanged: draft.setTagline,
          ),
          Divider(height: 1, color: AppColors.border),
          _IdentityRow(
            label: 'Domain',
            guidance: 'The public URL shown in footers and contact sections.',
            ctrl: domainCtrl,
            onChanged: draft.setDomain,
          ),
          Divider(height: 1, color: AppColors.border),
          _IdentityRow(
            label: 'Copyright',
            guidance: 'Footer copyright string. Include the year and legal entity name.',
            ctrl: copyrightCtrl,
            onChanged: draft.setCopyright,
          ),
        ],
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  final String label;
  final String guidance;
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;

  const _IdentityRow({
    required this.label,
    required this.guidance,
    required this.ctrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guidance,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  onChanged: onChanged,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.inputBR,
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.inputBR,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.inputBR,
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _DraftChangesBanner — shows when draft != live
// ─────────────────────────────────────────────────────────────────────────────

class _DraftChangesBanner extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onGenerate;
  final VoidCallback onDiscard;

  const _DraftChangesBanner({
    required this.onPreview,
    required this.onGenerate,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, size: 14, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unsaved changes — preview before generating the config snippet.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          _BannerAction(label: 'Preview', icon: Icons.preview_outlined, onTap: onPreview),
          const SizedBox(width: 6),
          _BannerAction(label: 'Generate', icon: Icons.code_outlined, onTap: onGenerate),
          const SizedBox(width: 6),
          _BannerAction(
            label: 'Discard',
            icon: Icons.undo_outlined,
            onTap: onDiscard,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _BannerAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ActionBar — bottom CTA row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final bool hasDraftChanges;
  final VoidCallback onPreview;
  final VoidCallback onGenerate;
  final VoidCallback onDiscard;

  const _ActionBar({
    required this.hasDraftChanges,
    required this.onPreview,
    required this.onGenerate,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Preview — always available
        Expanded(
          child: SizedBox(
            height: _kActionBtnH,
            child: OutlinedButton.icon(
              onPressed: onPreview,
              icon: const Icon(Icons.preview_outlined, size: 16),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
              ),
            ),
          ),
        ),

        if (hasDraftChanges) ...[
          const SizedBox(width: 10),

          // Generate snippet
          Expanded(
            child: SizedBox(
              height: _kActionBtnH,
              child: DecoratedBox(
                decoration: AppDecorations.primaryButton,
                child: ElevatedButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.code_outlined, size: 16, color: Colors.white),
                  label: Text('Generate Snippet', style: AppTypography.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Discard
          SizedBox(
            height: _kActionBtnH,
            child: OutlinedButton.icon(
              onPressed: onDiscard,
              icon: Icon(Icons.undo_outlined, size: 16, color: AppColors.error),
              label: Text(
                'Discard',
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
              ),
            ),
          ),
        ],
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SnippetDialog — shows the generated brand_config.dart CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class _SnippetDialog extends StatelessWidget {
  final String snippet;
  const _SnippetDialog({required this.snippet});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceLit,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      title: Row(
        children: [
          Icon(Icons.code_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('brand_config.dart Snippet', style: AppTypography.h4),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 13, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Paste this into brand_config.dart, replacing the CONFIG BLOCK. '
                      'In production (Cycle 3), this step writes to overlay.json instead.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 340),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  snippet,
                  style: TextStyle(
                    fontFamily: BrandCopy.fontAccent,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: AppTypography.bodySmall),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: snippet));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Snippet copied to clipboard.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.surfaceLit,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
              ),
            );
          },
          icon: const Icon(Icons.copy_outlined, size: 14),
          label: Text('Copy to Clipboard', style: AppTypography.button),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          ),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Shared layout helpers (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        borderRadius: AppRadius.cardBR,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
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