// lib/experience/spaces/space_admin/widgets/admin_preview_panel.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — AdminPanelController (ChangeNotifier) +
//     AdminPanelControllerScope (InheritedNotifier) + AdminPreviewPanel widget.
//     Panel slides in from the right (Claude artifact-style). Shows Live vs
//     Draft tabs. Full-screen button opens a split-view dialog for side-by-side
//     comparison before publishing. Renders a _BrandMockPage using the
//     appropriate BrandConfig — no dependency on actual public screens.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/admin_brand_draft.dart';
import '../../../../core/style/brand_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kHeaderH         = 52.0;
const double _kTabBarH         = 40.0;
const double _kMockHeroH       = 180.0;
const double _kMockCardH       = 80.0;
const double _kMockBtnH        = 40.0;
const double _kMockBtnR        = 20.0;  // pill border radius
const double _kMockSectionGap  = 16.0;
const double _kMockPad         = 20.0;
const double _kSplitMinWidth   = 320.0; // minimum width for each split pane

// ── Copy ──────────────────────────────────────────────────────────────────────
const String _kTabLive         = 'Live';
const String _kTabDraft        = 'Draft';
const String _kNoChangesMsg    = 'No changes yet. Edit brand tokens to see a live preview here.';
const String _kSplitTitle      = 'Compare: Live vs Draft';
const String _kSplitLiveLabel  = 'LIVE';
const String _kSplitDraftLabel = 'DRAFT';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// AdminPanelController — owns open/close state for the preview panel
// ─────────────────────────────────────────────────────────────────────────────

class AdminPanelController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void open()   { if (!_isOpen)  { _isOpen = true;  notifyListeners(); } }
  void close()  { if (_isOpen)   { _isOpen = false; notifyListeners(); } }
  void toggle() { _isOpen = !_isOpen; notifyListeners(); }
}


// ─────────────────────────────────────────────────────────────────────────────
// AdminPanelControllerScope — InheritedNotifier wrapper
// ─────────────────────────────────────────────────────────────────────────────
//
// Wrap at QAdminShell level. Any descendant (brand screen "Preview" button,
// etc.) can call AdminPanelControllerScope.of(context).open().

class AdminPanelControllerScope extends InheritedNotifier<AdminPanelController> {
  const AdminPanelControllerScope({
    super.key,
    required AdminPanelController controller,
    required super.child,
  }) : super(notifier: controller);

  static AdminPanelController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminPanelControllerScope>();
    assert(
      scope != null,
      'AdminPanelControllerScope not found. '
      'Wrap at QAdminShell level with AdminPanelControllerScope.',
    );
    return scope!.notifier!;
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AdminPreviewPanel — the actual panel widget
// ─────────────────────────────────────────────────────────────────────────────
//
// Reads AdminBrandDraftScope and AdminPanelControllerScope from context.
// The shell handles the slide animation (AnimatedContainer width);
// this widget just fills whatever space it's given.

class AdminPreviewPanel extends StatefulWidget {
  const AdminPreviewPanel({super.key});

  @override
  State<AdminPreviewPanel> createState() => _AdminPreviewPanelState();
}

class _AdminPreviewPanelState extends State<AdminPreviewPanel>
    with SingleTickerProviderStateMixin {

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    // Two tabs: Live | Draft. Default to Draft so changes are immediately visible.
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openFullScreenSplit(BuildContext context, AdminBrandDraft draft) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _SplitScreenDialog(draft: draft),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft     = AdminBrandDraftScope.of(context);
    final panelCtrl = AdminPanelControllerScope.of(context);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // ── Panel header ────────────────────────────────────────────────
          SizedBox(
            height: _kHeaderH,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.preview_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Brand Preview',
                    style: AppTypography.h5.copyWith(fontSize: 13),
                  ),

                  // Draft changes indicator pill
                  if (draft.hasDraftChanges) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        'UNSAVED',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Full-screen split view button
                  _HeaderIconBtn(
                    icon: Icons.open_in_full_outlined,
                    tooltip: 'Compare Live vs Draft',
                    onTap: () => _openFullScreenSplit(context, draft),
                  ),
                  const SizedBox(width: 4),

                  // Close panel
                  _HeaderIconBtn(
                    icon: Icons.close,
                    tooltip: 'Close preview',
                    onTap: panelCtrl.close,
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Tab bar ─────────────────────────────────────────────────────
          SizedBox(
            height: _kTabBarH,
            child: TabBar(
              controller: _tabCtrl,
              labelStyle: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              unselectedLabelStyle: AppTypography.caption.copyWith(fontSize: 11),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: _kTabLive),
                Tab(text: _kTabDraft),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _BrandMockPage(config: draft.liveConfig),
                _BrandMockPage(config: draft.draftConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SplitScreenDialog — full-screen Live | Draft comparison
// ─────────────────────────────────────────────────────────────────────────────

class _SplitScreenDialog extends StatelessWidget {
  final AdminBrandDraft draft;
  const _SplitScreenDialog({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.cardBR,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.compare_arrows_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(_kSplitTitle, style: AppTypography.h4),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),

            // Split panes
            Expanded(
              child: Row(
                children: [
                  // Live pane
                  Expanded(
                    child: Column(
                      children: [
                        _SplitPaneLabel(
                          label: _kSplitLiveLabel,
                          color: AppColors.success,
                        ),
                        Expanded(child: _BrandMockPage(config: draft.liveConfig)),
                      ],
                    ),
                  ),

                  VerticalDivider(width: 1, thickness: 1, color: AppColors.border),

                  // Draft pane
                  Expanded(
                    child: Column(
                      children: [
                        _SplitPaneLabel(
                          label: _kSplitDraftLabel,
                          color: AppColors.warning,
                        ),
                        Expanded(child: _BrandMockPage(config: draft.draftConfig)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitPaneLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SplitPaneLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: 0.08),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.overline.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _BrandMockPage — renders a sample UI in the given BrandConfig
// ─────────────────────────────────────────────────────────────────────────────
//
// This is intentionally a standalone mock — it doesn't depend on any public
// screen. That way the preview works correctly even before the merge engine
// is wired. It shows enough of the brand (colors, fonts, identity, buttons,
// cards) to make editing decisions confidently.

class _BrandMockPage extends StatelessWidget {
  final BrandConfig config;
  const _BrandMockPage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero banner
            _MockHero(config: config),
            const SizedBox(height: _kMockSectionGap),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kMockPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buttons row
                  _MockLabel('Buttons'),
                  const SizedBox(height: 8),
                  _MockButtons(config: config),
                  const SizedBox(height: _kMockSectionGap),

                  // Typography
                  _MockLabel('Typography'),
                  const SizedBox(height: 8),
                  _MockTypography(config: config),
                  const SizedBox(height: _kMockSectionGap),

                  // Color palette
                  _MockLabel('Palette'),
                  const SizedBox(height: 8),
                  _MockPalette(config: config),
                  const SizedBox(height: _kMockSectionGap),

                  // Sample cards
                  _MockLabel('Cards'),
                  const SizedBox(height: 8),
                  _MockCards(config: config),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockHero extends StatelessWidget {
  final BrandConfig config;
  const _MockHero({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kMockHeroH,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.primary.withValues(alpha: 0.9),
            config.secondary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_kMockPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: config.wordBold,
                    style: TextStyle(
                      fontFamily: config.fontHero,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: config.wordLight,
                    style: TextStyle(
                      fontFamily: config.fontHero,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              config.tagline,
              style: TextStyle(
                fontFamily: config.fontText,
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_kMockBtnR),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  fontFamily: config.fontText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: config.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockButtons extends StatelessWidget {
  final BrandConfig config;
  const _MockButtons({required this.config});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MockBtn(label: 'Primary', bg: config.primary, fg: Colors.white, font: config.fontText),
        _MockBtn(label: 'Secondary', bg: config.secondary, fg: Colors.white, font: config.fontText),
        _MockBtn(label: 'Accent', bg: config.tertiary, fg: Colors.white, font: config.fontText),
        _MockBtn(
          label: 'Outlined',
          bg: Colors.transparent,
          fg: config.primary,
          font: config.fontText,
          border: config.primary,
        ),
      ],
    );
  }
}

class _MockBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final String font;
  final Color? border;
  const _MockBtn({
    required this.label,
    required this.bg,
    required this.fg,
    required this.font,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kMockBtnH,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_kMockBtnR),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: font,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _MockTypography extends StatelessWidget {
  final BrandConfig config;
  const _MockTypography({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypoRow('Hero', config.fontHero, 20, FontWeight.w700, config.primary),
          _TypoRow('Display', config.fontDisplay, 16, FontWeight.w700, AppColors.textPrimary),
          _TypoRow('Text', config.fontText, 13, FontWeight.w400, AppColors.textSecondary),
          _TypoRow('Accent', config.fontAccent, 12, FontWeight.w500, config.secondary),
          _TypoRow('Signature', config.fontSignature, 15, FontWeight.w400, config.tertiary),
        ],
      ),
    );
  }
}

class _TypoRow extends StatelessWidget {
  final String role;
  final String family;
  final double size;
  final FontWeight weight;
  final Color color;
  const _TypoRow(this.role, this.family, this.size, this.weight, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              role,
              style: AppTypography.caption.copyWith(fontSize: 9),
            ),
          ),
          Expanded(
            child: Text(
              family,
              style: TextStyle(
                fontFamily: family,
                fontSize: size,
                fontWeight: weight,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockPalette extends StatelessWidget {
  final BrandConfig config;
  const _MockPalette({required this.config});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 6,
          child: _PaletteChip(color: config.primary, label: '60%'),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: 3,
          child: _PaletteChip(color: config.secondary, label: '30%'),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: 1,
          child: _PaletteChip(color: config.tertiary, label: '10%'),
        ),
      ],
    );
  }
}

class _PaletteChip extends StatelessWidget {
  final Color color;
  final String label;
  const _PaletteChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smBR,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _MockCards extends StatelessWidget {
  final BrandConfig config;
  const _MockCards({required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: _kMockCardH,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardBR,
            border: Border.all(color: config.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_outline, size: 18, color: config.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    config.appName,
                    style: TextStyle(
                      fontFamily: config.fontDisplay,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    config.domain,
                    style: TextStyle(
                      fontFamily: config.fontAccent,
                      fontSize: 10,
                      color: config.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: config.tertiary.withValues(alpha: 0.08),
            borderRadius: AppRadius.cardBR,
            border: Border.all(color: config.tertiary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: config.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  config.copyright,
                  style: TextStyle(
                    fontFamily: config.fontText,
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MockLabel extends StatelessWidget {
  final String text;
  const _MockLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTypography.overline);
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 14, color: AppColors.textMuted),
        ),
      ),
    );
  }
}