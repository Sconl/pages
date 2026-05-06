// lib/core/config/app_client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.2.0 — Added localOverlayAssetPath to AppClientConfig.
//             When set, the merge engine loads overlay.json from Flutter assets
//             instead of a CDN/API — enables Developer Package mode as a
//             first-class deployment option. Null = SaaS / Enterprise mode.
//   v1.1.0 — Added mobileConfigProvider and isMobileAppProvider.
//             Null mobileConfig = web/package mode; non-null = QPages mobile app.
//             Both providers are overridden in AppRoot's ProviderScope.
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_config.dart';
import '../auth/social_auth_port.dart';
import '../auth/biometric_auth_port.dart';
import '../auth/auth_adapters/social/stub_social_provider.dart';
import '../auth/auth_adapters/biometric/stub_biometric_provider.dart';
import '../router/router_config.dart';
import 'app_mobile_config.dart';

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
  final SocialAuthPort    socialAdapter;
  final BiometricAuthPort biometricAdapter;

  // ── Developer Package mode ────────────────────────────────────────────────
  // When set, the merge engine loads overlay.json from Flutter assets at this
  // path instead of fetching from a CDN or API. Keeps package-mode projects
  // fully self-contained — no network dependency, no credentials needed.
  // Leave null for SaaS and Enterprise deployments.
  final String? localOverlayAssetPath;

  AppClientConfig({
    required this.adapterType,
    required this.apiBaseUrl,
    required this.defaultTenantId,
    required this.auth,
    this.social                = const QSocialAuthConfig(),
    this.biometric             = const QBiometricConfig(),
    this.router                = const QRouterConfig(),
    this.localOverlayAssetPath,
    SocialAuthPort?    socialAdapter,
    BiometricAuthPort? biometricAdapter,
  })  : socialAdapter    = socialAdapter    ?? const StubSocialProvider(),
        biometricAdapter = biometricAdapter ?? const StubBiometricProvider();
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Riverpod provider for mobile config. Null when running as web / package.
/// Overridden in AppRoot's ProviderScope to inject kQSpaceMobileConfig on
/// native mobile builds.
final mobileConfigProvider = Provider<AppMobileConfig?>((ref) {
  throw UnimplementedError('mobileConfigProvider must be overridden in AppRoot');
});

/// Convenience provider — true when running as the QPages mobile app.
final isMobileAppProvider = Provider<bool>((ref) {
  return ref.watch(mobileConfigProvider) != null;
});