// frontend/lib/spaces/space_architect/architect_model/architect_credentials.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_model → architect_model.
//   • 2026-04-25 — Initial. Local credential validation + mock auth provider.
// ─────────────────────────────────────────────────────────────────────────────
//
// Two things live here:
//   1. validateArchitectCredentials — compares input against hardcoded dev
//      credentials. No network, no hashing, no backend.
//   2. ArchitectMockAuthProvider — full AuthProvider injected into the preview
//      ProviderScope so previewed auth screens can call signIn/signUp without
//      hitting a real backend.

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inline
// ─────────────────────────────────────────────────────────────────────────────

// ── Architect login credentials ───────────────────────────────────────────────
const String kArchitectUsername  = 'sconl';
const String _kArchitectPassword = 'architect';

// ── Mock preview session identity ─────────────────────────────────────────────
const String _kPreviewUserId      = 'arch-preview-001';
const String _kPreviewEmail       = 'preview@qspace.local';
const String _kPreviewDisplayName = 'Preview User';
const String _kPreviewTenantId    = 'qspace-dev';

// Realistic latency so loading spinners actually render during preview —
// 0ms responses make it impossible to verify the loading state visually
const Duration kMockAuthLatency = Duration(milliseconds: 800);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// validateArchitectCredentials
// ─────────────────────────────────────────────────────────────────────────────

bool validateArchitectCredentials(String username, String password) =>
    username.trim() == kArchitectUsername && password == _kArchitectPassword;

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectMockAuthProvider
// ─────────────────────────────────────────────────────────────────────────────
//
// Silent sessionStream so GoRouter inside the preview never fires its redirect
// callback — the screen stays pinned in the preview window regardless of what
// the auth form does.

class ArchitectMockAuthProvider extends AuthProvider {
  @override
  Stream<QAuthSession?> get sessionStream => const Stream.empty();

  @override
  QAuthSession? get currentSession => null;

  @override
  Future<String?> getToken() async => 'architect-preview-mock-token';

  @override
  Future<QAuthSession> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(kMockAuthLatency);
    return _previewSession;
  }

  @override
  Future<QAuthSession> signUp({
    required String email,
    required String password,
    required String displayName,
    required String tenantId,
    String? roleHint,
  }) async {
    await Future.delayed(kMockAuthLatency);
    return _previewSession;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(kMockAuthLatency);
  }

  @override
  Future<QAuthSession?> refreshSession() async => null;

  static const QAuthSession _previewSession = QAuthSession(
    userId:      _kPreviewUserId,
    email:       _kPreviewEmail,
    displayName: _kPreviewDisplayName,
    tenantId:    _kPreviewTenantId,
    role:        QRole.architect,
  );
}