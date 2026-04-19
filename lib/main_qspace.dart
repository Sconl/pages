// main_qspace.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QSpace-specific entry point.
//             Passes kQSpaceAuthConfig and kQSpaceRouterConfig to AppRoot.
//             main.dart stays as the universal entry that uses AppRoot defaults.
// ─────────────────────────────────────────────────────────────────────────────
//
// Entry point pattern — why multiple main_*.dart files:
//
//   main.dart           → universal entry, uses AppRoot's default params (QSpace defaults)
//   main_qspace.dart    → explicit QSpace production entry — same config, more explicit
//   main_dev.dart       → development: kAuthConfigDeveloper + initial route /admin
//   main_acme.dart      → Acme Corp client: their own client_config + auth config
//
// To run a specific entry:
//   flutter run -t main_qspace.dart
//   flutter build web -t main_qspace.dart --dart-define=API_BASE_URL=https://api.qspace.co
//
// Each entry is a thin wrapper — all logic lives in AppRoot, client_config, and auth_config.

import 'package:flutter/material.dart';

import 'client/qspace/client_config.dart';
import 'interface/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initAdapter();
  runApp(const AppRoot(
    authConfig:   kQSpaceAuthConfig,
    routerConfig: kQSpaceRouterConfig,
  ));
}

Future<void> _initAdapter() async {
  switch (kAuthAdapterType) {
    case AuthAdapterType.firebase:
      // Uncomment when Firebase adapter is active:
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      break;
    case AuthAdapterType.restJwt:
      // No init needed — RestJwtAuthProvider sets up Dio lazily.
      break;
  }
}