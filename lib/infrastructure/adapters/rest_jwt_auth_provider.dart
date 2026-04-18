// lib/infrastructure/adapters/rest_jwt_auth_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. JWT adapter for Rust backend.
//             Parses JWT payload locally (no external jwt library needed).
//             Stores tokens in shared_preferences for session persistence.
//             StreamController manages session state since REST has no push.
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the production adapter for the Rust/Axum backend.
// It talks to /api/auth/login and /api/auth/register.
//
// Session persistence strategy:
//   - JWT stored in shared_preferences under kStorageKeyToken
//   - On app start, we try to parse the stored token and restore session
//   - On expiry, we emit null and route to login
//   - Refresh token (if backend supports it) would go in _tryRefresh()

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_session.dart';
import '../auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Storage keys ──
const _kStorageKeyToken        = 'qspace_auth_token';
const _kStorageKeyRefreshToken = 'qspace_auth_refresh_token';

// ── API endpoints (relative to baseUrl) ──
const _kEndpointLogin          = '/api/auth/login';
const _kEndpointRegister       = '/api/auth/register';
const _kEndpointResetPassword  = '/api/auth/reset-password';
const _kEndpointRefresh        = '/api/auth/refresh';

// ── HTTP ──
const _kConnectTimeout         = Duration(seconds: 10);
const _kReceiveTimeout         = Duration(seconds: 10);

// ─────────────────────────────────────────────────────────────────────────────
// RestJwtAuthProvider
// ─────────────────────────────────────────────────────────────────────────────

class RestJwtAuthProvider extends AuthProvider {
  final String _baseUrl;
  late final Dio _dio;

  final _sessionController = StreamController<QAuthSession?>.broadcast();
  QAuthSession? _currentSession;

  RestJwtAuthProvider({required String baseUrl}) : _baseUrl = baseUrl {
    _dio = Dio(BaseOptions(
      baseUrl:        _baseUrl,
      connectTimeout: _kConnectTimeout,
      receiveTimeout: _kReceiveTimeout,
    ));

    // Try to restore session on startup — emit async so listeners attach first.
    _restoreSession();
  }

  // ── AuthPort contract ────────────────────────────────────────────────────

  @override
  Stream<QAuthSession?> get sessionStream => _sessionController.stream;

  @override
  QAuthSession? get currentSession => _currentSession;

  @override
  Future<String?> getToken() async {
    if (_currentSession?.rawToken != null) return _currentSession!.rawToken;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kStorageKeyToken);
  }

  @override
  Future<QAuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(_kEndpointLogin, data: {
      'email':    email,
      'password': password,
    });

    final token   = response.data['token']   as String;
    final expiry  = response.data['expires_at'] as String?;
    final user    = response.data['user']    as Map<String, dynamic>;

    final session = _sessionFromTokenAndUser(token, user, expiry);
    await _persistSession(token, response.data['refresh_token'] as String?);
    _emitSession(session);
    return session;
  }

  @override
  Future<QAuthSession> signUp({
    required String email,
    required String password,
    required String displayName,
    required String tenantId,
  }) async {
    // Register creates the user — sign-in follows immediately.
    await _dio.post(_kEndpointRegister, data: {
      'email':      email,
      'password':   password,
      'name':       displayName,
      'tenant_id':  tenantId,
    });

    // Backend doesn't return a token on register — we sign in to get one.
    return signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStorageKeyToken);
    await prefs.remove(_kStorageKeyRefreshToken);
    _sessionController.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _dio.post(_kEndpointResetPassword, data: {'email': email});
  }

  @override
  Future<QAuthSession?> refreshSession() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_kStorageKeyRefreshToken);
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(_kEndpointRefresh, data: {
        'refresh_token': refreshToken,
      });
      final token   = response.data['token']   as String;
      final expiry  = response.data['expires_at'] as String?;
      final user    = response.data['user']    as Map<String, dynamic>;
      final session = _sessionFromTokenAndUser(token, user, expiry);
      await _persistSession(token, response.data['refresh_token'] as String?);
      _emitSession(session);
      return session;
    } catch (_) {
      // Refresh failed — force re-login
      await signOut();
      return null;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  // Restores session from stored JWT on app cold-start.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kStorageKeyToken);
      if (token == null) {
        _sessionController.add(null);
        return;
      }

      final payload = _parseJwt(token);
      final expiry  = payload['exp'] as int?;

      // JWT is expired — clear it and emit null
      if (expiry != null &&
          DateTime.fromMillisecondsSinceEpoch(expiry * 1000)
              .isBefore(DateTime.now())) {
        await prefs.remove(_kStorageKeyToken);
        _sessionController.add(null);
        return;
      }

      final session = _sessionFromJwtPayload(token, payload);
      _currentSession = session;
      _sessionController.add(session);
    } catch (e) {
      // Corrupted token — start fresh
      debugPrint('[RestJwtAuthProvider] session restore failed: $e');
      _sessionController.add(null);
    }
  }

  QAuthSession _sessionFromTokenAndUser(
    String token,
    Map<String, dynamic> user,
    String? expiryIso,
  ) {
    return QAuthSession(
      userId:      user['id']   as String,
      email:       user['email'] as String,
      displayName: user['name'] as String? ?? '',
      tenantId:    user['tenant_id'] as String? ?? '',
      role:        QRoleX.fromString(user['role'] as String?),
      expiresAt:   expiryIso != null ? DateTime.tryParse(expiryIso) : null,
      token:       token,
    );
  }

  QAuthSession _sessionFromJwtPayload(String token, Map<String, dynamic> p) {
    final expiry = p['exp'] as int?;
    return QAuthSession(
      userId:      p['sub']       as String? ?? '',
      email:       p['email']     as String? ?? '',
      displayName: p['name']      as String? ?? '',
      tenantId:    p['tenant_id'] as String? ?? '',
      role:        QRoleX.fromString(p['role'] as String?),
      expiresAt:   expiry != null
          ? DateTime.fromMillisecondsSinceEpoch(expiry * 1000)
          : null,
      token: token,
    );
  }

  Future<void> _persistSession(String token, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKeyToken, token);
    if (refreshToken != null) {
      await prefs.setString(_kStorageKeyRefreshToken, refreshToken);
    }
  }

  void _emitSession(QAuthSession session) {
    _currentSession = session;
    _sessionController.add(session);
  }

  // Decode JWT payload without a library.
  // JWT is three base64url segments: header.payload.signature
  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT format');
    final payload = parts[1];
    // base64Url needs padding to a multiple of 4
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}