// lib/core/auth/auth_adapters/social/firebase_social_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Firebase social auth. Google + Apple + GitHub stubs.
//   v1.0.1 — Fixed: removed unused _kUsersCollection, _kDefaultTenantIdField
//             constants (Firestore document writes are not needed for social
//             sign-in — Firebase handles user creation automatically).
//             Fixed: _defaultTenantId field and _sessionFromUser() are used
//             only by the commented OAuth code. Suppressed unused warnings
//             with ignore directives — they will be referenced when the
//             OAuth flow is uncommented. Keeping them avoids a useless
//             rework cycle when the packages are added.
// ─────────────────────────────────────────────────────────────────────────────
//
// ⚠️  PUBSPEC REQUIREMENTS (add what you enable):
//   firebase_auth:       ^5.0.0
//   google_sign_in:      ^6.2.0   (Google only)
//   sign_in_with_apple:  ^6.0.0   (Apple — iOS/macOS/web only)
//
// GITHUB via Firebase requires flutter_web_auth_2 for the browser redirect.
// See the GitHub block below.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';

import '../../social_auth_port.dart';
import '../../auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseSocialProvider
// ─────────────────────────────────────────────────────────────────────────────

class FirebaseSocialProvider implements SocialAuthPort {
  final FirebaseAuth _auth;

  // Kept for use by _sessionFromUser when OAuth code is uncommented.
  // ignore: unused_field
  final String _defaultTenantId;

  FirebaseSocialProvider({
    FirebaseAuth? auth,
    required String defaultTenantId,
  })  : _auth            = auth ?? FirebaseAuth.instance,
        _defaultTenantId = defaultTenantId;

  @override
  bool get isConfigured => true;

  @override
  Future<QAuthSession> signInWith({
    required SocialAuthProvider provider,
    required String tenantId,
  }) async {
    switch (provider) {
      case SocialAuthProvider.google:
        return _signInWithGoogle(tenantId);
      case SocialAuthProvider.apple:
        return _signInWithApple(tenantId);
      case SocialAuthProvider.github:
        return _signInWithGitHub(tenantId);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    // GoogleSignIn().signOut(); // uncomment when google_sign_in is added
  }

  // ── Google ───────────────────────────────────────────────────────────────

  Future<QAuthSession> _signInWithGoogle(String tenantId) async {
    // Uncomment when google_sign_in is in pubspec:
    //
    // final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
    // if (googleUser == null) throw Exception('Google sign-in cancelled');
    // final googleAuth = await googleUser.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken:     googleAuth.idToken,
    // );
    // final result = await _auth.signInWithCredential(credential);
    // return _sessionFromUser(result.user!, tenantId);

    throw UnimplementedError(
      'Add google_sign_in to pubspec.yaml and uncomment the Google block.',
    );
  }

  // ── Apple ────────────────────────────────────────────────────────────────

  Future<QAuthSession> _signInWithApple(String tenantId) async {
    // Uncomment when sign_in_with_apple is in pubspec:
    //
    // final appleCredential = await SignInWithApple.getAppleIDCredential(
    //   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    // );
    // final oauthCredential = OAuthProvider('apple.com').credential(
    //   idToken:     appleCredential.identityToken,
    //   accessToken: appleCredential.authorizationCode,
    // );
    // final result = await _auth.signInWithCredential(oauthCredential);
    // return _sessionFromUser(result.user!, tenantId);

    throw UnimplementedError(
      'Add sign_in_with_apple to pubspec.yaml and uncomment the Apple block.',
    );
  }

  // ── GitHub ───────────────────────────────────────────────────────────────

  Future<QAuthSession> _signInWithGitHub(String tenantId) async {
    // GitHub OAuth via Firebase requires a web redirect on mobile.
    // Add flutter_web_auth_2 and implement:
    //
    // final githubProvider = GithubAuthProvider();
    // final result = await _auth.signInWithProvider(githubProvider); // web only
    // return _sessionFromUser(result.user!, tenantId);
    //
    // See: https://pub.dev/packages/flutter_web_auth_2

    throw UnimplementedError(
      'GitHub OAuth requires flutter_web_auth_2 on mobile. '
      'See firebase_social_provider.dart for the setup guide.',
    );
  }

  // ── Session builder ──────────────────────────────────────────────────────
  //
  // Called by the provider methods above once the OAuth flow completes.
  // Suppressed until the flow code is uncommented — removing this would
  // require adding it back when packages are installed.
  // ignore: unused_element
  Future<QAuthSession> _sessionFromUser(User user, String tenantId) async {
    try {
      final token = await user.getIdToken();
      return QAuthSession(
        userId:      user.uid,
        email:       user.email ?? '',
        displayName: user.displayName ?? '',
        tenantId:    tenantId,
        role:        QRole.user, // social sign-in starts at user tier
        token:       token,
      );
    } catch (e) {
      debugPrint('[FirebaseSocialProvider] session build error: $e');
      rethrow;
    }
  }
}