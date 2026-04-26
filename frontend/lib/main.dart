// frontend/lib/main.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Added _kArchitectMode flag. When true, boots ArchitectRoot
//                  instead of AppRoot — completely isolated widget tree with
//                  its own auth, providers, and routing. Flip to false before
//                  any production or staging deploy.
//   • v1.4.0 — No code changes. QPagesApp renamed to AppShell (app_shell.dart).
//               main.dart is unaffected — it only references AppRoot, not AppShell.
//   • v1.3.0 — Migrated to AppClientConfig pattern. AppRoot now takes config:.
//               _initAdapter reads adapterType from kQSpaceClientConfig instead of
//               the removed public kAuthAdapterType constant.
//               Added import for app_client_config.dart (AuthAdapterType enum).
//   • v1.1.0 — Added WidgetsFlutterBinding.ensureInitialized() for async setup.
//               Added Firebase init stub (no-op unless Firebase adapter is active).
//   • v1.0.0 — Replaced static QPagesApp shell with proper AppRoot entry point.
// ─────────────────────────────────────────────────────────────────────────────
//
// main.dart does three things and nothing else:
//   1. Check the architect mode flag → boot the right root
//   2. Ensure Flutter binding is initialized
//   3. Run adapter-specific setup (Firebase init if using Firebase adapter)

import 'package:flutter/material.dart';

import 'client/qspace/client_config.dart';
import 'core/config/app_client_config.dart';
import 'app/app_root.dart';
import 'spaces/space_architect/architect_root.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inline
// ─────────────────────────────────────────────────────────────────────────────

// ── Architect mode ─────────────────────────────────────────────────────────────
// Set to true to boot directly into the architect dev system.
// Bypasses AppRoot entirely — no normal auth, no GoRouter, no backend.
// ⚠️  MUST be false before staging or production deploy.
const bool _kArchitectMode = true;

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_kArchitectMode) {
    // Skip all adapter init — architect mode has no backend
    runApp(const ArchitectRoot());
    return;
  }

  // Normal production boot path — unchanged from before
  await _initAdapter(kQSpaceClientConfig);
  runApp(AppRoot(config: kQSpaceClientConfig));
}

Future<void> _initAdapter(AppClientConfig config) async {
  switch (config.adapterType) {
    case AuthAdapterType.firebase:
      // Uncomment when Firebase adapter is active:
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      break;
    case AuthAdapterType.restJwt:
      // No init needed — RestJwtAuthProvider sets up Dio lazily on first call.
      break;
  }
}