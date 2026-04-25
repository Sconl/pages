// lib/experience/spaces/space_dev/screen_roadmap/screen_roadmap_home.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Moved from lib/experience/spaces/space_value/views/view_engine_status.dart
//   • Renamed class: ViewEngineStatus → ScreenRoadmapHome (Canon v2.0.0 naming)
//   • Branding integrated — AppColors replaces hardcoded hex constants,
//     BrandCopy.fontDisplay/fontAccent replace hardcoded font names
//   • DevScreenSettingsScope wired — all 3 sections and sub-components
//     are now admin-controlled via space_admin's features screen
//   • Config block added per Rule 7 — all tunable values declared at the top
//   • Particle color updated to AppColors.primary (Deep Violet)
//   • Countdown + progress bar check settings before rendering
//   • Phase cards check settings before rendering
//   • Distribution model badges check settings before rendering
//   • Architecture layer badges check settings before rendering
//   • Branch/phase pills check settings before rendering
// ─────────────────────────────────────────────────────────────────────────────
//
// NOTE: Class still extends QPStructure (not QPScreen). The QPScreen rename
// is a pending commit (refactor/architecture-packaging). This file will be
// updated when that migration lands.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/style/app_style.dart';
import '../../core/admin/dev_screen_settings.dart';
import '../../qp_structure.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Typography ────────────────────────────────────────────────────────────────
const double _kTitleFontSize      = 52.0;
const double _kTitleLetterSpacing = -1.5;
const double _kSubtitleFontSize   = 12.0;
const double _kSubtitleTracking   = 0.8;
const double _kLabelFontSize      = 10.0;
const double _kLabelTracking      = 1.8;
const double _kCodeFontSize       = 11.0;
const double _kBadgeFontSize      = 11.0;

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kPageHorizPad   = 32.0;
const double _kPageVertPad    = 28.0;
const double _kMaxContentWidth = 1100.0;
const double _kSectionGap     = 52.0;
const double _kPhaseCardWidth = 196.0;
const double _kPhaseCardHeight = 210.0;

// ── Colors — project-specific accents not covered by AppColors ────────────────
// Countdown timer uses this cyan — it's not a brand color, just a clear readout.
const Color _kCyan    = Color(0xFF22D3EE);

// White opacity shorthands — used widely for muted text/borders on dark bg.
// white20 ≈ 20%, white25 ≈ 25%, white45 ≈ 45% opacity
const Color _kWhite20 = Color(0x33FFFFFF);
const Color _kWhite25 = Color(0x40FFFFFF);
const Color _kWhite45 = Color(0x73FFFFFF);

// ── Project dates (drives countdown + progress bar) ───────────────────────────
final DateTime _projectStart = DateTime(2026, 2, 23);
final DateTime _mvpTarget    = DateTime(2026, 5, 15);

// ── Copy / Branch status ──────────────────────────────────────────────────────
const String _kBranch     = 'refactor/architecture-packaging';
const String _kNextCommit =
    'refactor(experience): adapt first screen to QPScreen contract — sanity check';
const String _kNextStep   =
    'Step 2 — screen_roadmap_home.dart implementing QPStructure';
const String _kCurrentPhase = 'Pre-Cycle 0 · Week 7';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// Architecture layers
// ─────────────────────────────────────────────────────────────────────────────

// (name, description, exists) — tooltip text comes from description
const _kLayers = [
  ('canon/',          'Structural law — immutable contracts',  true),
  ('suite/',          'Nine template suites',                  true),
  ('client/',         'Client overlays + branding',           true),
  ('experience/',     'Spaces, structures, screens',          true),
  ('interface/',      'App shell, components, themes',        true),
  ('infrastructure/', 'Adapter contracts — pending',          false),
];


// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

enum _Status { done, active, pending }

class _Milestone {
  final String title;
  final String commit;
  final bool done;
  const _Milestone(this.title, this.commit, {this.done = false});
}

class _Phase {
  final String label;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<_Milestone> milestones;

  const _Phase({
    required this.label,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.milestones,
  });

  _Status status(DateTime now) {
    if (milestones.every((m) => m.done) || now.isAfter(endDate)) {
      return _Status.done;
    }
    if (milestones.any((m) => m.done) || !now.isBefore(startDate)) {
      return _Status.active;
    }
    return _Status.pending;
  }

  Color color(DateTime now) => switch (status(now)) {
    _Status.done    => AppColors.success,
    _Status.active  => AppColors.primary,
    _Status.pending => Colors.white30,
  };

  String emoji(DateTime now) => switch (status(now)) {
    _Status.done    => '✅',
    _Status.active  => '🚧',
    _Status.pending => '⏳',
  };

  String statusLabel(DateTime now) => switch (status(now)) {
    _Status.done    => 'Completed',
    _Status.active  => 'Active',
    _Status.pending => 'Pending',
  };

  int get doneCount => milestones.where((m) => m.done).length;
}


// ─────────────────────────────────────────────────────────────────────────────
// Phase data
// ─────────────────────────────────────────────────────────────────────────────

final _phases = <_Phase>[
  _Phase(
    label: 'Pre-Cycle 0 · Week 1',
    title: 'Architecture Foundation',
    description:
        'lib/ layers scaffolded, vocabulary locked, QPStructure '
        'contract defined, first concrete screen created, merge engine '
        'implemented, package skeleton built.',
    startDate: DateTime(2026, 2, 23),
    endDate:   DateTime(2026, 3, 7),
    milestones: const [
      _Milestone('Flutter project initialized',
          'chore(init): scaffold Flutter project qspace_pages', done: true),
      _Milestone('lib/ layers created (canon, suite, client, shell)',
          'chore(scaffold): create initial lib/ layer folders', done: true),
      _Milestone('lib/interface/ created — renamed from lib/ui/',
          'refactor(interface): rename ui/ → interface/', done: true),
      _Milestone('experience/spaces/ containers created',
          'feat(experience): create space containers', done: true),
      _Milestone('QPStructure contract defined (buildSectionCore/Context/Connect)',
          'refactor(experience): rename QPView → QPStructure, section_connect API', done: true),
      _Milestone('screen_roadmap_home — first QPStructure screen',
          'refactor(experience): adapt first screen to QPStructure contract'),
      _Milestone('lib/shell/merge_engine.dart — viewRegistry + resolution',
          'feat(shell): implement merge_engine view resolution and viewRegistry'),
      _Milestone('packages/qspace_pages/ — importable Flutter package',
          'feat(package): convert engine to importable Flutter package'),
    ],
  ),
  _Phase(
    label: 'Pre-Cycle 0 · Weeks 2–3',
    title: 'Style System Complete',
    description:
        'lib/core/style/ — 7 files complete. Brand #9933FF, Barlow/Niconne '
        'typography, motion system, BrandScope, AppTheme.forConfig(), '
        'all flutter analyze errors resolved.',
    startDate: DateTime(2026, 3, 8),
    endDate:   DateTime(2026, 4, 15),
    milestones: const [
      _Milestone('brand_config.dart — BrandConfig + BrandScope',
          'feat(style): brand_config with BrandScope + fromManifest()', done: true),
      _Milestone('app_branding.dart — BrandLogoEngine + 5-font roles',
          'feat(style): BrandLogoEngine, LogoShape, LogoVariant', done: true),
      _Milestone('app_theme.dart — AppColors, AppGradients, AppTheme.forConfig()',
          'feat(style): AppTheme.forConfig() runtime multi-tenant theming', done: true),
      _Milestone('app_canvas.dart — 6 BackgroundTypes, all painters',
          'feat(style): app_canvas with aurora/noise/topo/grid painters', done: true),
      _Milestone('app_decorations.dart + app_motion.dart merged',
          'feat(style): decorations, motion, parallax, shimmer, stagger', done: true),
      _Milestone('All flutter analyze errors fixed',
          'fix(style): resolve all lint errors across style system', done: true),
    ],
  ),
  _Phase(
    label: 'Pre-Cycle 0 · Week 4',
    title: 'Backend Scaffold + Landing Page',
    description:
        'Rust backend initialized (Axum + SeaORM + PostgreSQL). '
        'Public landing page live with waitlist.',
    startDate: DateTime(2026, 4, 16),
    endDate:   DateTime(2026, 4, 25),
    milestones: const [
      _Milestone('Rust backend scaffolded (Axum + SeaORM)',
          'chore(backend): scaffold Rust backend project'),
      _Milestone('PostgreSQL — users + tenants migrations',
          'feat(db): initial schema migrations'),
      _Milestone('GET /health endpoint live',
          'feat(backend): health check endpoint'),
      _Milestone('Public landing page deployed with waitlist',
          'feat(web): deploy public landing page'),
    ],
  ),
  _Phase(
    label: 'Cycle 1 · Weeks 5-8',
    title: 'Core MVP — Beacon: Brochure',
    description:
        'Q-prefix component library, Corporate suite QPScreen '
        'screens, manifest integration, first site deployed on DigitalOcean.',
    startDate: DateTime(2026, 4, 26),
    endDate:   DateTime(2026, 5, 23),
    milestones: const [
      _Milestone('Design tokens — lib/canon/canon_tokens.dart',
          'feat(canon): design token definitions'),
      _Milestone('Component library (QButton, QCard, QSection, QGrid)',
          'feat(interface): Q-prefixed component library'),
      _Milestone('Corporate suite screens (screen_home, screen_services, screen_about)',
          'feat(spaces): corporate suite space_value screens'),
      _Milestone('AppShell wired to effectiveManifest',
          'feat(interface): wire AppShell to manifest'),
      _Milestone('ThemeEngine — manifest tokens → Material 3 theme',
          'feat(interface): ThemeEngine from manifest tokens'),
      _Milestone('Beacon: Brochure — first template shipped 🎯',
          'feat(suite): Beacon Brochure corporate suite complete'),
    ],
  ),
  _Phase(
    label: 'Cycle 2 · Weeks 9-12',
    title: 'First Pilot Customers',
    description:
        '2-3 paying customers. Sites delivered within 48 hours. '
        'First testimonial. KES 10K+ MRR.',
    startDate: DateTime(2026, 5, 24),
    endDate:   DateTime(2026, 6, 20),
    milestones: const [
      _Milestone('10+ outreach demos completed', 'chore(sales): outreach phase'),
      _Milestone('Pilot customer 1 — site live',
          'feat(pilot): provision pilot customer 1'),
      _Milestone('Pilot customer 2 — site live',
          'feat(pilot): provision pilot customer 2'),
      _Milestone('First testimonial — KES 10K+ MRR', 'chore: Cycle 2 complete'),
    ],
  ),
  _Phase(
    label: 'Cycle 3 · Weeks 13-16',
    title: 'Productization Begins',
    description:
        '5+ customers, < 30 min provisioning, 2nd template suite shipped, '
        'space_admin control plane live.',
    startDate: DateTime(2026, 6, 21),
    endDate:   DateTime(2026, 7, 18),
    milestones: const [
      _Milestone('Semi-automated provisioning (< 30 min)',
          'feat(backend): automated tenant provisioning'),
      _Milestone('2nd template suite shipped', 'feat(suite): second template suite'),
      _Milestone('space_admin editor live', 'feat(admin): space_admin control plane'),
      _Milestone('5+ customers — < 10% churn', 'chore: Cycle 3 complete'),
    ],
  ),
];


// ─────────────────────────────────────────────────────────────────────────────
// ScreenRoadmapHome — QPStructure implementation
// ─────────────────────────────────────────────────────────────────────────────

class ScreenRoadmapHome extends QPStructure {
  const ScreenRoadmapHome({super.key});

  // Overrides build to add Scaffold + animated background.
  // Section rendering is gated by DevScreenSettings — admin controls
  // which sections appear without touching this class.
  @override
  Widget build(BuildContext context) {
    final settings = DevScreenSettingsScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _ParticleField()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: _kPageHorizPad,
                vertical: _kPageVertPad,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Each section is independently gated by admin settings.
                      // Hiding a section removes it and its spacing entirely.
                      if (settings.showSectionCore) ...[
                        buildSectionCore(context),
                        const SizedBox(height: _kSectionGap),
                      ],
                      if (settings.showSectionContext) ...[
                        buildSectionContext(context),
                        const SizedBox(height: _kSectionGap),
                      ],
                      if (settings.showSectionConnect) ...[
                        buildSectionConnect(context),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSectionCore(BuildContext context) => const _SectionCore();

  @override
  Widget buildSectionContext(BuildContext context) => const _SectionContext();

  @override
  Widget buildSectionConnect(BuildContext context) => const _SectionConnect();
}


// ─────────────────────────────────────────────────────────────────────────────
// section_core — identity, architecture layers, branch status
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCore extends StatelessWidget {
  const _SectionCore();

  @override
  Widget build(BuildContext context) {
    final settings = DevScreenSettingsScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title — uses brand display font (Barlow) per font role system
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'QSpace ',
              style: GoogleFonts.getFont(
                BrandCopy.fontDisplay,
                color: AppColors.textPrimary,
                fontSize: _kTitleFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: _kTitleLetterSpacing,
              ),
            ),
            TextSpan(
              text: 'Pages',
              style: GoogleFonts.getFont(
                BrandCopy.fontDisplay,
                color: AppColors.primary,
                fontSize: _kTitleFontSize,
                fontWeight: FontWeight.w300,
                letterSpacing: _kTitleLetterSpacing,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text(
          'Canonical UI Engine  ·  Architecture Engine  ·  Structural Operating System',
          style: TextStyle(
            color: Colors.white30,
            fontSize: _kSubtitleFontSize,
            letterSpacing: _kSubtitleTracking,
          ),
        ),
        const SizedBox(height: 28),

        // Branch + phase badges — hidden if admin disables branch status
        if (settings.showBranchStatus) ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusPill(
                dot: AppColors.primary,
                label: _kBranch,
                mono: true,
                borderColor: AppColors.primary.withAlpha(80),
                bgColor: AppColors.primary.withAlpha(18),
                textColor: AppColors.primary,
              ),
              _StatusPill(
                dot: AppColors.warning,
                label: _kCurrentPhase,
                borderColor: AppColors.warning.withAlpha(70),
                bgColor: AppColors.warning.withAlpha(15),
                textColor: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],

        // Architecture layers — hidden if admin disables them
        if (settings.showArchLayers) ...[
          Text(
            'ARCHITECTURE LAYERS',
            style: TextStyle(
              color: _kWhite25,
              fontSize: _kLabelFontSize,
              letterSpacing: _kLabelTracking,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kLayers
                .map((l) => _LayerBadge(name: l.$1, description: l.$2, exists: l.$3))
                .toList(),
          ),
          const SizedBox(height: 28),
        ],

        // One-liner — always visible when this section is shown
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(left: BorderSide(color: _kCyan, width: 3)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Text(
            'A platform-agnostic Flutter architecture engine delivering nine template '
            'suites across three distribution models — SaaS, Enterprise, and Package — '
            'powered by a Canon → Suite → Client → Experience → Interface contract '
            'system that ensures a single engine serves unlimited tenants without '
            'vendor lock-in.',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.65),
          ),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// section_context — roadmap, phases, countdown
// ─────────────────────────────────────────────────────────────────────────────

class _SectionContext extends StatelessWidget {
  const _SectionContext();

  @override
  Widget build(BuildContext context) {
    final settings = DevScreenSettingsScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ROADMAP',
              style: TextStyle(
                color: _kWhite25,
                fontSize: _kLabelFontSize,
                letterSpacing: _kLabelTracking,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Countdown is admin-gated independently from the section itself
            if (settings.showCountdown) const _CountdownBadge(),
          ],
        ),

        if (settings.showProgressBar) ...[
          const SizedBox(height: 14),
          const _OverallProgressBar(),
        ],

        if (settings.showPhaseCards) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: _kPhaseCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: _phases.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _PhaseCard(phase: _phases[i]),
            ),
          ),
        ],
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// section_connect — active step, commit target, distribution models
// ─────────────────────────────────────────────────────────────────────────────

class _SectionConnect extends StatelessWidget {
  const _SectionConnect();

  @override
  Widget build(BuildContext context) {
    final settings = DevScreenSettingsScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEXT ACTION',
          style: TextStyle(
            color: _kWhite25,
            fontSize: _kLabelFontSize,
            letterSpacing: _kLabelTracking,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),

        // Active step card — always shown when this section is visible
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.primary.withAlpha(60)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusPill(
                    dot: Colors.red,
                    label: '🔴  NOW',
                    borderColor: Colors.red.withAlpha(60),
                    bgColor: Colors.red.withAlpha(18),
                    textColor: Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _kNextStep,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CodeLine('flutter analyze'),
              const SizedBox(height: 8),
              _CodeLine('git commit -m "$_kNextCommit"'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionChip('Then: migrate screen_home.dart',      AppColors.primary),
                  _ActionChip('Then: implement merge_engine',         Colors.white24),
                  _ActionChip('Then: package skeleton',               Colors.white24),
                ],
              ),
            ],
          ),
        ),

        // Distribution model badges — admin-gated
        if (settings.showDistModels) ...[
          const SizedBox(height: 20),
          Text(
            'DISTRIBUTION MODELS',
            style: TextStyle(
              color: _kWhite25,
              fontSize: _kLabelFontSize,
              letterSpacing: _kLabelTracking,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModelBadge('Model 1', 'SaaS Hosted',            AppColors.primary),
              _ModelBadge('Model 2', 'Enterprise Self-Host',   _kCyan),
              _ModelBadge('Model 3', 'Developer Package',      AppColors.success),
            ],
          ),
        ],
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Countdown badge (stateful — ticks every second)
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownBadge extends StatefulWidget {
  const _CountdownBadge();

  @override
  State<_CountdownBadge> createState() => _CountdownBadgeState();
}

class _CountdownBadgeState extends State<_CountdownBadge> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Tick every second — cheap, no layout work per tick
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = _mvpTarget.difference(_now);
    if (diff.isNegative) {
      return Text(
        'MVP Target Reached 🎯',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final days  = diff.inDays;
    final hours = diff.inHours % 24;
    final mins  = diff.inMinutes % 60;
    final secs  = diff.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('MVP: ', style: TextStyle(color: Colors.white30, fontSize: 11)),
          Text(
            '${days}d ${hours}h ${mins}m ${secs}s',
            style: GoogleFonts.getFont(
              BrandCopy.fontAccent,  // JetBrains Mono for numbers/data
              color: _kCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Overall progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _OverallProgressBar extends StatelessWidget {
  const _OverallProgressBar();

  double get _progress {
    final now   = DateTime.now();
    final total = _mvpTarget.difference(_projectStart).inSeconds;
    final elapsed = now.difference(_projectStart).inSeconds.clamp(0, total);
    return elapsed / total;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_progress * 100).clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Sprint Progress',
              style: TextStyle(color: Colors.white30, fontSize: 11),
            ),
            Text(
              '${pct.toStringAsFixed(1)}%',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Stack(children: [
            Container(
              height: 4, width: w,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              height: 4,
              width: w * _progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, _kCyan]),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 6)],
              ),
            ),
          ]);
        }),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Phase card
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseCard extends StatefulWidget {
  final _Phase phase;
  const _PhaseCard({required this.phase});

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    final color = widget.phase.color(now);
    final done  = widget.phase.doneCount;
    final total = widget.phase.milestones.length;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (_) => _PhaseModal(phase: widget.phase),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: _kPhaseCardWidth,
          padding: const EdgeInsets.all(14),
          transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: _hovered ? color : AppColors.border,
              width: _hovered ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [BoxShadow(color: color.withAlpha(45), blurRadius: 18)]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.phase.label,
                  style: TextStyle(color: Colors.white30, fontSize: 9, letterSpacing: 0.6)),
              const SizedBox(height: 5),
              Text(
                widget.phase.title,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text(widget.phase.emoji(now), style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 5),
                Text(widget.phase.statusLabel(now),
                    style: TextStyle(color: color, fontSize: 11)),
              ]),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: total > 0 ? done / total : 0,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$done/$total milestones',
                      style: TextStyle(color: _kWhite25, fontSize: 10)),
                  if (_hovered)
                    Text('details →',
                        style: TextStyle(
                          color: color.withAlpha(180),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Phase modal
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseModal extends StatelessWidget {
  final _Phase phase;
  const _PhaseModal({required this.phase});

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    final color = phase.color(now);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF080A14),
            border: Border.all(color: color.withAlpha(80)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withAlpha(30), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 18),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(phase.label,
                              style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 0.6)),
                          const SizedBox(height: 4),
                          Text(phase.title,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(phase.emoji(now)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color.withAlpha(60)),
                              ),
                              child: Text(phase.statusLabel(now),
                                  style: TextStyle(
                                    color: color, fontSize: 11, fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          Text(phase.description,
                              style: const TextStyle(color: _kWhite45, fontSize: 12, height: 1.55)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white30, size: 18),
                    ),
                  ],
                ),
              ),
              // Milestones
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MILESTONES',
                          style: TextStyle(
                            color: _kWhite25, fontSize: 10, letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 14),
                      ...phase.milestones.asMap().entries.map((e) => _MilestoneRow(
                        milestone: e.value,
                        isLast: e.key == phase.milestones.length - 1,
                        phaseColor: color,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Milestone row
// ─────────────────────────────────────────────────────────────────────────────

class _MilestoneRow extends StatelessWidget {
  final _Milestone milestone;
  final bool isLast;
  final Color phaseColor;

  const _MilestoneRow({
    required this.milestone,
    required this.isLast,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = milestone.done ? AppColors.success : phaseColor.withAlpha(100);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(children: [
              const SizedBox(height: 3),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: dotColor.withAlpha(milestone.done ? 255 : 50),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 1.5),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1, margin: const EdgeInsets.only(top: 4),
                    color: AppColors.border,
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(milestone.done ? '✅' : '○',
                        style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: TextStyle(
                          color: milestone.done ? AppColors.success : Colors.white70,
                          fontSize: 12, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    milestone.commit,
                    style: GoogleFonts.getFont(
                      BrandCopy.fontAccent,
                      color: _kWhite20, fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LayerBadge extends StatelessWidget {
  final String name;
  final String description;
  final bool exists;

  const _LayerBadge({
    required this.name,
    required this.description,
    required this.exists,
  });

  @override
  Widget build(BuildContext context) {
    final color = exists ? AppColors.success : _kWhite25;
    return Tooltip(
      message: description,
      preferBelow: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          border: Border.all(color: color.withAlpha(70)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(exists ? '✓' : '○', style: TextStyle(color: color, fontSize: 10)),
            const SizedBox(width: 6),
            Text(
              'lib/$name',
              style: GoogleFonts.getFont(BrandCopy.fontAccent, color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color dot;
  final String label;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final bool mono;

  const _StatusPill({
    required this.dot,
    required this.label,
    required this.borderColor,
    required this.bgColor,
    required this.textColor,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: mono
                ? GoogleFonts.getFont(BrandCopy.fontAccent, color: textColor, fontSize: _kBadgeFontSize)
                : TextStyle(color: textColor, fontSize: _kBadgeFontSize, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  final String text;
  const _CodeLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: GoogleFonts.getFont(BrandCopy.fontAccent, color: Colors.white54, fontSize: _kCodeFontSize),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ActionChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final isSubtle = color == Colors.white24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(60)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSubtle ? _kWhite45 : color, fontSize: 12),
      ),
    );
  }
}

class _ModelBadge extends StatelessWidget {
  final String number;
  final String name;
  final Color color;
  const _ModelBadge(this.number, this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: color.withAlpha(60)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('$number · $name', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Particle field (animated background) — uses brand primary color
// ─────────────────────────────────────────────────────────────────────────────

class _ParticleField extends StatefulWidget {
  const _ParticleField();

  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(painter: _ParticlePainter(_ctrl.value)),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep Violet at 22 alpha — subtle, doesn't compete with content
    final paint = Paint()..color = AppColors.primary.withAlpha(22);
    for (int i = 0; i < 28; i++) {
      final dx = (size.width / 28) * i + sin(t * pi * 2 + i * 0.6) * 55;
      final dy = (size.height * t + i * (size.height / 28)) % size.height;
      final r  = 3.0 + sin(t * pi + i) * 2.0;
      canvas.drawCircle(Offset(dx, dy), r.abs(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}