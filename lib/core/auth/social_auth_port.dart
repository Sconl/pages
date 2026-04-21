// lib/core/auth/social_auth_port.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Abstract social auth contract + SocialAuthProvider enum.
//             Zero framework deps. Every concrete social adapter implements this.
//             UI depends on this — never on any concrete adapter.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: the contract for what social auth CAN do.
// What does NOT live here: OAuth flows, Firebase calls, token exchange, UI.

import 'auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SocialAuthProvider — the three standard social login options
// ─────────────────────────────────────────────────────────────────────────────

enum SocialAuthProvider { google, apple, github }

extension SocialAuthProviderX on SocialAuthProvider {
  String get displayName {
    switch (this) {
      case SocialAuthProvider.google: return 'Google';
      case SocialAuthProvider.apple:  return 'Apple';
      case SocialAuthProvider.github: return 'GitHub';
    }
  }

  // Drop a PNG/SVG at this path to replace the fallback letter rendering.
  // Format: 24×24, transparent background, single-color preferred.
  String get assetPath => 'assets/logos/social/$name.png';
}

// ─────────────────────────────────────────────────────────────────────────────
// SocialAuthPort
// ─────────────────────────────────────────────────────────────────────────────

abstract class SocialAuthPort {
  // Full OAuth flow → QAuthSession. The adapter handles everything in between.
  // Throws on cancellation or failure — callers wrap this in try/catch.
  Future<QAuthSession> signInWith({
    required SocialAuthProvider provider,
    required String tenantId,
  });

  // Signs out from the social provider. The session is also cleared by the
  // main AuthPort.signOut() — this handles provider-side cleanup.
  Future<void> signOut();

  // false = stub/unconfigured. UI suppresses social buttons when false.
  bool get isConfigured;
}