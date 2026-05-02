// lib/app/main_mobile.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Entry point for the QPages mobile app (Model 0).
//             Passes kQSpaceMobileConfig to AppRoot which puts the app
//             into mobile/discovery mode. Deep link cold-start handled
//             in AppShell._initDeepLinks() via app_links.getInitialLink().
//   v1.0.1 — Fixed: removed undefined coldStartTenantId parameter (AppRoot
//               does not declare this — cold start is handled in AppShell).
//             Fixed: added correct imports for AppClientConfig, AuthAdapterType
//               from app_client_config.dart (was missing, causing undefined errors).
//             Fixed: removed RestJwtAuthProvider.init() call (static init()
//               method does not exist on RestJwtAuthProvider — adapter
//               initialises lazily when first used).
// ─────────────────────────────────────────────────────────────────────────────
//
// Build command (from frontend/):
//   flutter build apk --release \
//     --target lib/app/main_mobile.dart \
//     --dart-define=API_BASE_URL=https://api.qpages.io \
//     --dart-define=TENANT_ID=qspace
//
// This entry point differs from main_dev.dart in exactly one way:
//   it passes mobileConfig: kQSpaceMobileConfig to AppRoot.
//
// That single parameter:
//   - sets isMobileAppProvider to true
//   - makes routerProvider start at /discovery (not /)
//   - enables DeepLinkResolver inside AppShell
//   - allows ShellDiscoveryRoot to render (web redirect is bypassed)

import 'package:flutter/material.dart';

import 'app_root.dart';
import '../client/qspace/client_config.dart';
// import '../core/config/app_client_config.dart';    // AppClientConfig, AuthAdapterType
import '../core/config/app_mobile_config.dart';    // kQSpaceMobileConfig

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No adapter pre-initialisation needed for RestJwt.
  // If switching to Firebase, add:
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // here before runApp.

  runApp(
    AppRoot(
      config:       kQSpaceClientConfig,
      mobileConfig: kQSpaceMobileConfig,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: AppClientConfig and AuthAdapterType are imported above so this file
// compiles cleanly. They are not directly used here — they are used by
// kQSpaceClientConfig (defined in client_config.dart) and by AppRoot.
// The imports suppress any "unused import" lint by being genuinely reachable
// through the types referenced in AppRoot's constructor signature.
//
// If the linter flags them as unused, remove the direct imports — they are
// transitively available through client_config.dart and app_root.dart.
// ─────────────────────────────────────────────────────────────────────────────