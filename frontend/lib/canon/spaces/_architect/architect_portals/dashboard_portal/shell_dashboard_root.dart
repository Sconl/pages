// frontend/lib/spaces/_architect/architect_portals/dashboard_portal/shell_dashboard_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Import changed to architect_auto_registry so the sidebar
//                  and grid use the assembled kArchitectSpaces list.
//   • 2026-04-26 — Initial. Dashboard portal shell.
// ─────────────────────────────────────────────────────────────────────────────
//
// SCRTSC: Shell → Config → Registry → Sections → Widgets.
// Two-column fixed layout: sidebar (collapsible) | grid.
// All navigation to the preview portal is initiated here.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/style/app_style.dart';
import '../../architect_model/architect_auto_registry.dart';
import '../../architect_model/architect_screen_registry.dart';
import '../../architect_state/architect_riverpod.dart';
import 'layout_dashboard_config.dart';
import 'layout_dashboard_registry.dart';
import 'dashboard_sections/section_dashboard_sidebar.dart';
import 'dashboard_sections/section_dashboard_grid.dart';
import '../preview_portal/shell_preview_root.dart';

class ShellDashboardRoot extends ConsumerWidget {
  const ShellDashboardRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const config = DashboardLayoutConfig.standard;
    final vis    = config.sections;

    final selectedSpaceId = ref.watch(architectSelectedSpaceProvider);
    final selectedSpace   = kArchitectSpaces.firstWhere(
      (s) => s.id == selectedSpaceId,
      orElse: () => kArchitectSpaces.first,
    );

    final sections = DashboardPortalSections(
      sidebar: vis.sidebar
          ? SectionDashboardSidebar(
              spaces:          kArchitectSpaces,
              selectedSpaceId: selectedSpaceId,
              onSpaceSelected: (id) =>
                  ref.read(architectSelectedSpaceProvider.notifier).state = id,
              onLogout: () =>
                  ref.read(architectIsLoggedInProvider.notifier).state = false,
            )
          : null,
      grid: vis.grid
          ? SectionDashboardGrid(
              space:  selectedSpace,
              onOpen: (entry) => _openPreview(context, ref, entry),
            )
          : null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (sections.sidebar != null) ...[
            sections.sidebar!,
            Container(width: 1, color: AppColors.border),
          ],
          if (sections.grid != null)
            Expanded(child: sections.grid!),
        ],
      ),
    );
  }

  void _openPreview(
    BuildContext context,
    WidgetRef ref,
    ArchitectScreenEntry entry,
  ) {
    ref.read(architectPreviewDeviceProvider.notifier).state = entry.defaultDevice;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ShellPreviewRoot(entry: entry),
        transitionDuration:        AppDurations.normal,
        reverseTransitionDuration: AppDurations.normal,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return FadeTransition(
            opacity: curved,
            child:   SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end:   Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}