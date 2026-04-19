// lib/experience/spaces/space_auth/state/auth_riverpod.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. All Riverpod providers for auth.
//   v1.1.0 — Added authConfigProvider (QAuthConfig — override in ProviderScope).
//             Added selectedUserClassProvider (stores the class id chosen at login
//             so the router knows which post-login route to use).
// ─────────────────────────────────────────────────────────────────────────────
//
// Provider summary:
//
//   authAdapterProvider       — the injected AuthProvider implementation.
//                               Overridden in app_root.dart. Throws if not overridden.
//
//   authConfigProvider        — the QAuthConfig for this tenant/deployment.
//                               Override in ProviderScope to change user classes,
//                               copy, feature flags, and post-login routing.
//                               Defaults to kAuthConfigDefault.
//
//   authSessionProvider       — Stream<QAuthSession?> from the adapter.
//                               GoRouter and screens both watch this.
//
//   currentSessionProvider    — Synchronous QAuthSession? accessor.
//                               Use inside auth-gated screens.
//
//   selectedUserClassProvider — Stores the AuthUserClass.id the user selected
//                               at the login/signup toggle. Set right before submit.
//                               Read by the router redirect to determine where to land.
//                               Cleared by setting to null after routing completes.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/auth/auth_config.dart';

export '../../../core/auth/auth_provider.dart';
export '../../../core/auth/auth_session.dart';
export '../../../core/auth/auth_config.dart';

// ── authAdapterProvider ──────────────────────────────────────────────────────

// MUST be overridden in ProviderScope (see app_root.dart).
// Throws UnimplementedError loudly if the override is missing — better than
// silently falling back to a wrong implementation.
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

// ── selectedUserClassProvider ────────────────────────────────────────────────

// Holds the AuthUserClass.id chosen on the role toggle right before login/signup.
// The router redirect reads this to pick the post-login destination.
// Null means "no selection yet" — router falls back to AuthPolicy.defaultHomeFor().
//
// Written by the screen in _submit(), not reactively — it's a transient signal,
// not persistent state. Don't read it anywhere except app_router.dart _redirect().
final selectedUserClassProvider = StateProvider<String?>((ref) => null);