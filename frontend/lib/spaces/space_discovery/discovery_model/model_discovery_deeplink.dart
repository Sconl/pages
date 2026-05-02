// frontend/lib/spaces/space_discovery/discovery_model/model_discovery_deeplink.dart

/// Parses incoming deep link URIs into a resolved tenant ID.
///
/// Handles two URI formats:
///   Universal Link:  https://qpages.io/app/{tenantId}
///   URI scheme:      qpages://t/{tenantId}
///
/// Also handles plain text input from the user (manual URL entry):
///   'acme'                         → tenantId: 'acme'
///   'acme.qpages.io'               → tenantId: 'acme'
///   'https://qpages.io/app/acme'   → tenantId: 'acme'
///   'qpages://t/acme'              → tenantId: 'acme'
///   'space.acexoft.com/acme'       → tenantId: 'acme' (Phase 1 support)
class DeepLinkResolver {
  final String universalLinkHost; // 'qpages.io'
  final String universalLinkPath; // '/app'
  final String scheme;            // 'qpages'

  // Phase 1 support: space.acexoft.com/{tenantId}
  static const _phase1Host = 'space.acexoft.com';

  const DeepLinkResolver({
    required this.universalLinkHost,
    required this.universalLinkPath,
    required this.scheme,
  });

  /// Resolves a Uri to a tenantId, or returns null if not recognised.
  /// Used by the app_links stream listener in AppRoot.
  String? resolveUri(Uri uri) {
    // Universal Link: https://qpages.io/app/{tenantId}
    if (uri.scheme == 'https' &&
        uri.host == universalLinkHost &&
        uri.pathSegments.length >= 2 &&
        '/${uri.pathSegments[0]}' == universalLinkPath) {
      return _clean(uri.pathSegments[1]);
    }

    // Phase 1 Universal Link: https://space.acexoft.com/app/{tenantId}
    if (uri.scheme == 'https' &&
        uri.host == _phase1Host &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'app') {
      return _clean(uri.pathSegments[1]);
    }

    // URI scheme: qpages://t/{tenantId}
    if (uri.scheme == scheme &&
        uri.host == 't' &&
        uri.pathSegments.isNotEmpty) {
      return _clean(uri.pathSegments[0]);
    }

    return null;
  }

  /// Resolves a raw string typed by the user into a tenantId.
  /// Returns null if the input cannot be mapped to a tenantId.
  String? resolveInput(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    // Try parsing as URI first
    try {
      final uri = Uri.parse(
        trimmed.startsWith('http') || trimmed.startsWith('qpages://')
            ? trimmed
            : 'https://$trimmed',
      );
      final fromUri = resolveUri(uri);
      if (fromUri != null) return fromUri;

      // {tenantId}.qpages.io → extract subdomain
      if (uri.host.endsWith('.$universalLinkHost')) {
        final subdomain = uri.host.split('.').first;
        return _clean(subdomain);
      }

      // space.acexoft.com/{tenantId} — Phase 1
      if (uri.host == _phase1Host && uri.pathSegments.isNotEmpty) {
        return _clean(uri.pathSegments[0]);
      }
    } catch (_) {
      // Not a valid URI — fall through
    }

    // Bare tenantId: 'acme' (no dots, no slashes, valid identifier)
    final bareId = RegExp(r'^[a-z0-9_-]+$');
    if (bareId.hasMatch(trimmed)) return trimmed;

    return null;
  }

  String? _clean(String id) {
    final cleaned = id.trim().toLowerCase();
    return cleaned.isEmpty ? null : cleaned;
  }
}