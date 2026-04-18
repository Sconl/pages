// lib/experience/spaces/space_auth/state/auth_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. All Riverpod providers for auth.
//             authAdapterProvider must be overridden in ProviderScope — it
//             throws by default so misconfigured apps fail loudly at startup,
//             not silently mid-flow.
// ─────────────────────────────────────────────────────────────────────────────
//
// Provider summary:
//
//   authAdapterProvider    — the injected AuthProvider implementation.
//                            Overridden in app_root.dart based on client config.
//                            Throws if you forget the override.
//
//   authSessionProvider    — Stream<QAuthSession?> from the adapter.
//                            GoRouter and screens both watch this.
//
//   currentSessionProvider — Synchronous QAuthSession? .value accessor.
//                            Use inside auth-gated screens where the guard
//                            already ran and you just need the session data.
//
// WHO IMPORTS WHAT:
//   app_router.dart       → authSessionProvider, currentSessionProvider
//   app_root.dart         → authAdapterProvider (to set the override)
//   screen_login.dart     → authAdapterProvider (to call signIn)
//   screen_signup.dart    → authAdapterProvider (to call signUp)
//   screen_reset.dart     → authAdapterProvider (to call sendPasswordReset)
//   any auth-gated screen → currentSessionProvider

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/auth_provider.dart';
import '../../../../core/auth/auth_session.dart';

export '../../../../infrastructure/auth_provider.dart';
export '../../../../core/auth/auth_session.dart';

// ── authAdapterProvider ──────────────────────────────────────────────────────

// MUST be overridden in ProviderScope (see app_root.dart).
// Throws UnimplementedError if app_root.dart forgot the override.
final authAdapterProvider = Provider<AuthProvider>((ref) {
  throw UnimplementedError(
    'authAdapterProvider must be overridden in ProviderScope.\n'
    'See lib/interface/app_root.dart.',
  );
});

// ── authSessionProvider ──────────────────────────────────────────────────────

// Thin wrapper around the adapter's sessionStream.
// Emits null when signed out, QAuthSession when signed in.
final authSessionProvider = StreamProvider<QAuthSession?>((ref) {
  return ref.watch(authAdapterProvider).sessionStream;
});

// ── currentSessionProvider ───────────────────────────────────────────────────

// Synchronous accessor. Returns null during the brief stream loading window.
// Only use this inside screens that are behind the GoRouter auth guard.
final currentSessionProvider = Provider<QAuthSession?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull;
});