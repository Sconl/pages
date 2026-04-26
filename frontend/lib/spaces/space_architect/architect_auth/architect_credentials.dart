// frontend/lib/spaces/space_architect/architect_auth/architect_credentials.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. Local credential validation + mock auth provider
//                  for use inside preview windows. No backend, no JWT.
// ─────────────────────────────────────────────────────────────────────────────
//
// Everything here is intentionally local. Architect auth never touches the
// network. The mock provider exists so screens that call authAdapterProvider
// inside the preview don't crash — they just get a simulated success response.

import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inline
// ─────────────────────────────────────────────────────────────────────────────

// ── Credentials ───────────────────────────────────────────────────────────────
const String kArchitectUsername = 'sconl';
const String _kArchitectPassword = 'architect';

// ── Preview session identity ───────────────────────────────────────────────────
// Used by ArchitectMockAuthProvider so previewed auth screens can "succeed"
const String _kPreviewUserId      = 'arch-preview-001';
const String _kPreviewEmail       = 'preview@qspace.local';
const String _kPreviewDisplayName = 'Preview User';
const String _kPreviewTenantId    = 'qspace-dev';

// Realistic latency so loading spinners actually render during preview testing
const Duration kMockAuthLatency = Duration(milliseconds: 800);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// validateArchitectCredentials
// ─────────────────────────────────────────────────────────────────────────────

/// Returns true if the username/password match the architect credentials.
/// Intentionally simple — this is a dev-only tool, not a security boundary.
bool validateArchitectCredentials(String username, String password) =>
    username.trim() == kArchitectUsername && password == _kArchitectPassword;

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectMockAuthProvider
// ─────────────────────────────────────────────────────────────────────────────
//
// Injected into the preview ProviderScope so screens that call signIn/signUp
// get a realistic success response without hitting a backend. The session
// returned is architect-level so all role guards pass in the preview.
//
// Important: this provider never emits a real session stream, so GoRouter's
// auth redirect doesn't fire inside the preview — screens stay where they are.

class ArchitectMockAuthProvider extends AuthProvider {
  // Keeps session stream silent so GoRouter inside the preview doesn't redirect
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
    // Fake the network round-trip so the loading spinner renders
    await Future.delayed(kMockAuthLatency);
    return const QAuthSession(
      userId:      _kPreviewUserId,
      email:       _kPreviewEmail,
      displayName: _kPreviewDisplayName,
      tenantId:    _kPreviewTenantId,
      role:        QRole.architect,
    );
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
    return const QAuthSession(
      userId:      _kPreviewUserId,
      email:       _kPreviewEmail,
      displayName: _kPreviewDisplayName,
      tenantId:    _kPreviewTenantId,
      role:        QRole.architect,
    );
  }

  @override
  Future<void> signOut() async {
    // No-op — preview sessions are stateless
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    // Simulate the async call so the UI can show its success state
    await Future.delayed(kMockAuthLatency);
  }

  @override
  Future<QAuthSession?> refreshSession() async => null;
}