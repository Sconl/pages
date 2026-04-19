// lib/spaces/space_auth/state/auth_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial.
//   v1.1.0 — Added authConfigProvider and selectedUserClassProvider.
//   v1.1.1 — Fixed: import paths updated after folder restructure.
//             experience/spaces → spaces; infrastructure → core/auth.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/auth/auth_config.dart';

export '../../../core/auth/auth_provider.dart';
export '../../../core/auth/auth_session.dart';
export '../../../core/auth/auth_config.dart';

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

// ── authSessionProvider ──────────────────────────────────────────────────────

final authSessionProvider = StreamProvider<QAuthSession?>((ref) {
  return ref.watch(authAdapterProvider).sessionStream;
});

// ── currentSessionProvider ───────────────────────────────────────────────────

final currentSessionProvider = Provider<QAuthSession?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull;
});

// ── selectedUserClassProvider ────────────────────────────────────────────────

// Written by the screen right before signIn/signUp. Read by the router redirect
// to determine where to route the user post-auth. Null = use AuthPolicy default.
final selectedUserClassProvider = StateProvider<String?>((ref) => null);