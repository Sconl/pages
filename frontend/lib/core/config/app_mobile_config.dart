// lib/core/config/app_mobile_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AppMobileConfig model + kQSpaceMobileConfig constant.
//   v1.1.0 — Providers added here (mobileConfigProvider, isMobileAppProvider).
//   v1.1.1 — Reverted provider additions. Both providers already existed in
//             app_client_config.dart, causing an ambiguous_import error in
//             app_root.dart. This file is model + constant only.
//             Providers live exclusively in app_client_config.dart.
// ─────────────────────────────────────────────────────────────────────────────
//
// AppMobileConfig is present only when the app is running as the QPages-branded
// mobile app, not when running as a web deployment or developer package.
//
// Providers (mobileConfigProvider, isMobileAppProvider) are declared in:
//   lib/core/config/app_client_config.dart
//
// Consumers that need the providers must import app_client_config.dart.
// Consumers that need only the type or constant import this file directly.

// ─────────────────────────────────────────────────────────────────────────────
// AppMobileConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for the QPages mobile app (Model 0).
/// Present only when the app is running as the QPages-branded mobile app,
/// not when running as a web deployment or developer package.
/// Passed to AppRoot — absent (null) means web / package mode.
class AppMobileConfig {
  /// When true, space_discovery is the app's initial route
  /// instead of the normal web entry experience.
  final bool discoveryEnabled;

  /// The deep link scheme registered in AndroidManifest.xml.
  /// Used by DeepLinkResolver to parse incoming URIs.
  /// Example: 'qpages'  →  qpages://t/{tenantId}
  final String deepLinkScheme;

  /// The Universal Link host registered for app links.
  /// Example: 'qpages.io'  →  https://qpages.io/app/{tenantId}
  final String universalLinkHost;

  /// The Universal Link path prefix for tenant deep links.
  /// Example: '/app'  →  https://qpages.io/app/{tenantId}
  final String universalLinkPath;

  const AppMobileConfig({
    this.discoveryEnabled = true,
    required this.deepLinkScheme,
    required this.universalLinkHost,
    required this.universalLinkPath,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Constant — injected via ProviderScope override in main_mobile.dart
// ─────────────────────────────────────────────────────────────────────────────

/// The QPages mobile app config.
/// Used in main_mobile.dart only — passed as a ProviderScope override.
const kQSpaceMobileConfig = AppMobileConfig(
  deepLinkScheme:    'qpages',
  universalLinkHost: 'qpages.io',
  universalLinkPath: '/app',
);