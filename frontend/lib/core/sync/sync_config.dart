// frontend/lib/core/sync/sync_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. ProjectStructure manifest + SyncJob base class.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  CLI-ONLY — this file imports dart:io.
//     Do NOT import it from any Flutter widget, provider, or app code.
//     It is used exclusively by sync_service.dart, sync_watcher.dart, and
//     sync_runner.dart — all of which run as standalone Dart CLI scripts.
//
// ─────────────────────────────────────────────────────────────────────────────
// HOW TO ADD A NEW SYNC JOB
// ─────────────────────────────────────────────────────────────────────────────
//
//   1. Create a new class extending SyncJob in its own file
//      (e.g. lib/core/sync/jobs/route_sync_job.dart)
//
//   2. Implement:
//        String get name          → human-readable label for logs
//        String get watchPath     → path (relative to project root) to watch
//        bool   shouldRun(event)  → filter which FileSystemEvents trigger this job
//        Future<void> run()       → what to do when triggered
//
//   3. Register it in kSyncConfig.jobs below
//
//   4. Done — the watcher and runner both pick it up automatically
//
// Examples of future sync jobs:
//   - RoutesSyncJob        → auto-updates app_router.dart when screen files are added
//   - BarrelSyncJob        → regenerates barrel export files for any package
//   - AdminRegistrySyncJob → mirrors architect_sync for the admin portal registry
//   - LocaleSyncJob        → keeps .arb files in sync with a master key list

// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — update paths here if the project structure changes
// ─────────────────────────────────────────────────────────────────────────────

// Root of the Flutter project — all paths below are relative to this.
// sync_watcher.dart and sync_runner.dart must be run from this directory.
const String kProjectRoot = '.';

// Path to the spaces folder — what the architect sync watches
const String kSpacesPath = 'lib/spaces';

// The architect space itself — excluded from space scanning
const String kArchitectSpacePath = 'lib/spaces/_architect';

// Where registration stubs are generated
const String kArchitectRegistrationsPath =
    'lib/spaces/_architect/architect_registrations';

// The auto-registry file that gets rewritten on every sync
const String kArchitectAutoRegistryPath =
    'lib/spaces/_architect/architect_model/architect_auto_registry.dart';

// ── Icon + accent defaults for new spaces ─────────────────────────────────────
// Add entries here to give a new space its correct visual identity in the
// architect dashboard before its registration file is manually customised.
const Map<String, SpaceVisualDefaults> kSpaceVisualDefaults = {
  'space_auth':      SpaceVisualDefaults(icon: 'Icons.lock_outline_rounded',           accent: 'Color(0xFF9933FF)'),
  'space_value':     SpaceVisualDefaults(icon: 'Icons.home_outlined',                  accent: 'Color(0xFF0F91D2)'),
  'space_admin':     SpaceVisualDefaults(icon: 'Icons.admin_panel_settings_outlined',   accent: 'Color(0xFFFAAF2E)'),
  'space_site':      SpaceVisualDefaults(icon: 'Icons.language_outlined',              accent: 'Color(0xFF00E676)'),
  'space_dev':       SpaceVisualDefaults(icon: 'Icons.code_outlined',                  accent: 'Color(0xFF40C4FF)'),
  'space_billing':   SpaceVisualDefaults(icon: 'Icons.credit_card_outlined',           accent: 'Color(0xFFFF5252)'),
  'space_profile':   SpaceVisualDefaults(icon: 'Icons.person_outline_rounded',         accent: 'Color(0xFFFFB300)'),
  'space_discovery': SpaceVisualDefaults(icon: 'Icons.explore_outlined',               accent: 'Color(0xFF00BCD4)'),
};

const String kDefaultIcon   = 'Icons.widgets_outlined';
const String kDefaultAccent = 'Color(0xFF9933FF)';

// Folders inside lib/spaces/ that are NOT real app spaces
const Set<String> kIgnoredSpaceFolders = {'_architect'};

// ── Watcher debounce ──────────────────────────────────────────────────────────
// How long to wait after the last file system event before running sync.
// Prevents rapid-fire triggers when an IDE creates multiple files at once.
const Duration kWatcherDebounce = Duration(milliseconds: 600);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// SpaceVisualDefaults — icon + accent for stub generation
// ─────────────────────────────────────────────────────────────────────────────

class SpaceVisualDefaults {
  final String icon;
  final String accent;
  const SpaceVisualDefaults({required this.icon, required this.accent});
}


// ─────────────────────────────────────────────────────────────────────────────
// SyncJob — base class for all sync jobs
// ─────────────────────────────────────────────────────────────────────────────
//
// Each job is self-contained: it knows what to watch, when to fire, and what
// to generate. The watcher and runner call these without knowing the details.

abstract class SyncJob {
  // Human-readable name shown in log output
  String get name;

  // Path to watch (relative to project root). The watcher registers a
  // FileSystemEvent stream on this path.
  String get watchPath;

  // Whether this FileSystemEvent should trigger a run().
  // Default: trigger on directory creation events only.
  // Override to respond to file creation, modification, deletion, etc.
  bool shouldRun(FileSystemEvent event) {
    return event.type == FileSystemEvent.create ||
           event.type == FileSystemEvent.modify;
  }

  // Execute the sync logic. Must be idempotent — safe to call multiple times.
  Future<void> run(String projectRoot);
}


// ─────────────────────────────────────────────────────────────────────────────
// SyncConfig — the master list of registered sync jobs
// ─────────────────────────────────────────────────────────────────────────────
//
// kSyncConfig is the single registry. Add jobs here. The watcher and runner
// both iterate this list — they don't know about individual jobs.

class SyncConfig {
  final List<SyncJob> jobs;
  const SyncConfig({required this.jobs});
}

// The master registry — imported by sync_watcher.dart and sync_runner.dart
// ignore: non_constant_identifier_names
SyncConfig get kSyncConfig {
  // Import here to avoid circular deps — jobs are in separate files
  // and only instantiated when the config is first accessed.
  return SyncConfig(
    jobs: [
      ArchitectRegistrationSyncJob(),
      // Add future sync jobs here:
      // RoutesSyncJob(),
      // BarrelExportSyncJob(),
    ],
  );
}


// ─────────────────────────────────────────────────────────────────────────────
// ArchitectRegistrationSyncJob — the original architect_sync logic
// ─────────────────────────────────────────────────────────────────────────────
//
// Watches lib/spaces/ for new space_* folders and keeps the architect
// registration system in sync. This replaces tools/architect_sync.dart.

class ArchitectRegistrationSyncJob extends SyncJob {
  @override
  String get name => 'Architect Registration Sync';

  @override
  String get watchPath => kSpacesPath;

  @override
  bool shouldRun(FileSystemEvent event) {
    // Trigger on directory creation (new space) or modification (file change
    // inside a space). Ignore deletions for now — stub files are harmless.
    return event.type == FileSystemEvent.create ||
           event.type == FileSystemEvent.modify;
  }

  @override
  Future<void> run(String projectRoot) async {
    // ── 1. Discover space_* folders ──────────────────────────────────────────
    final spacesDir = Directory('$projectRoot/$kSpacesPath');
    if (!spacesDir.existsSync()) return;

    final spaceFolders = spacesDir
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split(Platform.pathSeparator).last)
        .where((n) => n.startsWith('space_') && !kIgnoredSpaceFolders.contains(n))
        .toList()
      ..sort();

    // ── 2. Ensure registrations dir exists ────────────────────────────────────
    final regDir = Directory('$projectRoot/$kArchitectRegistrationsPath');
    if (!regDir.existsSync()) regDir.createSync(recursive: true);

    // ── 3. Create stub for any space without a registration file ─────────────
    for (final spaceName in spaceFolders) {
      final regFile = File(
        '$projectRoot/$kArchitectRegistrationsPath/${spaceName}_registration.dart',
      );
      if (!regFile.existsSync()) {
        _writeStub(regFile, spaceName);
        _log('  ✨  Created stub: ${spaceName}_registration.dart');
      }
    }

    // ── 4. Assemble auto_registry from ALL registration files ─────────────────
    final allRegFiles = regDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('_registration.dart'))
        .map((f) => f.path.split(Platform.pathSeparator).last)
        .toList()
      ..sort();

    final autoFile = File('$projectRoot/$kArchitectAutoRegistryPath');
    _writeAutoRegistry(autoFile, allRegFiles);
    _log('  ✅  Rewrote: $kArchitectAutoRegistryPath');
  }

  // ── Stub generator ───────────────────────────────────────────────────────────

  void _writeStub(File file, String spaceName) {
    final defaults = kSpaceVisualDefaults[spaceName] ??
        SpaceVisualDefaults(icon: kDefaultIcon, accent: kDefaultAccent);
    final symbol   = _toExportSymbol(spaceName);
    final date     = DateTime.now().toLocal().toString().substring(0, 10);

    file.writeAsStringSync('''// frontend/lib/spaces/_architect/architect_registrations/${spaceName}_registration.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// AUTO-GENERATED STUB — safe to edit
// ─────────────────────────────────────────────────────────────────────────────
//   Generated by lib/core/sync (ArchitectRegistrationSyncJob) on $date.
//   This file will NOT be overwritten on future sync runs.
//   Add screen imports + ArchitectScreenEntry items to the screens list below.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO ADD A SCREEN:
//   1. Import the screen widget at the top of this file
//   2. Add an ArchitectScreenEntry to the screens list
//   3. Save — sync_watcher.dart updates architect_auto_registry.dart automatically

import 'package:flutter/material.dart';

import '../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — update icon + accent to match the space visual identity
// ─────────────────────────────────────────────────────────────────────────────

const _kId     = '$spaceName';
const _kLabel  = '$spaceName';
const _kIcon   = ${defaults.icon};
const _kAccent = ${defaults.accent};

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

final ArchitectSpace $symbol = ArchitectSpace(
  id:      _kId,
  label:   _kLabel,
  icon:    _kIcon,
  accent:  _kAccent,
  screens: const [],   // ← import screen widgets above and add entries here
);
''');
  }

  // ── Auto-registry writer ──────────────────────────────────────────────────

  void _writeAutoRegistry(File file, List<String> fileNames) {
    final date     = DateTime.now().toLocal().toString().substring(0, 10);
    final imports  = fileNames.map((f) =>
        "import '../architect_registrations/$f';").join('\n');
    final entries  = fileNames.map((f) {
      final spaceName = f.replaceAll('.dart', '').replaceAll('_registration', '');
      return '  ${_toExportSymbol(spaceName)},';
    }).join('\n');

    file.writeAsStringSync('''// frontend/lib/spaces/_architect/architect_model/architect_auto_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// AUTO-GENERATED — do not edit by hand
// ─────────────────────────────────────────────────────────────────────────────
//   Regenerated by lib/core/sync (ArchitectRegistrationSyncJob) on $date.
// ─────────────────────────────────────────────────────────────────────────────

import 'architect_screen_registry.dart';

$imports

// ─────────────────────────────────────────────────────────────────────────────
// kArchitectSpaces — assembled from all registration files
// ─────────────────────────────────────────────────────────────────────────────

final List<ArchitectSpace> kArchitectSpaces = [
$entries
];
''');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  // space_auth → kRegisterSpaceAuth
  String _toExportSymbol(String spaceName) {
    final pascal = spaceName.split('_').map(_cap).join();
    return 'kRegister$pascal';
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _log(String msg) => stdout.writeln(msg);
}