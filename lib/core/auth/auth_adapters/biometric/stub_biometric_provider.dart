// lib/core/auth/auth_adapters/biometric/stub_biometric_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Default no-op. isAvailable always returns false.
//             isConfigured = false → UI hides biometric button entirely.
// ─────────────────────────────────────────────────────────────────────────────

import '../../biometric_auth_port.dart';

class StubBiometricProvider implements BiometricAuthPort {
  const StubBiometricProvider();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate({required String reason, String? cancelLabel}) async => false;

  @override
  bool get isConfigured => false;
}