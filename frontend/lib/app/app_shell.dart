// lib/interface/app_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QPagesApp root widget.
//             Moved out of main.dart. Uses MaterialApp.router + GoRouter.
//             BrandScope wraps the entire app so all widgets inherit brand tokens.
//   v1.1.0 — Renamed file qpages_app.dart → app_shell.dart.
//             Renamed class QPagesApp → AppShell.
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the root of the Flutter widget tree, below ProviderScope (app_root.dart).
// It sets up BrandScope, GoRouter, and AppTheme.
// It does NOT know which route is active — GoRouter handles that.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/style/app_style.dart';
import '../core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShell
// ─────────────────────────────────────────────────────────────────────────────

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return BrandScope(
      // kBrandDefault is the platform brand (Deep Violet, Barlow/Niconne).
      // In production, this is replaced by BrandConfig.fromManifest(effectiveManifest)
      // once the MergeEngine (lib/shell/merge_engine.dart) is wired (Week 7 Step 7).
      config: kBrandDefault,
      child: MaterialApp.router(
        title:                  BrandCopy.appName,
        debugShowCheckedModeBanner: false,
        theme:                  AppTheme.dark,
        routerConfig:           router,
      ),
    );
  }
}