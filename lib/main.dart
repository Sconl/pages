// main.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Replaced static QPagesApp shell with proper AppRoot entry point.
//   v1.1.0 — Added WidgetsFlutterBinding.ensureInitialized() for async setup.
//             Added Firebase init stub (no-op unless Firebase adapter is active).
//   v1.2.0 — No changes to this file. QAdminShell config wired via client_config
//             → app_router → ShellRoute. main.dart remains unaware of admin config.
//   v1.3.0 — Migrated to AppClientConfig pattern. AppRoot now takes config:.
//             _initAdapter reads adapterType from kQSpaceClientConfig instead of
//             the removed public kAuthAdapterType constant.
//             Added import for app_client_config.dart (AuthAdapterType enum).
// ─────────────────────────────────────────────────────────────────────────────
//
// main.dart does three things and nothing else:
//   1. Ensure Flutter binding is initialized
//   2. Run adapter-specific setup (Firebase init if using Firebase adapter)
//   3. Hand off to AppRoot with the master config

import 'package:flutter/material.dart';

import 'client/qspace/client_config.dart';
import 'core/config/app_client_config.dart';
import 'interface/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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