// lib/spaces/space_admin/widgets/admin_preview_panel.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AdminPanelController + AdminPanelControllerScope +
//             AdminPreviewPanel. Live | Draft tabs. Full-screen split dialog.
//             _BrandMockPage renders brand tokens without any public screen dep.
//   v1.1.0 — Import paths updated to lib/spaces/... structure.
//   v1.1.1 — Fixed: removed redundant brand_config.dart import (all used symbols
//             are re-exported by app_style.dart — unnecessary_import warning).
//             Fixed: removed unused super.key from _BrandMockPage constructor
//             (unused_element_parameter warning — key is never passed externally).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/admin_brand_draft.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const double _kHeaderH        = 52.0;
const double _kTabBarH        = 40.0;
const double _kMockHeroH      = 180.0;
const double _kMockBtnH       = 40.0;
const double _kMockBtnR       = 20.0;
const double _kMockSectionGap = 16.0;
const double _kMockPad        = 20.0;

const String _kTabLive         = 'Live';
const String _kTabDraft        = 'Draft';
const String _kSplitTitle      = 'Compare: Live vs Draft';
const String _kSplitLiveLabel  = 'LIVE';
const String _kSplitDraftLabel = 'DRAFT';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// AdminPanelController + Scope
// ─────────────────────────────────────────────────────────────────────────────

class AdminPanelController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;
  void open()   { if (!_isOpen)  { _isOpen = true;  notifyListeners(); } }
  void close()  { if (_isOpen)   { _isOpen = false; notifyListeners(); } }
  void toggle() { _isOpen = !_isOpen; notifyListeners(); }
}

class AdminPanelControllerScope extends InheritedNotifier<AdminPanelController> {
  const AdminPanelControllerScope({
    super.key,
    required AdminPanelController controller,
    required super.child,
  }) : super(notifier: controller);

  static AdminPanelController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminPanelControllerScope>();
    assert(scope != null, 'AdminPanelControllerScope not found. Wrap at QAdminShell level.');
    return scope!.notifier!;
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AdminPreviewPanel
// ─────────────────────────────────────────────────────────────────────────────

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
    // Default to Draft tab — changes show immediately when the panel opens.
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft     = AdminBrandDraftScope.of(context);
    final panelCtrl = AdminPanelControllerScope.of(context);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          SizedBox(
            height: _kHeaderH,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.preview_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Brand Preview', style: AppTypography.h5.copyWith(fontSize: 13)),

                  if (draft.hasDraftChanges) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.35)),
                      ),
                      child: Text('UNSAVED', style: AppTypography.caption.copyWith(
                        color: AppColors.warning, fontSize: 8,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      )),
                    ),
                  ],

                  const Spacer(),

                  _HeaderBtn(
                    icon:    Icons.open_in_full_outlined,
                    tooltip: 'Compare Live vs Draft',
                    onTap:   () => showDialog(
                      context: context,
                      barrierColor: Colors.black87,
                      builder: (_) => _SplitScreenDialog(draft: draft),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _HeaderBtn(
                    icon:    Icons.close,
                    tooltip: 'Close preview',
                    onTap:   panelCtrl.close,
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Tabs ───────────────────────────────────────────────────────
          SizedBox(
            height: _kTabBarH,
            child: TabBar(
              controller:           _tabCtrl,
              labelStyle:           AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: AppTypography.caption.copyWith(fontSize: 11),
              labelColor:           AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor:       AppColors.primary,
              indicatorSize:        TabBarIndicatorSize.label,
              tabs: const [Tab(text: _kTabLive), Tab(text: _kTabDraft)],
            ),
          ),

          Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Tab views ──────────────────────────────────────────────────
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
// _SplitScreenDialog — full-screen Live | Draft side-by-side comparison
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
                  Icon(Icons.compare_arrows_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(_kSplitTitle, style: AppTypography.h4),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 20,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),

            // Split panes
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Column(children: [
                    _PaneLabel(label: _kSplitLiveLabel,  color: AppColors.success),
                    Expanded(child: _BrandMockPage(config: draft.liveConfig)),
                  ])),
                  VerticalDivider(
                      width: 1, thickness: 1, color: AppColors.border),
                  Expanded(child: Column(children: [
                    _PaneLabel(label: _kSplitDraftLabel, color: AppColors.warning),
                    Expanded(child: _BrandMockPage(config: draft.draftConfig)),
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaneLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _PaneLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: 0.08),
      child: Text(label, textAlign: TextAlign.center,
          style: AppTypography.overline.copyWith(color: color, fontSize: 10)),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _BrandMockPage — standalone brand preview, no public screen dependency
// ─────────────────────────────────────────────────────────────────────────────
//
// super.key intentionally removed — this is a private widget instantiated only
// twice internally (Live tab and Draft tab). Key identity is never needed.

class _BrandMockPage extends StatelessWidget {
  final BrandConfig config;
  // No super.key — private widget, never keyed externally.
  const _BrandMockPage({required this.config});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero banner ───────────────────────────────────────────────
            Container(
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
                  mainAxisAlignment:  MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(children: [
                      TextSpan(
                        text: config.wordBold,
                        style: TextStyle(
                            fontFamily: config.fontHero, fontSize: 28,
                            fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      TextSpan(
                        text: config.wordLight,
                        style: TextStyle(
                            fontFamily: config.fontHero, fontSize: 28,
                            fontWeight: FontWeight.w300, color: Colors.white70),
                      ),
                    ])),
                    const SizedBox(height: 6),
                    Text(config.tagline, style: TextStyle(
                      fontFamily: config.fontText,
                      fontSize:   12,
                      color:      Colors.white70,
                    )),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(_kMockBtnR),
                      ),
                      child: Text('Get Started', style: TextStyle(
                        fontFamily:  config.fontText,
                        fontSize:    11,
                        fontWeight:  FontWeight.w600,
                        color:       config.primary,
                      )),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kMockPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _kMockSectionGap),

                  // ── 60-30-10 palette bar ──────────────────────────────
                  Text('PALETTE', style: AppTypography.overline),
                  const SizedBox(height: 8),
                  Row(children: [
                    Flexible(flex: 6, child: _PaletteChip(
                        color: config.primary,   label: '60%')),
                    const SizedBox(width: 4),
                    Flexible(flex: 3, child: _PaletteChip(
                        color: config.secondary, label: '30%')),
                    const SizedBox(width: 4),
                    Flexible(flex: 1, child: _PaletteChip(
                        color: config.tertiary,  label: '10%')),
                  ]),
                  const SizedBox(height: _kMockSectionGap),

                  // ── Buttons ───────────────────────────────────────────
                  Text('BUTTONS', style: AppTypography.overline),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _MockBtn(label: 'Primary',   bg: config.primary,
                        fg: Colors.white, font: config.fontText),
                    _MockBtn(label: 'Secondary', bg: config.secondary,
                        fg: Colors.white, font: config.fontText),
                    _MockBtn(label: 'Accent',    bg: config.tertiary,
                        fg: Colors.white, font: config.fontText),
                    _MockBtn(label: 'Outlined',  bg: Colors.transparent,
                        fg: config.primary, font: config.fontText,
                        border: config.primary),
                  ]),
                  const SizedBox(height: _kMockSectionGap),

                  // ── Typography ────────────────────────────────────────
                  Text('TYPOGRAPHY', style: AppTypography.overline),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        AppColors.surface,
                      borderRadius: AppRadius.cardBR,
                      border:       Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TypoRow('Hero',      config.fontHero,      20,
                            FontWeight.w700, config.primary),
                        _TypoRow('Display',   config.fontDisplay,   16,
                            FontWeight.w700, AppColors.textPrimary),
                        _TypoRow('Text',      config.fontText,      13,
                            FontWeight.w400, AppColors.textSecondary),
                        _TypoRow('Accent',    config.fontAccent,    12,
                            FontWeight.w500, config.secondary),
                        _TypoRow('Signature', config.fontSignature, 15,
                            FontWeight.w400, config.tertiary),
                      ],
                    ),
                  ),
                  const SizedBox(height: _kMockSectionGap),

                  // ── Identity card ─────────────────────────────────────
                  Text('IDENTITY', style: AppTypography.overline),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        AppColors.surface,
                      borderRadius: AppRadius.cardBR,
                      border:       Border.all(
                          color: config.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color:  config.primary.withValues(alpha: 0.15),
                          shape:  BoxShape.circle,
                        ),
                        child: Icon(Icons.star_outline,
                            size: 18, color: config.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(config.appName, style: TextStyle(
                            fontFamily: config.fontDisplay, fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                          Text(config.domain, style: TextStyle(
                            fontFamily: config.fontAccent, fontSize: 10,
                            color: config.secondary,
                          )),
                        ],
                      ),
                    ]),
                  ),
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


// ─────────────────────────────────────────────────────────────────────────────
// Shared private helpers
// ─────────────────────────────────────────────────────────────────────────────

class _PaletteChip extends StatelessWidget {
  final Color  color;
  final String label;
  const _PaletteChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.smBR),
      child: Center(child: Text(label, style: const TextStyle(
        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
      ))),
    );
  }
}

class _MockBtn extends StatelessWidget {
  final String label;
  final Color  bg;
  final Color  fg;
  final String font;
  final Color? border;
  const _MockBtn({
    required this.label, required this.bg, required this.fg,
    required this.font, this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:   _kMockBtnH,
      padding:  const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(_kMockBtnR),
        border:       border != null ? Border.all(color: border!) : null,
      ),
      child: Center(child: Text(label, style: TextStyle(
        fontFamily: font, fontSize: 11,
        fontWeight: FontWeight.w600, color: fg,
      ))),
    );
  }
}

class _TypoRow extends StatelessWidget {
  final String     role;
  final String     family;
  final double     size;
  final FontWeight weight;
  final Color      color;
  const _TypoRow(this.role, this.family, this.size, this.weight, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 60, child: Text(role,
            style: AppTypography.caption.copyWith(fontSize: 9))),
        Expanded(child: Text(family, style: TextStyle(
          fontFamily: family, fontSize: size,
          fontWeight: weight, color: color,
        ), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final String   tooltip;
  final VoidCallback onTap;
  const _HeaderBtn({
    required this.icon, required this.tooltip, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color:        AppColors.background,
            borderRadius: BorderRadius.circular(6),
            border:       Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 14, color: AppColors.textMuted),
        ),
      ),
    );
  }
}