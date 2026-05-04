// frontend/lib/core/sync/sync_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-05-04 — Paths updated: lib/spaces → lib/canon/spaces following the
//                  project structure migration. .registrations path preserved.
//   • 2026-04-27 — kArchitectRegistrationsPath updated: architect_registrations
//                  → .registrations.
//   • 2026-04-27 — Initial.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  CLI-ONLY — this file imports dart:io.
//     Do NOT import it from any Flutter widget, provider, or app code.
//
// ─────────────────────────────────────────────────────────────────────────────
// HOW TO ADD A NEW SYNC JOB
// ─────────────────────────────────────────────────────────────────────────────
//
//   1. Create a class extending SyncJob
//   2. Implement: name / watchPath / shouldRun / run
//   3. Add one line to kSyncConfig.jobs below
//   4. Done — watcher and runner pick it up automatically

// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — update paths here when the project structure changes
// ─────────────────────────────────────────────────────────────────────────────

const String kProjectRoot = '.';

// Updated: spaces folder moved from lib/spaces → lib/canon/spaces
const String kSpacesPath = 'lib/canon/spaces';

// The architect space itself
const String kArchitectSpacePath = 'lib/canon/spaces/_architect';

// Where registration stubs live (dot-prefix keeps it at top of folder tree)
const String kArchitectRegistrationsPath =
    'lib/canon/spaces/_architect/.registrations';

// The auto-registry file that gets rewritten on every sync
const String kArchitectAutoRegistryPath =
    'lib/canon/spaces/_architect/architect_model/architect_auto_registry.dart';

// Folders inside lib/canon/spaces/ that are NOT real app spaces
const Set<String> kIgnoredSpaceFolders = {'_architect'};

// Debounce — prevents rapid-fire triggers on IDE multi-file creation
const Duration kWatcherDebounce = Duration(milliseconds: 600);

// ── Visual defaults for auto-generated stubs ──────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SpaceVisualDefaults {
  final String icon;
  final String accent;
  const SpaceVisualDefaults({required this.icon, required this.accent});
}

// ─────────────────────────────────────────────────────────────────────────────
// SyncJob — base class
// ─────────────────────────────────────────────────────────────────────────────

abstract class SyncJob {
  String get name;
  String get watchPath;

  bool shouldRun(FileSystemEvent event) =>
      event.type == FileSystemEvent.create ||
      event.type == FileSystemEvent.modify;

  Future<void> run(String projectRoot);
}

// ─────────────────────────────────────────────────────────────────────────────
// SyncConfig — master registry of sync jobs
// ─────────────────────────────────────────────────────────────────────────────

class SyncConfig {
  final List<SyncJob> jobs;
  const SyncConfig({required this.jobs});
}

// ignore: non_constant_identifier_names
SyncConfig get kSyncConfig => SyncConfig(
  jobs: [
    ArchitectRegistrationSyncJob(),
    // Add future jobs here:
    // RoutesSyncJob(),
    // BarrelExportSyncJob(),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectRegistrationSyncJob
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectRegistrationSyncJob extends SyncJob {
  @override
  String get name => 'Architect Registration Sync';

  @override
  String get watchPath => kSpacesPath;

  @override
  bool shouldRun(FileSystemEvent event) =>
      event.type == FileSystemEvent.create ||
      event.type == FileSystemEvent.modify;

  @override
  Future<void> run(String projectRoot) async {
    // ── 1. Discover space_* folders ──────────────────────────────────────────
    final spacesDir = Directory('$projectRoot/$kSpacesPath');
    if (!spacesDir.existsSync()) {
      stderr.writeln(
        '  ⚠️  Spaces dir not found: $kSpacesPath\n'
        '     Make sure sync_watcher/runner is run from frontend/',
      );
      return;
    }

    final spaceFolders = spacesDir
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split(Platform.pathSeparator).last)
        .where((n) => n.startsWith('space_') && !kIgnoredSpaceFolders.contains(n))
        .toList()
      ..sort();

    // ── 2. Ensure .registrations dir exists ───────────────────────────────────
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
    final symbol = _toExportSymbol(spaceName);
    final date   = DateTime.now().toLocal().toString().substring(0, 10);
    final pascal = _toPascal(spaceName);

    // Build content as a StringBuffer to avoid any ambiguity about which
    // dollar signs are interpolation vs literal text in the output file.
    final buf = StringBuffer();
    buf.writeln(
      '// frontend/lib/canon/spaces/_architect/.registrations/${spaceName}_registration.dart',
    );
    buf.writeln('//');
    buf.writeln('// ' + '─' * 77);
    buf.writeln('// AUTO-GENERATED STUB — safe to edit');
    buf.writeln('// ' + '─' * 77);
    buf.writeln('//   Generated by lib/core/sync (ArchitectRegistrationSyncJob) on $date.');
    buf.writeln('//   This file will NOT be overwritten on future sync runs.');
    buf.writeln('//');
    buf.writeln('// HOW TO ADD A SCREEN — two imports is always enough:');
    buf.writeln('//');
    buf.writeln('//   Import 1: the shell root of the screen');
    buf.writeln('//     import \'../../${spaceName}/{name}_views/shell_{name}_root.dart\';');
    buf.writeln('//');
    buf.writeln('//   Import 2: any enums the shell constructor needs as arguments');
    buf.writeln('//     import \'../../${spaceName}/{name}_views/layout_{name}_config.dart\';');
    buf.writeln('//');
    buf.writeln('//   Then add an ArchitectScreenEntry to the screens list:');
    buf.writeln('//     ArchitectScreenEntry(');
    buf.writeln('//       id:      \'screen_${spaceName}_foo\',');
    buf.writeln('//       label:   \'Foo\',');
    buf.writeln('//       description: \'What this screen does.\',');
    buf.writeln('//       builder: () => const Shell${pascal}Root(mode: ${pascal}Mode.foo),');
    buf.writeln('//     ),');
    buf.writeln('//');
    buf.writeln('// ' + '─' * 77);
    buf.writeln();
    buf.writeln('import \'package:flutter/material.dart\';');
    buf.writeln();
    buf.writeln('import \'../architect_model/architect_screen_registry.dart\';');
    buf.writeln();
    buf.writeln('// Import 1: import \'../../${spaceName}/{views_folder}/shell_{name}_root.dart\';');
    buf.writeln('// Import 2: import \'../../${spaceName}/{views_folder}/layout_{name}_config.dart\';');
    buf.writeln();
    buf.writeln('// ' + '─' * 77);
    buf.writeln('// CONFIG');
    buf.writeln('// ' + '─' * 77);
    buf.writeln();
    buf.writeln("const _kId     = '$spaceName';");
    buf.writeln("const _kLabel  = '$spaceName';");
    buf.writeln("const _kIcon   = ${defaults.icon};");
    buf.writeln("const _kAccent = ${defaults.accent};");
    buf.writeln();
    buf.writeln('// ' + '─' * 77);
    buf.writeln('// END CONFIG BLOCK');
    buf.writeln('// ' + '─' * 77);
    buf.writeln();
    buf.writeln('final ArchitectSpace $symbol = ArchitectSpace(');
    buf.writeln('  id:      _kId,');
    buf.writeln('  label:   _kLabel,');
    buf.writeln('  icon:    _kIcon,');
    buf.writeln('  accent:  _kAccent,');
    buf.writeln('  screens: const [],   // ← add ArchitectScreenEntry items here');
    buf.writeln(');');

    file.writeAsStringSync(buf.toString());
  }

  // ── Auto-registry writer ──────────────────────────────────────────────────
  //
  // Uses StringBuffer (not string interpolation of the output content) to
  // ensure $imports and $entries are never written literally to the output file.

  void _writeAutoRegistry(File file, List<String> fileNames) {
    final date = DateTime.now().toLocal().toString().substring(0, 10);

    final buf = StringBuffer();
    buf.writeln(
      '// frontend/lib/canon/spaces/_architect/architect_model/architect_auto_registry.dart',
    );
    buf.writeln('//');
    buf.writeln('// ' + '─' * 77);
    buf.writeln('// AUTO-GENERATED — do not edit by hand');
    buf.writeln('// ' + '─' * 77);
    buf.writeln('//   Regenerated by lib/core/sync (ArchitectRegistrationSyncJob) on $date.');
    buf.writeln('// ' + '─' * 77);
    buf.writeln();
    buf.writeln("import 'architect_screen_registry.dart';");
    buf.writeln();

    for (final f in fileNames) {
      buf.writeln("import '../.registrations/$f';");
    }

    buf.writeln();
    buf.writeln('// ' + '─' * 77);
    buf.writeln('// kArchitectSpaces — assembled from all registration files');
    buf.writeln('// ' + '─' * 77);
    buf.writeln();
    buf.writeln('final List<ArchitectSpace> kArchitectSpaces = [');
    for (final f in fileNames) {
      final spaceName = f.replaceAll('.dart', '').replaceAll('_registration', '');
      buf.writeln('  ${_toExportSymbol(spaceName)},');
    }
    buf.writeln('];');

    file.writeAsStringSync(buf.toString());
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _toExportSymbol(String spaceName) =>
      'kRegister${spaceName.split('_').map(_cap).join()}';

  String _toPascal(String spaceName) =>
      spaceName.split('_').map(_cap).join();

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _log(String msg) => stdout.writeln(msg);
}