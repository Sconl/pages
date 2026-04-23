// lib/core/auth/auth_adapters/social/rest_jwt_social_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. REST JWT social auth. Exchange provider token for app JWT.
//   v1.0.1 — Fixed: removed unused flutter/foundation.dart import.
//             Suppressed unused_field warnings on _dio and _baseUrl — they are
//             used by _signInWithGoogle/Apple/GitHub once those methods are
//             implemented. Removing them now would require adding them back.
//             Suppressed unused_element on _sessionFromResponse — same reason.
// ─────────────────────────────────────────────────────────────────────────────
//
// REQUIRED BACKEND ENDPOINTS:
//   POST /api/auth/social/google  { id_token, tenant_id } → { token, user }
//   POST /api/auth/social/apple   { id_token, tenant_id } → { token, user }
//   POST /api/auth/social/github  { code, tenant_id }    → { token, user }

import 'dart:async';
import 'package:dio/dio.dart';

import '../../social_auth_port.dart';
import '../../auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kEndpointSocialGoogle = '/api/auth/social/google';
const _kEndpointSocialApple  = '/api/auth/social/apple';
const _kEndpointSocialGithub = '/api/auth/social/github';

// ─────────────────────────────────────────────────────────────────────────────
// RestJwtSocialProvider
// ─────────────────────────────────────────────────────────────────────────────

class RestJwtSocialProvider implements SocialAuthPort {
  // Suppressed: used by sign-in methods once OAuth flow is implemented.
  // ignore: unused_field
  final Dio    _dio;
  // ignore: unused_field
  final String _baseUrl;

  RestJwtSocialProvider({required String baseUrl})
      : _baseUrl = baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl:        baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

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
  Future<void> signOut() async {}

  // ── Provider flows ───────────────────────────────────────────────────────
  // Pattern per provider:
  //   Step 1: Run OAuth flow on device to get a provider token/code
  //   Step 2: POST token to your backend endpoint
  //   Step 3: Backend verifies with provider + returns app JWT
  //   Step 4: Parse into QAuthSession via _sessionFromResponse()

  Future<QAuthSession> _signInWithGoogle(String tenantId) async {
    // Step 1: final googleUser = await GoogleSignIn().signIn();
    // Step 2: final idToken = (await googleUser!.authentication).idToken!;
    // Step 3: final response = await _dio.post(_kEndpointSocialGoogle, data: {
    //           'id_token': idToken, 'tenant_id': tenantId });
    // Step 4: return _sessionFromResponse(response.data);

    throw UnimplementedError(
      'Implement Google OAuth and backend endpoint $_kEndpointSocialGoogle.',
    );
  }

  Future<QAuthSession> _signInWithApple(String tenantId) async {
    throw UnimplementedError(
      'Implement Apple OAuth and backend endpoint $_kEndpointSocialApple.',
    );
  }

  Future<QAuthSession> _signInWithGitHub(String tenantId) async {
    throw UnimplementedError(
      'Implement GitHub OAuth and backend endpoint $_kEndpointSocialGithub.',
    );
  }

  // Suppressed: called by the flow methods above once implemented.
  // ignore: unused_element
  QAuthSession _sessionFromResponse(Map<String, dynamic> data) {
    final token = data['token'] as String;
    final user  = data['user']  as Map<String, dynamic>;
    return QAuthSession(
      userId:      user['id']        as String,
      email:       user['email']     as String,
      displayName: user['name']      as String? ?? '',
      tenantId:    user['tenant_id'] as String? ?? '',
      role:        QRoleX.fromString(user['role'] as String?),
      token:       token,
    );
  }
}