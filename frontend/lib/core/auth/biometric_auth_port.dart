// lib/core/auth/biometric_auth_port.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Abstract biometric auth contract. Zero framework deps.
//             Concrete implementation uses local_auth. Stub always returns false.
// ─────────────────────────────────────────────────────────────────────────────
//
// Biometric authenticates the device owner — it does NOT create or own a
// session. After a successful biometric check, the shell attempts a token
// refresh via the main AuthPort. The biometric is the gate, not the key.

abstract class BiometricAuthPort {
  // true if the device supports biometrics and the user has enrolled.
  // Async because it hits a platform channel.
  Future<bool> isAvailable();

  // Triggers the system biometric prompt.
  // Returns true on success, false on cancellation.
  // Throws if the device is locked out or an unrecoverable error occurs.
  Future<bool> authenticate({
    required String reason,
    String? cancelLabel,
  });

  // false = stub/unconfigured. UI hides biometric button when false.
  bool get isConfigured;
}