// frontend/lib/spaces/space_architect/architect_portals/preview_portal/preview_widgets/widget_preview_live_screen.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Isolated app tree that renders the previewed screen
//                  with full production context.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW THIS WORKS:
//   ProviderScope (mock auth + preview auth config)
//     → MaterialApp.router (AppTheme.dark + GoRouter stub)
//       → BrandScope (kBrandDefault)
//         → MediaQuery override (selected device dimensions + safe areas)
//           → [screen widget]
//
// The GoRouter stub maps all auth routes back to the previewed screen so
// navigation calls inside the screen don't crash and the preview stays open.
//
// StatefulWidget so the GoRouter is built once in initState — avoids
// flickering when the parent updates (zoom slider, orientation toggle).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/style/app_style.dart';
import '../../../../../core/auth/auth_config.dart';
import '../../../../../core/auth/auth_adapters/social/stub_social_provider.dart';
import '../../../../../core/auth/auth_adapters/biometric/stub_biometric_provider.dart';
import '../../../../space_auth/auth_state/auth_riverpod.dart';
import '../../../architect_model/architect_credentials.dart';
import '../../../architect_model/architect_screen_registry.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// Auth config injected into the preview — must mirror kQSpaceAuthConfig in
// client_config.dart so the role toggle renders exactly as in production.
// ⚠️  Keep in sync manually when kQSpaceAuthConfig changes.
const QAuthConfig _kPreviewAuthConfig = QAuthConfig(
  tenantId: 'qspace-dev',
  userClasses: [
    AuthUserClass(id: 'user',  label: 'User',      role: QRole.user),
    AuthUserClass(id: 'admin', label: 'Admin',      role: QRole.clientAdmin),
    AuthUserClass(id: 'dev',   label: 'Developer',  role: QRole.developer),
  ],
  showRoleToggle:     true,
  loginHeading:       'Welcome back',
  loginSubheading:    'Sign in to your QSpace account',
  signupHeading:      'Get started',
  signupSubheading:   'Create your QSpace account',
  allowSignup:        true,
  allowPasswordReset: true,
  postLoginRoutes: {
    'user':  '/',
    'admin': '/admin',
    'dev':   '/admin',
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class WidgetPreviewLiveScreen extends StatefulWidget {
  final ArchitectScreenEntry entry;
  final Size                 size;
  final ArchitectDevice      device;

  const WidgetPreviewLiveScreen({
    super.key,
    required this.entry,
    required this.size,
    required this.device,
  });

  @override
  State<WidgetPreviewLiveScreen> createState() => _WidgetPreviewLiveScreenState();
}

class _WidgetPreviewLiveScreenState extends State<WidgetPreviewLiveScreen> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  GoRouter _buildRouter() {
    // All auth routes map back to the previewed screen so context.go() calls
    // inside the screen don't throw "route not found" errors
    return GoRouter(
      initialLocation: '/',
      redirect:        (_, __) => null,   // no redirects inside preview
      routes: [
        GoRoute(path: '/',               builder: (_, __) => widget.entry.builder()),
        GoRoute(path: '/login',          builder: (_, __) => widget.entry.builder()),
        GoRoute(path: '/signup',         builder: (_, __) => widget.entry.builder()),
        GoRoute(path: '/reset-password', builder: (_, __) => widget.entry.builder()),
        GoRoute(path: '/admin',          builder: (_, __) => widget.entry.builder()),
        GoRoute(path: '/admin/overview', builder: (_, __) => widget.entry.builder()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Mock provider — auth screens get working signIn/signUp responses
        authAdapterProvider.overrideWithValue(ArchitectMockAuthProvider()),
        // Production-mirror auth config so the role toggle looks correct
        authConfigProvider.overrideWithValue(_kPreviewAuthConfig),
        // Social + biometric disabled in preview — avoids uninitialized plugin crashes
        socialAuthConfigProvider.overrideWith(
          (ref) => const QSocialAuthConfig(enabled: false),
        ),
        biometricConfigProvider.overrideWith(
          (ref) => const QBiometricConfig(enabled: false),
        ),
        socialAuthAdapterProvider.overrideWith(
          (ref) => const StubSocialProvider(),
        ),
        biometricAuthAdapterProvider.overrideWith(
          (ref) => const StubBiometricProvider(),
        ),
        tenantIdProvider.overrideWithValue('qspace-dev'),
      ],
      child: BrandScope(
        config: kBrandDefault,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme:        AppTheme.dark,
          routerConfig: _router,
          builder: (context, child) {
            // MediaQuery override forces the screen to believe it is running
            // on the selected device — responsive breakpoints, safe areas,
            // and orientation all reflect the previewed device
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size:             widget.size,
                devicePixelRatio: 2.0,
                padding: widget.device.isMobile
                    ? const EdgeInsets.only(top: 44, bottom: 34)
                    : EdgeInsets.zero,
                viewPadding: widget.device.isMobile
                    ? const EdgeInsets.only(top: 44, bottom: 34)
                    : EdgeInsets.zero,
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}