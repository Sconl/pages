// frontend/lib/main.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Import path corrected to match refactored space_architect
//                  folder structure. No logic changes.
//   • 2026-04-25 — Added _kArchitectMode flag + conditional boot.
//   • v1.3.0 — Migrated to AppClientConfig pattern.
//   • v1.1.0 — Added WidgetsFlutterBinding.ensureInitialized().
//   • v1.0.0 — Initial.
// ─────────────────────────────────────────────────────────────────────────────
//
// main.dart does three things and nothing else:
//   1. Check the architect mode flag — boot the right root
//   2. Ensure Flutter binding is initialized
//   3. Run adapter-specific setup (Firebase init if using Firebase adapter)

import 'package:flutter/material.dart';

import 'client/qspace/client_config.dart';
import 'core/config/app_client_config.dart';
import 'app/app_root.dart';
import 'spaces/_architect/architect_root.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inline
// ─────────────────────────────────────────────────────────────────────────────

// ── Architect mode ─────────────────────────────────────────────────────────────
// true  → boots ArchitectRoot (isolated dev system, no backend)
// false → boots AppRoot (normal production path)
// ⚠️  MUST be false before staging or production deploy.
const bool _kArchitectMode = true;

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_kArchitectMode) {
    // Skip all adapter init — architect mode has no backend dependency
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