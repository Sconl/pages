// frontend/lib/core/sync/sync_watcher.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. Continuous file system watcher. Monitors all
//                  watchPaths from kSyncConfig, debounces rapid events,
//                  triggers the correct SyncJob(s) automatically.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  CLI-ONLY — imports dart:io and dart:async. Never import from widget code.
//
// USAGE — run once from a terminal, keep it alive while developing:
//   cd frontend
//   dart run lib/core/sync/sync_watcher.dart
//
// VS CODE TASK (add to .vscode/tasks.json):
//   {
//     "label": "QSpace Sync Watcher",
//     "type": "shell",
//     "command": "dart run lib/core/sync/sync_watcher.dart",
//     "isBackground": true,
//     "runOptions": { "runOn": "folderOpen" }
//   }
//
// "runOn": "folderOpen" launches it automatically every time VS Code opens the
// workspace — zero manual steps. Add it to your default task group to have it
// start silently in the background.
//
// ─────────────────────────────────────────────────────────────────────────────
// WHY NOT RIVERPOD?
// ─────────────────────────────────────────────────────────────────────────────
//   Riverpod manages in-app runtime state — providers, widget rebuilds, async
//   data. This is a build-time / development-time concern: watching the file
//   system and generating source code. These are orthogonal concerns.
//
//   dart:io's Directory.watch() is exactly the right primitive:
//     • Lives outside the Flutter app process
//     • Has no widget tree dependency
//     • Stays alive for as long as the terminal process runs
//     • Can be started/stopped independently of hot reload
//
//   If you later want the architect dashboard to show "last sync time" inside
//   the running app, add a Riverpod provider that reads a tiny JSON status
//   file written by this watcher. That keeps the concerns cleanly separated.

// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

import 'sync_config.dart';
import 'sync_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const String _kBanner = '''
╔════════════════════════════════════════════════════╗
║          QSpace Sync Watcher — running             ║
║  Ctrl+C to stop  •  dart run lib/core/sync/        ║
╚════════════════════════════════════════════════════╝''';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  final projectRoot = Directory.current.path;
  final service     = SyncService(
    projectRoot: projectRoot,
    config:      kSyncConfig,
  );

  stdout.writeln(_kBanner);
  stdout.writeln('📂  Watching from: $projectRoot\n');

  // ── Run all jobs once on startup ──────────────────────────────────────────
  // This catches any changes made while the watcher wasn't running (e.g.
  // spaces added while VS Code was closed).
  await service.runAll();

  // ── Set up file system watchers for each unique watch path ────────────────
  // Multiple jobs may share the same watchPath — we deduplicate the watchers
  // and let the service figure out which jobs to run per event.
  final watchPaths = kSyncConfig.jobs
      .map((j) => j.watchPath)
      .toSet();

  final subscriptions = <StreamSubscription<FileSystemEvent>>[];

  for (final watchPath in watchPaths) {
    final dir = Directory('$projectRoot/$watchPath');
    if (!dir.existsSync()) {
      stderr.writeln('⚠️   Watch path not found: $watchPath — skipping');
      continue;
    }

    stdout.writeln('👁   Watching: $watchPath');

    // debounce — collect events for kWatcherDebounce, then flush
    Timer? debounceTimer;
    FileSystemEvent? lastEvent;

    final sub = dir.watch(recursive: true).listen((event) {
      lastEvent = event;
      debounceTimer?.cancel();
      debounceTimer = Timer(kWatcherDebounce, () async {
        if (lastEvent != null) {
          await service.runJobsForEvent(lastEvent!);
          lastEvent = null;
        }
      });
    });

    subscriptions.add(sub);
  }

  stdout.writeln('\n✅  Watcher ready. Waiting for changes...\n');

  // ── Keep process alive ────────────────────────────────────────────────────
  // The subscriptions keep the event loop running. On Ctrl+C, cancel cleanly.
  ProcessSignal.sigint.watch().listen((_) async {
    stdout.writeln('\n\n🛑  Watcher stopped.\n');
    for (final sub in subscriptions) {
      await sub.cancel();
    }
    exit(0);
  });
}