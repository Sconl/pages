// lib/experience/spaces/space_value/views/view_engine_status.dart
//
// ViewEngineStatus — first concrete QPStructure implementation.
//
// section_core    → QSpace Pages identity, architecture layers, branch status
// section_context → Project roadmap: phases, milestones, live countdown
// section_connect → Active step, commit target, next action
//
// TEMPORARY: Replace once QPagesApp and infrastructure layer are complete.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../qp_structure.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAccent  = Color(0xFF6366F1);
const _kCyan    = Color(0xFF22D3EE);
const _kSuccess = Color(0xFF4ADE80);
const _kWarning = Color(0xFFFBBF24);
const _kBg      = Color(0xFF050714);
const _kCard    = Color(0xFF0D0F1E);
const _kBorder  = Color(0xFF1E2035);

// Colors.white20/25/45 do not exist in Flutter — using const hex equivalents:
//   white20 → 0x33FFFFFF (≈ 20 % opacity)
//   white25 → 0x40FFFFFF (≈ 25 % opacity)
//   white45 → 0x73FFFFFF (≈ 45 % opacity)
const _kWhite20 = Color(0x33FFFFFF);
const _kWhite25 = Color(0x40FFFFFF);
const _kWhite45 = Color(0x73FFFFFF);

final _projectStart = DateTime(2026, 2, 23);
final _mvpTarget    = DateTime(2026, 5, 15);

const _kBranch     = 'refactor/architecture-packaging';
const _kNextCommit =
    'refactor(experience): adapt first view to QPStructure contract — sanity check';
const _kNextStep   =
    'Step 2 — view_engine_status.dart implementing QPStructure';

// ─────────────────────────────────────────────────────────────────────────────
// Architecture layers
// ─────────────────────────────────────────────────────────────────────────────

const _kLayers = [
  ('canon/',          'Structural law — immutable contracts',  true),
  ('suite/',          'Nine template suites',                  true),
  ('client/',         'Client overlays + branding',           true),
  ('experience/',     'Spaces, structures, views',            true),
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
        _Status.done    => _kSuccess,
        _Status.active  => _kAccent,
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
        'contract defined, first concrete view created, merge engine '
        'implemented, package skeleton built.',
    startDate: DateTime(2026, 2, 23),
    endDate:   DateTime(2026, 3, 7),
    milestones: const [
      _Milestone(
        'Flutter project initialized',
        'chore(init): scaffold Flutter project qspace_pages',
        done: true,
      ),
      _Milestone(
        'lib/ layers created (canon, suite, client, shell)',
        'chore(scaffold): create initial lib/ layer folders',
        done: true,
      ),
      _Milestone(
        'lib/interface/ created — renamed from lib/ui/',
        'refactor(interface): rename ui/ → interface/',
        done: true,
      ),
      _Milestone(
        'experience/spaces/ containers created',
        'feat(experience): create space containers',
        done: true,
      ),
      _Milestone(
        'QPStructure contract defined (buildSectionCore/Context/Connect)',
        'refactor(experience): rename QPView → QPStructure, section_connect API',
        done: true,
      ),
      _Milestone(
        'view_engine_status — first QPStructure view',
        'refactor(experience): adapt first view to QPStructure contract',
      ),
      _Milestone(
        'lib/shell/merge_engine.dart — viewRegistry + resolution',
        'feat(shell): implement merge_engine view resolution and viewRegistry',
      ),
      _Milestone(
        'packages/qspace_pages/ — importable Flutter package',
        'feat(package): convert engine to importable Flutter package',
      ),
    ],
  ),
  _Phase(
    label: 'Pre-Cycle 0 · Week 2',
    title: 'Backend Scaffold + Landing Page',
    description:
        'Rust backend initialized (Axum + SeaORM + PostgreSQL). '
        'Public landing page live with waitlist.',
    startDate: DateTime(2026, 3, 8),
    endDate:   DateTime(2026, 3, 14),
    milestones: const [
      _Milestone(
        'Rust backend scaffolded (Axum + SeaORM)',
        'chore(backend): scaffold Rust backend project',
      ),
      _Milestone(
        'PostgreSQL — users + tenants migrations',
        'feat(db): initial schema migrations',
      ),
      _Milestone(
        'GET /health endpoint live',
        'feat(backend): health check endpoint',
      ),
      _Milestone(
        'Public landing page deployed with waitlist',
        'feat(web): deploy public landing page',
      ),
    ],
  ),
  _Phase(
    label: 'Pre-Cycle 0 · Weeks 3-4',
    title: 'Core APIs + Interface Shell',
    description:
        'Tenant management, JWT auth, content CRUD (space_id + '
        'structure_id), media upload. Flutter AppShell with 3-space '
        'Canon navigation.',
    startDate: DateTime(2026, 3, 15),
    endDate:   DateTime(2026, 3, 28),
    milestones: const [
      _Milestone(
        'Tenant API (POST/GET /api/tenants)',
        'feat(backend): tenant management API',
      ),
      _Milestone(
        'JWT auth — register, login, middleware',
        'feat(backend): JWT auth endpoints',
      ),
      _Milestone(
        'Content CRUD with space_id + structure_id',
        'feat(backend): content CRUD with canonical mapping',
      ),
      _Milestone(
        'Media upload (POST /api/media)',
        'feat(backend): media upload endpoint',
      ),
      _Milestone(
        'AppShell + QNavBar (Canon 3-space rule)',
        'feat(interface): app shell with canonical navigation',
      ),
      _Milestone(
        'Pre-Cycle 0 complete — 10+ waitlist signups',
        'chore: Pre-Cycle 0 complete',
      ),
    ],
  ),
  _Phase(
    label: 'Cycle 1 · Weeks 5-8',
    title: 'Core MVP — Beacon: Brochure',
    description:
        'Q-prefix component library, Corporate suite QPStructure '
        'views, manifest integration, first site deployed on DigitalOcean.',
    startDate: DateTime(2026, 3, 29),
    endDate:   DateTime(2026, 4, 25),
    milestones: const [
      _Milestone(
        'Design tokens — lib/canon/canon_tokens.dart',
        'feat(canon): design token definitions',
      ),
      _Milestone(
        'Component library (QButton, QCard, QSection, QGrid)',
        'feat(interface): Q-prefixed component library',
      ),
      _Milestone(
        'Corporate suite views (view_home, view_services, view_about)',
        'feat(spaces): corporate suite space_value views',
      ),
      _Milestone(
        'AppShell wired to effectiveManifest',
        'feat(interface): wire AppShell to manifest',
      ),
      _Milestone(
        'ThemeEngine — manifest tokens → Material 3 theme',
        'feat(interface): ThemeEngine from manifest tokens',
      ),
      _Milestone(
        'Beacon: Brochure — first template shipped 🎯',
        'feat(suite): Beacon Brochure corporate suite complete',
      ),
    ],
  ),
  _Phase(
    label: 'Cycle 2 · Weeks 9-12',
    title: 'First Pilot Customers',
    description:
        '2-3 paying customers. Sites delivered within 48 hours. '
        'First testimonial. KES 10K+ MRR.',
    startDate: DateTime(2026, 4, 26),
    endDate:   DateTime(2026, 5, 23),
    milestones: const [
      _Milestone(
        '10+ outreach demos completed',
        'chore(sales): outreach phase',
      ),
      _Milestone(
        'Pilot customer 1 — site live',
        'feat(pilot): provision pilot customer 1',
      ),
      _Milestone(
        'Pilot customer 2 — site live',
        'feat(pilot): provision pilot customer 2',
      ),
      _Milestone(
        'First testimonial — KES 10K+ MRR',
        'chore: Cycle 2 complete',
      ),
    ],
  ),
  _Phase(
    label: 'Cycle 3 · Weeks 13-16',
    title: 'Productization Begins',
    description:
        '5+ customers, < 30 min provisioning, 2nd template suite shipped.',
    startDate: DateTime(2026, 5, 24),
    endDate:   DateTime(2026, 6, 20),
    milestones: const [
      _Milestone(
        'Semi-automated provisioning (< 30 min)',
        'feat(backend): automated tenant provisioning',
      ),
      _Milestone(
        '2nd template suite shipped',
        'feat(suite): second template suite',
      ),
      _Milestone(
        '5+ customers — < 10% churn',
        'chore: Cycle 3 complete',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// ViewEngineStatus — QPStructure implementation
// ─────────────────────────────────────────────────────────────────────────────

class ViewEngineStatus extends QPStructure {
  const ViewEngineStatus({super.key});

  // Overrides build to add Scaffold + animated background.
  // All three canonical section builders are called — contract is honoured.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          const Positioned.fill(child: _ParticleField()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionCore(context),
                      const SizedBox(height: 52),
                      buildSectionContext(context),
                      const SizedBox(height: 52),
                      buildSectionConnect(context),
                      const SizedBox(height: 40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'QSpace ',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.5,
              ),
            ),
            TextSpan(
              text: 'Pages',
              style: GoogleFonts.inter(
                color: _kAccent,
                fontSize: 52,
                fontWeight: FontWeight.w300,
                letterSpacing: -1.5,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text(
          'Canonical UI Engine  ·  Architecture Engine  ·  Structural Operating System',
          style: TextStyle(
            color: Colors.white30,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 28),

        // Branch + phase badge row
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatusPill(
              dot: _kAccent,
              label: _kBranch,
              mono: true,
              borderColor: _kAccent.withAlpha(80),
              bgColor: _kAccent.withAlpha(18),
              textColor: _kAccent,
            ),
            _StatusPill(
              dot: _kWarning,
              label: 'Pre-Cycle 0 · Week 1',
              borderColor: _kWarning.withAlpha(70),
              bgColor: _kWarning.withAlpha(15),
              textColor: _kWarning,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Architecture layers
        Text(
          'ARCHITECTURE LAYERS',
          style: TextStyle(
            color: _kWhite25,
            fontSize: 10,
            letterSpacing: 1.8,
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

        // One-liner description
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: _kCard,
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
                fontSize: 10,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const _CountdownBadge(),
          ],
        ),
        const SizedBox(height: 14),
        const _OverallProgressBar(),
        const SizedBox(height: 20),
        // Phase cards — horizontal scroll
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _phases.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _PhaseCard(phase: _phases[i]),
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEXT ACTION',
          style: TextStyle(
            color: _kWhite25,
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        // Active step card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kCard,
            border: Border.all(color: _kAccent.withAlpha(60)),
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
                children: const [
                  _ActionChip('Then: migrate view_home.dart', _kAccent),
                  _ActionChip('Then: implement merge_engine', Colors.white24),
                  _ActionChip('Then: package skeleton', Colors.white24),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Distribution model badges
        Text(
          'DISTRIBUTION MODELS',
          style: TextStyle(
            color: _kWhite25,
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ModelBadge('Model 1', 'SaaS Hosted', _kAccent),
            _ModelBadge('Model 2', 'Enterprise Self-Host', _kCyan),
            _ModelBadge('Model 3', 'Developer Package', _kSuccess),
          ],
        ),
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
        style: TextStyle(color: _kSuccess, fontSize: 12, fontWeight: FontWeight.w600),
      );
    }
    final days  = diff.inDays;
    final hours = diff.inHours % 24;
    final mins  = diff.inMinutes % 60;
    final secs  = diff.inSeconds % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kCard,
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('MVP: ', style: TextStyle(color: Colors.white30, fontSize: 11)),
          Text(
            '${days}d ${hours}h ${mins}m ${secs}s',
            style: GoogleFonts.sourceCodePro(
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
    final elapsed =
        now.difference(_projectStart).inSeconds.clamp(0, total);
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
                color: _kAccent,
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
              height: 4,
              width: w,
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
                gradient: const LinearGradient(
                  colors: [_kAccent, _kCyan],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: _kAccent.withAlpha(80), blurRadius: 6),
                ],
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
          width: 196,
          padding: const EdgeInsets.all(14),
          transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: _kCard,
            border: Border.all(
              color: _hovered ? color : _kBorder,
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
              Text(
                widget.phase.label,
                style: TextStyle(color: Colors.white30, fontSize: 9, letterSpacing: 0.6),
              ),
              const SizedBox(height: 5),
              Text(
                widget.phase.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text(widget.phase.emoji(now), style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 5),
                Text(
                  widget.phase.statusLabel(now),
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ]),
              const Spacer(),
              // Milestone progress bar
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
                  Text(
                    '$done/$total milestones',
                    style: TextStyle(color: _kWhite25, fontSize: 10),
                  ),
                  if (_hovered)
                    Text(
                      'details →',
                      style: TextStyle(
                        color: color.withAlpha(180),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
                  border: Border(bottom: BorderSide(color: _kBorder)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.label,
                            style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 0.6),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phase.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                              child: Text(
                                phase.statusLabel(now),
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          Text(
                            phase.description,
                            style: const TextStyle(color: _kWhite45, fontSize: 12, height: 1.55),
                          ),
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
                      Text(
                        'MILESTONES',
                        style: TextStyle(
                          color: _kWhite25,
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...phase.milestones.asMap().entries.map((e) {
                        return _MilestoneRow(
                          milestone: e.value,
                          isLast: e.key == phase.milestones.length - 1,
                          phaseColor: color,
                        );
                      }),
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
    final dotColor = milestone.done ? _kSuccess : phaseColor.withAlpha(100);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(children: [
              const SizedBox(height: 3),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor.withAlpha(milestone.done ? 255 : 50),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 1.5),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.only(top: 4),
                    color: _kBorder,
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
                    Text(milestone.done ? '✅' : '○', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: TextStyle(
                          color: milestone.done ? _kSuccess : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    milestone.commit,
                    style: GoogleFonts.sourceCodePro(color: _kWhite20, fontSize: 10),
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
    final color = exists ? _kSuccess : _kWhite25;
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
            Text(
              exists ? '✓' : '○',
              style: TextStyle(color: color, fontSize: 10),
            ),
            const SizedBox(width: 6),
            Text(
              'lib/$name',
              style: GoogleFonts.sourceCodePro(color: color, fontSize: 11),
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
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: mono
                ? GoogleFonts.sourceCodePro(color: textColor, fontSize: 11)
                : TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
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
        style: GoogleFonts.sourceCodePro(color: Colors.white54, fontSize: 11),
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
        style: TextStyle(
          color: isSubtle ? _kWhite45 : color,
          fontSize: 12,
        ),
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
        color: _kCard,
        border: Border.all(color: color.withAlpha(60)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$number · $name',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle field (animated background)
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
    final paint = Paint()..color = const Color(0xFF6366F1).withAlpha(22);
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