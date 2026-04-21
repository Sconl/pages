// lib/core/auth/auth_adapters/social/stub_social_provider.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Default no-op. Used when social auth is not configured.
//             isConfigured = false → UI hides all social buttons.
// ─────────────────────────────────────────────────────────────────────────────

import '../../social_auth_port.dart';
import '../../auth_session.dart';

class StubSocialProvider implements SocialAuthPort {
  const StubSocialProvider();

  @override
  Future<QAuthSession> signInWith({
    required SocialAuthProvider provider,
    required String tenantId,
  }) async {
    throw UnimplementedError(
      'Social auth is not configured.\n'
      'Pass a concrete SocialAuthPort in AppClientConfig.socialAdapter.\n'
      'See lib/core/auth/auth_adapters/social/ for available implementations.',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  bool get isConfigured => false;
}