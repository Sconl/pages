// lib/core/auth/auth_adapters/biometric/local_biometric_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Device-native biometric auth via local_auth package.
//             Handles fingerprint, face ID, iris depending on device capability.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  PUBSPEC REQUIREMENT:
//   local_auth: ^2.2.0
//
// ANDROID setup:
//   android/app/src/main/AndroidManifest.xml:
//   <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
//
// iOS setup:
//   ios/Runner/Info.plist:
//   <key>NSFaceIDUsageDescription</key>
//   <string>We use Face ID to keep your account secure.</string>
//
// HOW IT WORKS WITH AUTH:
//   Biometric doesn't own a session. After a successful biometric check,
//   the shell calls authAdapter.refreshSession() to restore the stored token.
//   The biometric is the gate — the refresh token is the key.

// import 'package:local_auth/local_auth.dart'; // uncomment when added to pubspec

import '../../biometric_auth_port.dart';

class LocalBiometricProvider implements BiometricAuthPort {
  // final LocalAuthentication _auth = LocalAuthentication(); // uncomment when ready

  const LocalBiometricProvider();

  @override
  bool get isConfigured => true;

  @override
  Future<bool> isAvailable() async {
    // Uncomment when local_auth is in pubspec:
    //
    // final canCheck = await _auth.canCheckBiometrics;
    // final isDeviceSupported = await _auth.isDeviceSupported();
    // if (!canCheck || !isDeviceSupported) return false;
    // final availableBiometrics = await _auth.getAvailableBiometrics();
    // return availableBiometrics.isNotEmpty;

    // Stub: always false until package is added
    return false;
  }

  @override
  Future<bool> authenticate({
    required String reason,
    String? cancelLabel,
  }) async {
    // Uncomment when local_auth is in pubspec:
    //
    // return await _auth.authenticate(
    //   localizedReason: reason,
    //   options: AuthenticationOptions(
    //     stickyAuth: true,
    //     biometricOnly: false, // allow PIN fallback
    //   ),
    // );

    return false;
  }
}