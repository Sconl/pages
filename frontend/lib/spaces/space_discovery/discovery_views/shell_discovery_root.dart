// lib/spaces/space_discovery/discovery_views/shell_discovery_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Orchestrator for space_discovery.
//   v1.0.1 — Fixed: added missing import for app_mobile_config.dart.
//             mobileConfigProvider was undefined because the import was absent.
//             Fixed: added import for state_discovery_providers.dart so
//             discoveryLayoutProvider and DiscoveryLayout resolve.
//   v1.0.2 — Fixed: mobileConfigProvider is defined in app_client_config.dart,
//             not app_mobile_config.dart. Added import for app_client_config.dart.
//             app_mobile_config.dart kept for AppMobileConfig type used
//             by DeepLinkResolver constructor.
// ─────────────────────────────────────────────────────────────────────────────
//
// ShellDiscoveryRoot is the orchestrator of space_discovery.
//
// Responsibilities:
//   1. Listens for warm-open deep links via app_links (cold-start is in AppShell)
//   2. Reads discoveryLayoutProvider to determine which template to show
//   3. Delegates template selection to LayoutDiscoveryRegistry
//   4. Wraps everything in a Scaffold with the platform background colour
//
// It does NOT build section content directly.
// It does NOT contain business logic — that stays in discovery_state/.

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qspace_pages/core/config/app_client_config.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_model/model_discovery_deeplink.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_state/state_discovery_providers.dart';
import 'layout_discovery_config.dart';
import 'layout_discovery_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShellDiscoveryRoot
// ─────────────────────────────────────────────────────────────────────────────

class ShellDiscoveryRoot extends ConsumerStatefulWidget {
  const ShellDiscoveryRoot({super.key});

  @override
  ConsumerState<ShellDiscoveryRoot> createState() => _ShellDiscoveryRootState();
}

class _ShellDiscoveryRootState extends ConsumerState<ShellDiscoveryRoot> {

  @override
  void initState() {
    super.initState();
    _listenForDeepLinks();

    // If a tenantId was set before this shell mounted (e.g. from a cold-start
    // deep link handled by AppShell before navigation landed here), make sure
    // the layout is in loading state so SectionDiscoveryStatus fires immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = ref.read(pendingTenantIdProvider);
      if (pending != null &&
          ref.read(discoveryLayoutProvider) != DiscoveryLayout.loading) {
        ref.read(discoveryLayoutProvider.notifier).state = DiscoveryLayout.loading;
      }
    });
  }

  // Warm-open deep links only — cold-start is handled in AppShell._initDeepLinks().
  // ShellDiscoveryRoot may not yet be in the tree when a cold-start deep link
  // arrives, so AppShell owns that responsibility.
  void _listenForDeepLinks() {
    final mobileConfig = ref.read(mobileConfigProvider);
    if (mobileConfig == null) return; // web build — no deep links

    final resolver = DeepLinkResolver(
      universalLinkHost: mobileConfig.universalLinkHost,
      universalLinkPath: mobileConfig.universalLinkPath,
      scheme:            mobileConfig.deepLinkScheme,
    );

    AppLinks().uriLinkStream.listen((uri) {
      final tenantId = resolver.resolveUri(uri);
      if (tenantId != null && mounted) {
        ref.read(pendingTenantIdProvider.notifier).state        = tenantId;
        ref.read(discoveryLayoutProvider.notifier).state = DiscoveryLayout.loading;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(discoveryLayoutProvider);
    final config = LayoutDiscoveryConfig(activeLayout: layout);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutDiscoveryRegistry.buildFor(config.activeLayout),
      ),
    );
  }
}