// lib/core/auth/auth_adapters/rest_jwt_auth_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. JWT adapter for Rust/Axum backend.
//   v1.0.1 — Moved from lib/infrastructure/adapters/ → lib/core/auth/auth_adapters/.
//             Fixed: removed redundant import of '../auth_session.dart'.
//             Fixed: added roleHint param to signUp() — forwarded to backend
//             register payload as 'role_hint'. Backend decides whether to honor it.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Storage keys ──
const _kStorageKeyToken        = 'qspace_auth_token';
const _kStorageKeyRefreshToken = 'qspace_auth_refresh_token';

// ── API endpoints (relative to baseUrl) ──
const _kEndpointLogin         = '/api/auth/login';
const _kEndpointRegister      = '/api/auth/register';
const _kEndpointResetPassword = '/api/auth/reset-password';
const _kEndpointRefresh       = '/api/auth/refresh';

// ── HTTP ──
const _kConnectTimeout = Duration(seconds: 10);
const _kReceiveTimeout = Duration(seconds: 10);

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

    final token  = response.data['token']      as String;
    final expiry = response.data['expires_at'] as String?;
    final user   = response.data['user']       as Map<String, dynamic>;

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
    String? roleHint,         // forwarded to backend — backend decides whether to honor it
  }) async {
    await _dio.post(_kEndpointRegister, data: {
      'email':      email,
      'password':   password,
      'name':       displayName,
      'tenant_id':  tenantId,
      if (roleHint != null) 'role_hint': roleHint,
    });

    // Backend doesn't return a token on register — sign in to get one.
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
    final prefs        = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_kStorageKeyRefreshToken);
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(_kEndpointRefresh, data: {
        'refresh_token': refreshToken,
      });
      final token   = response.data['token']      as String;
      final expiry  = response.data['expires_at'] as String?;
      final user    = response.data['user']       as Map<String, dynamic>;
      final session = _sessionFromTokenAndUser(token, user, expiry);
      await _persistSession(token, response.data['refresh_token'] as String?);
      _emitSession(session);
      return session;
    } catch (_) {
      await signOut();
      return null;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

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

      if (expiry != null &&
          DateTime.fromMillisecondsSinceEpoch(expiry * 1000).isBefore(DateTime.now())) {
        await prefs.remove(_kStorageKeyToken);
        _sessionController.add(null);
        return;
      }

      final session = _sessionFromJwtPayload(token, payload);
      _currentSession = session;
      _sessionController.add(session);
    } catch (e) {
      debugPrint('[RestJwtAuthProvider] session restore failed: $e');
      _sessionController.add(null);
    }
  }

  QAuthSession _sessionFromTokenAndUser(
    String token,
    Map<String, dynamic> user,
    String? expiryIso,
  ) =>
      QAuthSession(
        userId:      user['id']        as String,
        email:       user['email']     as String,
        displayName: user['name']      as String? ?? '',
        tenantId:    user['tenant_id'] as String? ?? '',
        role:        QRoleX.fromString(user['role'] as String?),
        expiresAt:   expiryIso != null ? DateTime.tryParse(expiryIso) : null,
        token:       token,
      );

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

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT format');
    final normalized = base64Url.normalize(parts[1]);
    final decoded    = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}