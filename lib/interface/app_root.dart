// lib/interface/app_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. ProviderScope + adapter injection.
//   v1.1.0 — Added typed authConfig and routerConfig params with defaults.
//             Each main_*.dart passes its own config. ProviderScope now also
//             overrides authConfigProvider and routerConfigProvider.
//             This is the ONLY file that knows which concrete adapter is in use.
// ─────────────────────────────────────────────────────────────────────────────
//
// Dependency injection lives here and nowhere else.
//
// Adding a new adapter: change client_config.dart + add a case to _buildAdapter().
// No other file needs to change.
//
// Adding a new client/tenant: create a new main_*.dart that passes different
// authConfig and routerConfig. No other file needs to change.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../client/qspace/client_config.dart';
import '../core/auth/auth_config.dart';
import '../core/router/router_config.dart';
import '../spaces/space_auth/state/auth_riverpod.dart';
import '../core/auth/auth_adapters/firebase_auth_provider.dart';
import '../core/auth/auth_adapters/rest_jwt_auth_provider.dart';
import 'qpages_app.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppRoot
// ─────────────────────────────────────────────────────────────────────────────

class AppRoot extends StatelessWidget {
  final QAuthConfig   authConfig;
  final QRouterConfig routerConfig;

  const AppRoot({
    super.key,
    // Defaults to the QSpace config — other clients pass their own.
    this.authConfig   = kQSpaceAuthConfig,
    this.routerConfig = kQSpaceRouterConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // The concrete auth adapter. This is the single seam where adapters are swapped.
        authAdapterProvider.overrideWithValue(_buildAdapter()),
        // Which user classes, copy, and feature flags to use for auth screens.
        authConfigProvider.overrideWithValue(authConfig),
        // Extra routes and redirect rules for this client.
        routerConfigProvider.overrideWithValue(routerConfig),
      ],
      child: const QPagesApp(),
    );
  }

  // Builds the concrete auth adapter from kAuthAdapterType.
  // Throws immediately at startup if the type is wrong — loud failure beats
  // a silent misbehavior discovered hours later in a signIn() call.
  static _buildAdapter() {
    switch (kAuthAdapterType) {
      case AuthAdapterType.restJwt:
        return RestJwtAuthProvider(baseUrl: kApiBaseUrl);
      case AuthAdapterType.firebase:
        return FirebaseAuthProvider(defaultTenantId: kDefaultTenantId);
    }
  }
}