// lib/core/config/app_client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AppClientConfig — the master config class.
//             Centralizes every subsystem config in one object.
//             AppRoot takes exactly one AppClientConfig and derives everything.
//             To configure QSpace Pages for any project: define one instance
//             of this class in your client_config.dart and pass it to AppRoot.
// ─────────────────────────────────────────────────────────────────────────────
//
// PHILOSOPHY:
//   Every piece of behavior that could differ between projects, tenants, or
//   deployment flavors lives in AppClientConfig. AppRoot and the core system
//   are completely project-agnostic — they only know about this config object.
//
// HOW TO ADD A NEW PROJECT:
//   1. Create lib/client/{project}/client_config.dart
//   2. Define a final {kProject}ClientConfig = AppClientConfig(...)
//   3. Create main_{project}.dart → runApp(AppRoot(config: kProjectClientConfig))
//   4. Done — zero changes to any core file.

import '../auth/auth_config.dart';
import '../auth/social_auth_port.dart';
import '../auth/biometric_auth_port.dart';
import '../auth/auth_adapters/social/stub_social_provider.dart';
import '../auth/auth_adapters/biometric/stub_biometric_provider.dart';
import '../router/router_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthAdapterType — which auth backend this deployment uses
// ─────────────────────────────────────────────────────────────────────────────

enum AuthAdapterType { restJwt, firebase }

// ─────────────────────────────────────────────────────────────────────────────
// AppClientConfig — the master config
// ─────────────────────────────────────────────────────────────────────────────

class AppClientConfig {
  // ── Backend ───────────────────────────────────────────────────────────────
  final AuthAdapterType adapterType;
  final String          apiBaseUrl;
  final String          defaultTenantId;

  // ── Auth UI behavior ──────────────────────────────────────────────────────
  final QAuthConfig auth;

  // ── Social login ──────────────────────────────────────────────────────────
  final QSocialAuthConfig social;

  // ── Biometric ─────────────────────────────────────────────────────────────
  final QBiometricConfig biometric;

  // ── Routing extras ────────────────────────────────────────────────────────
  final QRouterConfig router;

  // ── Concrete adapters ─────────────────────────────────────────────────────
  // Null → stub used (feature effectively off).
  // Pass a real implementation to enable: GoogleSocialProvider(), LocalBiometricProvider(), etc.
  final SocialAuthPort   socialAdapter;
  final BiometricAuthPort biometricAdapter;

  AppClientConfig({
    required this.adapterType,
    required this.apiBaseUrl,
    required this.defaultTenantId,
    required this.auth,
    this.social          = const QSocialAuthConfig(),
    this.biometric       = const QBiometricConfig(),
    this.router          = const QRouterConfig(),
    SocialAuthPort?    socialAdapter,
    BiometricAuthPort? biometricAdapter,
  })  : socialAdapter    = socialAdapter    ?? const StubSocialProvider(),
        biometricAdapter = biometricAdapter ?? const StubBiometricProvider();
}