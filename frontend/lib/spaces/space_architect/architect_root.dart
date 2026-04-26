// frontend/lib/spaces/space_architect/architect_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. Architect root widget with its own ProviderScope,
//                  MaterialApp, and login/dashboard routing logic.
// ─────────────────────────────────────────────────────────────────────────────
//
// ArchitectRoot is completely isolated from AppRoot. It has its own Riverpod
// scope, its own MaterialApp, its own routing — no shared state with the
// production app boot path. This is intentional: the architect system must
// never interfere with what normal users see.
//
// The routing here is trivially simple: if logged in → dashboard, else → login.
// No GoRouter needed. Animated crossfade transitions between the two states.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/style/app_style.dart';
import 'architect_screens/screen_architect_login.dart';
import 'architect_screens/screen_architect_dashboard.dart';
import 'architect_state/architect_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const Duration _kRootTransitionDuration = Duration(milliseconds: 350);
const String   _kAppTitle               = 'QSpace — Architect';

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectRoot
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectRoot extends StatelessWidget {
  const ArchitectRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Own ProviderScope — architect providers are completely separate
    // from the production app providers in AppRoot
    return ProviderScope(
      child: BrandScope(
        config: kBrandDefault,
        child: MaterialApp(
          title:                  _kAppTitle,
          debugShowCheckedModeBanner: false,
          theme:                  AppTheme.dark,
          home:                   const _ArchitectRouter(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ArchitectRouter
// ─────────────────────────────────────────────────────────────────────────────
//
// Watches the login state and swaps between login and dashboard with a smooth
// crossfade. No GoRouter — overkill for a two-state internal tool.

class _ArchitectRouter extends ConsumerWidget {
  const _ArchitectRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(architectIsLoggedInProvider);

    return AnimatedSwitcher(
      duration:        _kRootTransitionDuration,
      switchInCurve:   Curves.easeOut,
      switchOutCurve:  Curves.easeIn,
      transitionBuilder: (child, animation) {
        // Fade + slight upward slide on the incoming screen
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end:   Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity:  animation,
          child:    SlideTransition(position: slide, child: child),
        );
      },
      child: isLoggedIn
          ? const ScreenArchitectDashboard(key: ValueKey('dashboard'))
          : const ScreenArchitectLogin(key: ValueKey('login')),
    );
  }
}