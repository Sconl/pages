// lib/spaces/space_auth/auth_state/auth_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Added authConfigProvider, selectedUserClassProvider.
//   v1.1.1 — Import paths updated after folder restructure.
//   v2.0.0 — Moved to auth_state/. Paths updated.
//   v2.1.0 — Added socialAuthAdapterProvider, biometricAuthAdapterProvider,
//             socialAuthConfigProvider, biometricConfigProvider, tenantIdProvider.
//             All six new providers must be overridden in ProviderScope (AppRoot).
// ─────────────────────────────────────────────────────────────────────────────
//
// Provider registry for the auth space.
// All providers here are shells — AppRoot overrides them with real values.
// Default values are safe no-ops so the app doesn't crash if a provider is
// accidentally read before the override is applied.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/auth/auth_config.dart';
import '../../../../core/auth/social_auth_port.dart';
import '../../../../core/auth/biometric_auth_port.dart';
import '../../../../core/auth/auth_adapters/social/stub_social_provider.dart';
import '../../../../core/auth/auth_adapters/biometric/stub_biometric_provider.dart';

export '../../../../core/auth/auth_provider.dart';
export '../../../../core/auth/auth_session.dart';
export '../../../../core/auth/auth_config.dart';
export '../../../../core/auth/social_auth_port.dart';
export '../../../../core/auth/biometric_auth_port.dart';

// ── authAdapterProvider ──────────────────────────────────────────────────────

final authAdapterProvider = Provider<AuthProvider>((ref) {
  throw UnimplementedError(
    'authAdapterProvider must be overridden in ProviderScope.\n'
    'See lib/interface/app_root.dart.',
  );
});

// ── authConfigProvider ───────────────────────────────────────────────────────

final authConfigProvider = Provider<QAuthConfig>(
  (ref) => kAuthConfigDefault,
);

// ── socialAuthConfigProvider ─────────────────────────────────────────────────

// Controls which social buttons appear and in what order.
final socialAuthConfigProvider = Provider<QSocialAuthConfig>(
  (ref) => const QSocialAuthConfig(enabled: false),
);

// ── biometricConfigProvider ──────────────────────────────────────────────────

final biometricConfigProvider = Provider<QBiometricConfig>(
  (ref) => const QBiometricConfig(enabled: false),
);

// ── socialAuthAdapterProvider ────────────────────────────────────────────────

// The concrete social auth implementation. Stub by default.
final socialAuthAdapterProvider = Provider<SocialAuthPort>(
  (ref) => const StubSocialProvider(),
);

// ── biometricAuthAdapterProvider ─────────────────────────────────────────────

// The concrete biometric implementation. Stub by default (always unavailable).
final biometricAuthAdapterProvider = Provider<BiometricAuthPort>(
  (ref) => const StubBiometricProvider(),
);

// ── tenantIdProvider ─────────────────────────────────────────────────────────

// The active tenant. Overridden in ProviderScope with config.defaultTenantId.
// Shells and sections read this instead of importing client_config.dart.
// This keeps space files completely client-agnostic.
final tenantIdProvider = Provider<String>((ref) => 'default');

// ── authSessionProvider ──────────────────────────────────────────────────────

final authSessionProvider = StreamProvider<QAuthSession?>((ref) {
  return ref.watch(authAdapterProvider).sessionStream;
});

// ── currentSessionProvider ───────────────────────────────────────────────────

final currentSessionProvider = Provider<QAuthSession?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull;
});

// ── selectedUserClassProvider ────────────────────────────────────────────────

// Written by ShellAuthRoot right before signIn/signUp.
// Read once by GoRouter redirect to determine post-login destination.
final selectedUserClassProvider = StateProvider<String?>((ref) => null);