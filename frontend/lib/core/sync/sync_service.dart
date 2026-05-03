// frontend/lib/core/sync/sync_service.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. SyncService — iterates kSyncConfig.jobs, runs
//                  each, reports success/failure per job.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  CLI-ONLY — imports dart:io. Never import from widget or provider code.
//
// SyncService is stateless — instantiate, call runAll() or runJob(), dispose.
// Both sync_watcher.dart (continuous) and sync_runner.dart (one-shot) use this.

// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

import 'sync_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const String _kDivider = '─────────────────────────────────────────────────────';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SyncService {
  final String      projectRoot;
  final SyncConfig  config;

  const SyncService({
    required this.projectRoot,
    required this.config,
  });

  // Run every registered job in order.
  // Errors in one job do NOT stop subsequent jobs.
  Future<void> runAll() async {
    _log('\n$_kDivider');
    _log('🔄  QSpace Sync — ${config.jobs.length} job(s)');
    _log(_kDivider);

    var passed = 0;
    var failed = 0;

    for (final job in config.jobs) {
      await runJob(job);
      passed++;
    }

    _log(_kDivider);
    _log('✅  $passed passed  •  ${failed > 0 ? "❌  $failed failed" : "0 failed"}');
    _log(_kDivider);
  }

  // Run a single job by reference — used by the watcher when an event fires
  // for a specific watch path.
  Future<void> runJob(SyncJob job) async {
    _log('\n▶  ${job.name}');
    try {
      await job.run(projectRoot);
    } catch (e, stack) {
      stderr.writeln('  ❌  ${job.name} failed: $e');
      stderr.writeln('     $stack');
    }
  }

  // Find all jobs whose watchPath matches the event path and run them.
  // Called by the watcher on every debounced FileSystemEvent.
  Future<void> runJobsForEvent(FileSystemEvent event) async {
    final matchingJobs = config.jobs.where((job) {
      // Match if the event path starts with the job's watch path
      final watchAbs = '$projectRoot/${job.watchPath}';
      return event.path.startsWith(watchAbs) && job.shouldRun(event);
    }).toList();

    if (matchingJobs.isEmpty) return;

    final relativePath = event.path.replaceFirst('$projectRoot/', '');
    _log('\n📁  Change detected: $relativePath');

    for (final job in matchingJobs) {
      await runJob(job);
    }
  }

  void _log(String msg) => stdout.writeln(msg);
}