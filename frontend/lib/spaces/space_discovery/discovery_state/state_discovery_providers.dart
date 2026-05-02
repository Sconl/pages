// frontend/lib/spaces/space_discovery/discovery_state/state_discovery_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_model/model_discovery_session.dart';

// ─── Discovery layout state ────────────────────────────────────────────────

/// Which discovery layout is currently active.
/// shell_discovery_root reads this to select the correct template.
enum DiscoveryLayout { home, scan, loading }

final discoveryLayoutProvider =
    StateProvider<DiscoveryLayout>((ref) => DiscoveryLayout.home);

// ─── Tenant resolution state ───────────────────────────────────────────────

/// The tenant ID currently being resolved.
/// Set from DeepLinkResolver output, QR scan result, or manual input.
/// Null = no pending navigation.
final pendingTenantIdProvider = StateProvider<String?>((ref) => null);

/// True while GET /api/app/resolve/{tenantId} is in flight.
final tenantResolvingProvider = StateProvider<bool>((ref) => false);

/// Error from the last failed resolution attempt. Null = no error.
final tenantResolveErrorProvider = StateProvider<String?>((ref) => null);

// ─── Recent spaces ─────────────────────────────────────────────────────────

/// Recently visited tenant spaces loaded from DiscoverySession (SharedPreferences).
final recentSpacesProvider = FutureProvider<List<SavedTenantSpace>>((ref) async {
  return DiscoverySession.getRecent();
});

// ─── Resolved tenant data (from /api/app/resolve) ─────────────────────────

/// The display name returned by the backend after successful resolution.
/// Populated in section_discovery_status during the loading flow.
/// Used to update DiscoverySession after a successful visit.
final resolvedTenantNameProvider = StateProvider<String?>((ref) => null);

/// The overlay.json URL returned by the backend after successful resolution.
/// Handed off to the merge engine after discovery completes.
final resolvedOverlayUrlProvider = StateProvider<String?>((ref) => null);