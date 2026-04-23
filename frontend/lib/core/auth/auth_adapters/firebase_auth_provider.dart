// lib/core/auth/auth_adapters/firebase_auth_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Firebase adapter.
//   v1.0.1 — Fixed: hide AuthProvider from firebase_auth import to prevent
//             name collision with our AuthProvider.
//   v1.0.2 — Moved from lib/infrastructure/adapters/ → lib/core/auth/auth_adapters/.
//             Fixed: removed redundant import of '../auth_session.dart' — all
//             session types are already available via '../auth_provider.dart'.
//             Fixed: added roleHint param to signUp() to satisfy AuthPort contract.
//             Firebase doesn't use roleHint natively — it's stored in Firestore
//             as a 'roleHint' field for backend processing or admin review.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';

import '../auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const _kUsersCollection      = 'users';
const _kDefaultRole          = 'user';
const _kDefaultTenantIdField = 'tenantId';

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseAuthProvider
// ─────────────────────────────────────────────────────────────────────────────

class FirebaseAuthProvider extends AuthProvider {
  final FirebaseAuth      _auth;
  final FirebaseFirestore _db;
  final String            _defaultTenantId;

  FirebaseAuthProvider({
    FirebaseAuth?      auth,
    FirebaseFirestore? db,
    required String    defaultTenantId,
  })  : _auth            = auth ?? FirebaseAuth.instance,
        _db              = db   ?? FirebaseFirestore.instance,
        _defaultTenantId = defaultTenantId;

  // ── AuthPort contract ────────────────────────────────────────────────────

  @override
  Stream<QAuthSession?> get sessionStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _buildSession(user);
    });
  }

  @override
  QAuthSession? get currentSession {
    final user = _auth.currentUser;
    if (user == null) return null;
    return QAuthSession(
      userId:      user.uid,
      email:       user.email ?? '',
      displayName: user.displayName ?? '',
      tenantId:    _defaultTenantId,
      role:        QRole.user,
      token:       null,
    );
  }

  @override
  Future<String?> getToken() async => _auth.currentUser?.getIdToken();

  @override
  Future<QAuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
    return _buildSession(credential.user!);
  }

  @override
  Future<QAuthSession> signUp({
    required String email,
    required String password,
    required String displayName,
    required String tenantId,
    String? roleHint,         // stored in Firestore — backend or admin decides whether to honor it
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    final user = credential.user!;

    try {
      await user.reload();
      await _auth.currentUser!.updateDisplayName(displayName);
    } catch (e) {
      debugPrint('[FirebaseAuthProvider] displayName update skipped (non-fatal): $e');
    }

    await _db.collection(_kUsersCollection).doc(user.uid).set({
      'uid':                   user.uid,
      'email':                 email,
      'displayName':           displayName,
      _kDefaultTenantIdField:  tenantId,
      'role':                  _kDefaultRole,
      if (roleHint != null) 'roleHint': roleHint,
      'createdAt':             FieldValue.serverTimestamp(),
      'updatedAt':             FieldValue.serverTimestamp(),
    });

    return _buildSession(user);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<QAuthSession?> refreshSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    return _buildSession(_auth.currentUser!);
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<QAuthSession> _buildSession(User user) async {
    try {
      final doc  = await _db.collection(_kUsersCollection).doc(user.uid).get();
      final data = doc.data() ?? {};
      return QAuthSession(
        userId:      user.uid,
        email:       user.email ?? data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? user.displayName ?? '',
        tenantId:    data[_kDefaultTenantIdField] as String? ?? _defaultTenantId,
        role:        QRoleX.fromString(data['role'] as String?),
        token:       await user.getIdToken(),
      );
    } catch (e) {
      debugPrint('[FirebaseAuthProvider] Firestore user fetch failed: $e');
      return QAuthSession(
        userId:      user.uid,
        email:       user.email ?? '',
        displayName: user.displayName ?? '',
        tenantId:    _defaultTenantId,
        role:        QRole.user,
        token:       await user.getIdToken(),
      );
    }
  }
}