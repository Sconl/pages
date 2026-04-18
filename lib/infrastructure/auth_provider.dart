// lib/infrastructure/auth_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Abstract AuthProvider extending AuthPort.
//   v1.0.1 — Fixed: removed unused direct import of auth_session.dart.
//             auth_session.dart is already re-exported via auth_port.dart's
//             export chain — the direct import was redundant and noisy.
// ─────────────────────────────────────────────────────────────────────────────

import '../core/auth/auth_port.dart';

export '../core/auth/auth_port.dart';
export '../core/auth/auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthProvider
// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthProvider implements AuthPort {
  @override
  Future<String?> getToken();
}