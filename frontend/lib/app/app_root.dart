// lib/interface/app_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Typed authConfig and routerConfig params.
//   v1.1.1 — Fixed: adapter import paths updated.
//   v1.2.0 — Migrated to AppClientConfig pattern (Session 3).
//   v1.2.1 — Fixed: config param made required (kQSpaceClientConfig is final).
//             Removed unused/redundant imports. Removed dead ?? fallbacks.
//   v1.2.2 — Fixed: restored router_config.dart import — routerConfigProvider
//             is defined there, not re-exported via auth_riverpod.dart.
//   v1.2.3 — Updated child: QPagesApp() → AppShell() following file rename
//             qpages_app.dart → app_shell.dart.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_client_config.dart';
import '../core/auth/auth_adapters/firebase_auth_provider.dart';
import '../core/auth/auth_adapters/rest_jwt_auth_provider.dart';
// import '../core/auth/auth_adapters/social/stub_social_provider.dart';
// import '../core/auth/auth_adapters/biometric/stub_biometric_provider.dart';
import '../core/router/router_config.dart';
import '../spaces/space_auth/auth_state/auth_riverpod.dart';
import 'app_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppRoot
// ─────────────────────────────────────────────────────────────────────────────

class AppRoot extends StatelessWidget {
  final AppClientConfig config;

  const AppRoot({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authAdapterProvider.overrideWithValue(_buildAuthAdapter()),
        authConfigProvider.overrideWithValue(config.auth),
        socialAuthConfigProvider.overrideWithValue(config.social),
        biometricConfigProvider.overrideWithValue(config.biometric),
        socialAuthAdapterProvider.overrideWithValue(_buildSocialAdapter()),
        biometricAuthAdapterProvider.overrideWithValue(_buildBiometricAdapter()),
        tenantIdProvider.overrideWithValue(config.defaultTenantId),
        routerConfigProvider.overrideWithValue(config.router),
      ],
      child: const AppShell(),
    );
  }

  AuthProvider _buildAuthAdapter() {
    switch (config.adapterType) {
      case AuthAdapterType.restJwt:
        return RestJwtAuthProvider(baseUrl: config.apiBaseUrl);
      case AuthAdapterType.firebase:
        return FirebaseAuthProvider(defaultTenantId: config.defaultTenantId);
    }
  }

  SocialAuthPort _buildSocialAdapter()       => config.socialAdapter;
  BiometricAuthPort _buildBiometricAdapter() => config.biometricAdapter;
}