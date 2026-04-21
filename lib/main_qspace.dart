// main_qspace.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QSpace-specific entry point.
//   v1.1.0 — Migrated to AppClientConfig pattern. Replaced flat authConfig +
//             routerConfig params with config: kQSpaceClientConfig.
//             _initAdapter reads adapterType from config — kAuthAdapterType
//             and AuthAdapterType are no longer public constants in client_config.
//             Added import for app_client_config.dart (AuthAdapterType enum).
// ─────────────────────────────────────────────────────────────────────────────
//
// Explicit QSpace production entry point.
// main.dart is the universal entry — this file exists for clarity and to allow
// per-entry --dart-define overrides at build time.
//
// To run:
//   flutter run -t main_qspace.dart
//   flutter build web -t main_qspace.dart --dart-define=API_BASE_URL=https://api.qspace.co

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
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      break;
    case AuthAdapterType.restJwt:
      // No init needed — RestJwtAuthProvider sets up Dio lazily.
      break;
  }
}