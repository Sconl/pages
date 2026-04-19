// lib/interface/app_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Typed authConfig and routerConfig params.
//   v1.1.1 — Fixed: adapter import paths updated — infrastructure deleted,
//             adapters now live at lib/core/auth/auth_adapters/.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../client/qspace/client_config.dart';
import '../core/auth/auth_config.dart';
import '../core/router/router_config.dart';
import '../core/auth/auth_adapters/firebase_auth_provider.dart';
import '../core/auth/auth_adapters/rest_jwt_auth_provider.dart';
import '../spaces/space_auth/auth_state/auth_riverpod.dart';
import 'qpages_app.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppRoot
// ─────────────────────────────────────────────────────────────────────────────

class AppRoot extends StatelessWidget {
  final QAuthConfig   authConfig;
  final QRouterConfig routerConfig;

  const AppRoot({
    super.key,
    this.authConfig   = kQSpaceAuthConfig,
    this.routerConfig = kQSpaceRouterConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authAdapterProvider.overrideWithValue(_buildAdapter()),
        authConfigProvider.overrideWithValue(authConfig),
        routerConfigProvider.overrideWithValue(routerConfig),
      ],
      child: const QPagesApp(),
    );
  }

  static _buildAdapter() {
    switch (kAuthAdapterType) {
      case AuthAdapterType.restJwt:
        return RestJwtAuthProvider(baseUrl: kApiBaseUrl);
      case AuthAdapterType.firebase:
        return FirebaseAuthProvider(defaultTenantId: kDefaultTenantId);
    }
  }
}