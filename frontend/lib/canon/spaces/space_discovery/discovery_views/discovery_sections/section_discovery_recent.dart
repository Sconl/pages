// lib/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_recent.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. List of recently visited tenant spaces.
//   v1.0.1 — Fixed: unnecessary_underscores lint — (_, __) → (_, _) in
//             recentSpacesProvider.when(error:) callback.
//             Note: widget_discovery_space_tile.dart must exist alongside
//             this file for the import to resolve. Created in same batch.
// ─────────────────────────────────────────────────────────────────────────────
//
// Shows a list of recently visited tenant spaces loaded from DiscoverySession.
// Hidden entirely when the list is empty — no empty-state UI here.
// Each row is a WidgetDiscoverySpaceTile that taps to navigate to that tenant.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/canon/spaces/space_discovery/discovery_state/state_discovery_providers.dart';
import '../discovery_widgets/widget_discovery_space_tile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SectionDiscoveryRecent
// ─────────────────────────────────────────────────────────────────────────────

class SectionDiscoveryRecent extends ConsumerWidget {
  const SectionDiscoveryRecent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSpacesProvider);

    return recentAsync.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, _) => const SizedBox.shrink(), // was (_, __) — lint fixed
      data:    (spaces) {
        if (spaces.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent', style: AppTypography.overline),
            SizedBox(height: AppSpacing.sm),
            ...spaces.map(
              (space) => WidgetDiscoverySpaceTile(
                space: space,
                onTap: () {
                  ref.read(pendingTenantIdProvider.notifier).state  = space.tenantId;
                  ref.read(discoveryLayoutProvider.notifier).state  = DiscoveryLayout.loading;
                },
              ),
            ),
          ],
        );
      },
    );
  }
}