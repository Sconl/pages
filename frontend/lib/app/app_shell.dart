// lib/app/app_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QPagesApp root widget.
//             Moved out of main.dart. Uses MaterialApp.router + GoRouter.
//             BrandScope wraps the entire app so all widgets inherit brand tokens.
//   v1.1.0 — Renamed file qpages_app.dart → app_shell.dart.
//             Renamed class QPagesApp → AppShell.
//   v1.2.0 — Converted to ConsumerStatefulWidget to support deep-link lifecycle.
//             Added _initDeepLinks() / _handleDeepLink() via app_links package.
//             GoRouter instance cached as _router for programmatic navigation
//             from _handleDeepLink.
//   v1.2.1 — Fixed: DeepLinkResolver import path corrected to
//               discovery_model/model_discovery_deeplink.dart.
//             Fixed: Added import for state_discovery_providers.dart so
//               pendingTenantIdProvider and discoveryLayoutProvider resolve.
//             Fixed: resolver.resolve() → resolver.resolveUri().
//             Fixed: _resolveInitialLocation() removed (unused — initial
//               location is handled inside routerProvider in app_router.dart).
//             Fixed: _handleDeepLink now sets provider state and navigates
//               to /discovery rather than the removed /discovery/loading route.
//   v1.2.2 — Fixed: added import for app_client_config.dart so
//               mobileConfigProvider resolves. Provider is defined there,
//               not in app_mobile_config.dart.
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the root of the Flutter widget tree, below ProviderScope (app_root.dart).
// It sets up BrandScope, GoRouter, and AppTheme.
// It does NOT know which route is active — GoRouter handles that.
//
// Deep-link flow:
//   Cold start  → appLinks.getInitialLink() fires in initState.
//   Warm open   → appLinks.uriLinkStream fires while app is running.
//   Both paths  → _handleDeepLink() resolves the tenantId, sets
//                 pendingTenantIdProvider + discoveryLayoutProvider to loading,
//                 then navigates to /discovery so ShellDiscoveryRoot shows
//                 the loading template and calls the resolution API.

import 'package:app_links/app_links.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/style/app_style.dart';
import '../core/router/app_router.dart';
import '../core/config/app_client_config.dart';
// import '../core/config/app_mobile_config.dart';
import '../canon/spaces/space_discovery/discovery_model/model_discovery_deeplink.dart';
import '../canon/spaces/space_discovery/discovery_state/state_discovery_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShell
// ─────────────────────────────────────────────────────────────────────────────

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Router is read once here so _handleDeepLink can call _router.go()
    // without going through the widget tree.
    _router = ref.read(routerProvider);
    _initDeepLinks();
  }

  // ── Deep-link lifecycle ──────────────────────────────────────────────────

  void _initDeepLinks() {
    final appLinks = AppLinks();

    // Cold start — app opened via deep link
    appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });

    // Warm open — deep link received while app is already running
    appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    final mobileConfig = ref.read(mobileConfigProvider);
    if (mobileConfig == null) return; // not the mobile app — ignore

    final resolver = DeepLinkResolver(
      universalLinkHost: mobileConfig.universalLinkHost,
      universalLinkPath: mobileConfig.universalLinkPath,
      scheme:            mobileConfig.deepLinkScheme,
    );

    final tenantId = resolver.resolveUri(uri);
    if (tenantId != null) {
      // Set the pending tenant so SectionDiscoveryStatus can resolve it
      ref.read(pendingTenantIdProvider.notifier).state        = tenantId;
      // Switch ShellDiscoveryRoot to the loading template
      ref.read(discoveryLayoutProvider.notifier).state = DiscoveryLayout.loading;
      // Navigate to /discovery — ShellDiscoveryRoot reads discoveryLayoutProvider
      // and renders TemplateDiscoveryLoading automatically
      _router.go('/discovery');
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return BrandScope(
      // kBrandDefault is the platform brand (Deep Violet, Barlow/Niconne).
      // In production, this is replaced by BrandConfig.fromManifest(effectiveManifest)
      // once the MergeEngine (lib/core/merge/merge_engine.dart) is wired (Cycle 1).
      config: kBrandDefault,
      child: MaterialApp.router(
        title:                      BrandCopy.appName,
        debugShowCheckedModeBanner: false,
        theme:                      AppTheme.dark,
        routerConfig:               router,
      ),
    );
  }
}