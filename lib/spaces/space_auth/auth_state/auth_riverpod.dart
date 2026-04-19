// lib/spaces/space_auth/auth_state/auth_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. All Riverpod providers for auth.
//   v1.1.0 — Added authConfigProvider and selectedUserClassProvider.
//   v1.1.1 — Import paths updated after folder restructure.
//   v2.0.0 — Moved from state/ → auth_state/ per layered architecture.
//             Import paths updated accordingly.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: behavior wiring — providers, session stream, access.
// What does NOT live here: UI widgets, layout logic, screen composition.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/auth/auth_config.dart';

export '../../../core/auth/auth_provider.dart';
export '../../../core/auth/auth_session.dart';
export '../../../core/auth/auth_config.dart';

// ── authAdapterProvider ──────────────────────────────────────────────────────

// MUST be overridden in ProviderScope (see lib/interface/app_root.dart).
// Throws loudly if the override is missing — better than a silent wrong adapter.
final authAdapterProvider = Provider<AuthProvider>((ref) {
  throw UnimplementedError(
    'authAdapterProvider must be overridden in ProviderScope.\n'
    'See lib/interface/app_root.dart.',
  );
});

// ── authConfigProvider ───────────────────────────────────────────────────────

// Override in ProviderScope to customize auth behavior for a tenant.
// Defaults to the standard two-tier user/admin config.
final authConfigProvider = Provider<QAuthConfig>(
  (ref) => kAuthConfigDefault,
);

// ── authSessionProvider ──────────────────────────────────────────────────────

final authSessionProvider = StreamProvider<QAuthSession?>((ref) {
  return ref.watch(authAdapterProvider).sessionStream;
});

// ── currentSessionProvider ───────────────────────────────────────────────────

// Synchronous accessor. Use inside screens already behind the GoRouter guard.
final currentSessionProvider = Provider<QAuthSession?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull;
});

// ── selectedUserClassProvider ────────────────────────────────────────────────

// Written by ShellAuthRoot right before signIn/signUp.
// Read once by the GoRouter redirect to determine post-login destination.
// Null means no explicit selection — router falls back to AuthPolicy.defaultHomeFor().
final selectedUserClassProvider = StateProvider<String?>((ref) => null);