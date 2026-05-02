// frontend/lib/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_status.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_model/model_discovery_session.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_state/state_discovery_providers.dart';

/// The loading state — shown while resolving a tenant from the backend.
/// On mount: calls GET /api/app/resolve/{tenantId}.
/// On success: saves to DiscoverySession, stores overlay URL, navigates.
/// On failure: shows error, switches layout back to home.
class SectionDiscoveryStatus extends ConsumerStatefulWidget {
  const SectionDiscoveryStatus({super.key});

  @override
  ConsumerState<SectionDiscoveryStatus> createState() =>
      _SectionDiscoveryStatusState();
}

class _SectionDiscoveryStatusState
    extends ConsumerState<SectionDiscoveryStatus> {

  @override
  void initState() {
    super.initState();
    // Resolve after first frame — provider state is readable by then
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final tenantId = ref.read(pendingTenantIdProvider);
    if (tenantId == null) {
      _goHome();
      return;
    }

    ref.read(tenantResolvingProvider.notifier).state = true;

    try {
      // TODO: replace with actual API base URL from config
      final response = await Dio().get(
        'http://localhost:3000/api/app/resolve/$tenantId',
      );

      if (response.statusCode == 200) {
        final data        = response.data as Map<String, dynamic>;
        final displayName = data['display_name'] as String? ?? tenantId;
        final overlayUrl  = data['overlay_url']  as String? ?? '';

        // Store resolved data for the merge engine
        ref.read(resolvedTenantNameProvider.notifier).state = displayName;
        ref.read(resolvedOverlayUrlProvider.notifier).state = overlayUrl;

        // Persist this visit to local session
        await DiscoverySession.saveVisit(SavedTenantSpace(
          tenantId:    tenantId,
          displayName: displayName,
          lastVisited: DateTime.now(),
        ));

        // TODO (Cycle 1): Navigate into the tenant experience.
        // This will set the runtime tenantId context and trigger the
        // merge engine to load their overlay.json → BrandConfig.
        // For now: navigate to home (placeholder).
        if (mounted) {
          // Replace with context.go('/') wired to tenant context
        }
      }
    } on DioException catch (e) {
      final message = e.response?.statusCode == 404
          ? 'That space doesn\'t exist. Check the URL.'
          : 'Connection error. Check your internet.';

      if (mounted) {
        ref.read(tenantResolveErrorProvider.notifier).state = message;
        _goHome();
      }
    } finally {
      if (mounted) {
        ref.read(tenantResolvingProvider.notifier).state = false;
      }
    }
  }

  void _goHome() {
    ref.read(pendingTenantIdProvider.notifier).state = null;
    ref.read(discoveryLayoutProvider.notifier).state = DiscoveryLayout.home;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLoader(),
        SizedBox(height: AppSpacing.lg),
        Text('Finding your space…', style: AppTypography.body),
        SizedBox(height: AppSpacing.sm),
        Text(
          ref.watch(pendingTenantIdProvider) ?? '',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}