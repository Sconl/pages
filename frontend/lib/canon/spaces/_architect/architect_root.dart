// frontend/lib/spaces/space_architect/architect_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Refactored. Now delegates login to ShellArchitectRoot and
//                  dashboard to ShellDashboardRoot — no inline widget trees.
//   • 2026-04-25 — Initial. Architect root with isolated ProviderScope.
// ─────────────────────────────────────────────────────────────────────────────
//
// ArchitectRoot is completely isolated from AppRoot:
//   • Its own ProviderScope — no shared providers with the production app
//   • Its own MaterialApp — independent theme, title, and routing
//   • Its own AnimatedSwitcher routing — login ↔ dashboard
//
// This is intentional: the architect system must never interfere with what
// normal users experience, and its providers must not leak into production.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/style/app_style.dart';
import 'architect_state/architect_riverpod.dart';
import 'architect_views/shell_architect_root.dart';
import 'architect_portals/dashboard_portal/shell_dashboard_root.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const Duration _kTransitionDuration = Duration(milliseconds: 350);
const String   _kAppTitle           = 'QSpace — Architect';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectRoot extends StatelessWidget {
  const ArchitectRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Fully isolated ProviderScope — architect providers never leak into AppRoot
    return ProviderScope(
      child: BrandScope(
        config: kBrandDefault,
        child: MaterialApp(
          title:                     _kAppTitle,
          debugShowCheckedModeBanner: false,
          theme:                     AppTheme.dark,
          home:                      const _ArchitectRouter(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ArchitectRouter — login ↔ dashboard AnimatedSwitcher
// ─────────────────────────────────────────────────────────────────────────────

class _ArchitectRouter extends ConsumerWidget {
  const _ArchitectRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(architectIsLoggedInProvider);

    return AnimatedSwitcher(
      duration:       _kTransitionDuration,
      switchInCurve:  Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end:   Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return FadeTransition(
          opacity: animation,
          child:   SlideTransition(position: slide, child: child),
        );
      },
      child: isLoggedIn
          ? const ShellDashboardRoot(key: ValueKey('dashboard'))
          : const ShellArchitectRoot(key: ValueKey('login')),
    );
  }
}