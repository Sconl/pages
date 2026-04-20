// main.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Replaced static QPagesApp shell with proper AppRoot entry point.
//             ProviderScope, auth adapter injection, and GoRouter now live in
//             lib/interface/ — main.dart is deliberately minimal.
//   v1.1.0 — Added WidgetsFlutterBinding.ensureInitialized() for async setup.
//             Added Firebase init stub (no-op unless Firebase adapter is active).
//   v1.2.0 — No changes to this file. QAdminShell now receives its config via
//             client_config.dart → app_router.dart → ShellRoute builder.
//             main.dart remains unaware of the admin config — correct separation.
// ─────────────────────────────────────────────────────────────────────────────
//
// main.dart does three things and nothing else:
//   1. Ensure Flutter binding is initialized (required before any async work)
//   2. Run any adapter-specific setup (Firebase init if using Firebase adapter)
//   3. Hand off to AppRoot
//
// Everything else — ProviderScope, BrandScope, GoRouter, QAdminShell config —
// lives in lib/interface/ and lib/core/router/.
//
// Admin config wiring:
//   kQSpaceAdminConfig (client_config.dart)
//     → app_router.dart ShellRoute builder
//     → QAdminShell(config: kQSpaceAdminConfig)
//   main.dart never imports admin config directly.

import 'package:flutter/material.dart';

import 'client/qspace/client_config.dart';
import 'interface/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Adapter-specific startup. Each adapter initializes only what it needs.
  // Add cases here as new adapters (Supabase, custom, etc.) are introduced.
  await _initAdapter();

  runApp(const AppRoot());
}

// Runs any one-time setup required by the active auth adapter.
Future<void> _initAdapter() async {
  switch (kAuthAdapterType) {
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