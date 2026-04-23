// lib/core/auth/auth_port.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Abstract auth contract. No framework. No provider mention.
//             Follows Universal Architecture Directive § 5.
//   v1.1.0 — Added optional roleHint to signUp() — the class the user selected
//             at signup. Backend may or may not use it. Zero breaking change.
// ─────────────────────────────────────────────────────────────────────────────
//
// This file defines what auth CAN do — nothing about HOW.
// Firebase, JWT, Auth0 — none of that belongs here.
// Every adapter (RestJwt, Firebase, Mock) implements this.
//
// Consumers depend on AuthPort. AuthPort depends on nothing.
// Adapters depend on providers.

import 'auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthPort
// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthPort {
  // Real-time session stream. Emits null on sign-out.
  // GoRouter and the session provider both listen here.
  Stream<QAuthSession?> get sessionStream;

  // Synchronous current session — null if not authenticated.
  // Use this inside auth-gated logic where you know the guard already ran.
  QAuthSession? get currentSession;

  // Returns the raw bearer token for authenticated API calls.
  // Null if signed out. Adapters handle refresh internally.
  Future<String?> getToken();

  Future<QAuthSession> signIn({
    required String email,
    required String password,
  });

  Future<QAuthSession> signUp({
    required String email,
    required String password,
    required String displayName,
    // tenantId is required here because sign-up in a multitenant system
    // needs to bind the new user to the right tenant from the first call.
    required String tenantId,
    // roleHint is the AuthUserClass.id the user selected at signup.
    // Pass it to the backend — the backend decides whether to honor it.
    // Null if no role toggle was shown (single-user config).
    String? roleHint,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  // Refresh the session without re-entering credentials.
  // REST adapter reads the stored refresh token. Firebase does this natively.
  Future<QAuthSession?> refreshSession();
}