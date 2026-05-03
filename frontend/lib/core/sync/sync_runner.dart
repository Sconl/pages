// frontend/lib/core/sync/sync_runner.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Initial. One-shot sync runner — runs all jobs and exits.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  CLI-ONLY — imports dart:io. Never import from widget code.
//
// USAGE:
//   cd frontend
//   dart run lib/core/sync/sync_runner.dart
//
// Use this for:
//   • CI/CD pipeline (runs sync before flutter build)
//   • Manual one-off refresh after pulling changes
//   • VS Code "run task" when you don't want the watcher running continuously
//
// For continuous watching during development, use sync_watcher.dart instead.

// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

import 'sync_config.dart';
import 'sync_service.dart';

void main() async {
  final projectRoot = Directory.current.path;
  final service     = SyncService(
    projectRoot: projectRoot,
    config:      kSyncConfig,
  );

  await service.runAll();

  // Exit 0 on success — CI scripts can check this
  exit(0);
}