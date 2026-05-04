// lib/spaces/space_discovery/discovery_views/discovery_sections/section_discovery_search.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. URL input + Go + Scan QR buttons.
//   v1.0.1 — Fixed: added missing import for app_mobile_config.dart.
//             mobileConfigProvider was undefined because the import was absent.
//   v1.0.2 — Fixed: mobileConfigProvider is defined in app_client_config.dart,
//             not app_mobile_config.dart. Added import for app_client_config.dart.
//             app_mobile_config.dart kept for AppMobileConfig type reference
//             via DeepLinkResolver constructor args.
// ─────────────────────────────────────────────────────────────────────────────
//
// URL input field + Go button + Scan QR button.
// Parses raw text input via DeepLinkResolver.resolveInput().
// On valid input → sets pendingTenantIdProvider + switches layout to loading.
// On invalid input → sets tenantResolveErrorProvider with a user-friendly message.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qspace_pages/core/config/app_client_config.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/canon/spaces/space_discovery/discovery_model/model_discovery_deeplink.dart';
import 'package:qspace_pages/canon/spaces/space_discovery/discovery_state/state_discovery_providers.dart';
import '../discovery_widgets/widget_discovery_input.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SectionDiscoverySearch
// ─────────────────────────────────────────────────────────────────────────────

class SectionDiscoverySearch extends ConsumerStatefulWidget {
  const SectionDiscoverySearch({super.key});

  @override
  ConsumerState<SectionDiscoverySearch> createState() =>
      _SectionDiscoverySearchState();
}

class _SectionDiscoverySearchState
    extends ConsumerState<SectionDiscoverySearch> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(tenantResolveErrorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WidgetDiscoveryInput(
          controller: _controller,
          errorText:  error,
          onSubmitted: (_) => _resolve(),
        ),

        SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _resolve,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text('Go', style: AppTypography.button),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text('Scan QR', style: AppTypography.button),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical:   AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _resolve() {
    final mobileConfig = ref.read(mobileConfigProvider);
    if (mobileConfig == null) return;

    final input = _controller.text.trim();
    if (input.isEmpty) return;

    // Clear any previous error before attempting resolution
    ref.read(tenantResolveErrorProvider.notifier).state = null;

    final resolver = DeepLinkResolver(
      universalLinkHost: mobileConfig.universalLinkHost,
      universalLinkPath: mobileConfig.universalLinkPath,
      scheme:            mobileConfig.deepLinkScheme,
    );

    final tenantId = resolver.resolveInput(input);

    if (tenantId == null) {
      ref.read(tenantResolveErrorProvider.notifier).state =
          'Could not recognise that URL. Try: yourorg.qpages.io';
      return;
    }

    ref.read(pendingTenantIdProvider.notifier).state        = tenantId;
    ref.read(discoveryLayoutProvider.notifier).state = DiscoveryLayout.loading;
  }

  void _openScanner() {
    ref.read(discoveryLayoutProvider.notifier).state = DiscoveryLayout.scan;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}