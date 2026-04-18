// lib/interface/app_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. ProviderScope + adapter injection.
//             This is the only file that knows which concrete AuthProvider
//             is in use. Everything else depends on authAdapterProvider.
// ─────────────────────────────────────────────────────────────────────────────
//
// Dependency injection lives here and nowhere else.
// Adding a new adapter = change client_config.dart + update the switch below.
// No other file needs to change.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../client/qspace/client_config.dart';
import '../experience/spaces/space_auth/state/auth_riverpod.dart';
import '../infrastructure/adapters/firebase_auth_provider.dart';
import '../infrastructure/adapters/rest_jwt_auth_provider.dart';
import 'qpages_app.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppRoot
// ─────────────────────────────────────────────────────────────────────────────

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Wire the correct adapter based on client_config.dart.
        // This is the single seam where you swap providers.
        authAdapterProvider.overrideWithValue(_buildAdapter()),
      ],
      child: const QPagesApp(),
    );
  }

  // Builds the concrete auth adapter from config.
  // If kAuthAdapterType is wrong or unsupported, this throws immediately
  // at startup — loud failure beats silent misbehavior.
  static _buildAdapter() {
    switch (kAuthAdapterType) {
      case AuthAdapterType.restJwt:
        return RestJwtAuthProvider(baseUrl: kApiBaseUrl);
      case AuthAdapterType.firebase:
        return FirebaseAuthProvider(defaultTenantId: kDefaultTenantId);
    }
  }
}