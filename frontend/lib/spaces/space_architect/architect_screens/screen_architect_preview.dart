// frontend/lib/spaces/space_architect/architect_screens/screen_architect_preview.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-25 — Initial. Live preview window with device frame, preset
//                  switcher, orientation toggle, and fully functional app
//                  context (isolated ProviderScope + MaterialApp + BrandScope).
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW THE PREVIEW WORKS:
//   The previewed screen runs inside its own isolated widget tree:
//     ProviderScope (overrides auth → ArchitectMockAuthProvider)
//       → MaterialApp (AppTheme.dark, GoRouter stub)
//         → BrandScope (kBrandDefault)
//           → MediaQuery override (device dimensions)
//             → [Your screen widget here]
//
//   Every button, form, and animation inside the preview is LIVE. GoRouter
//   navigations that push auth routes work via a stub router that re-renders
//   the same previewed screen — so the architect sees the full interaction
//   without the preview closing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/style/app_style.dart';
import '../../../core/auth/auth_config.dart';
import '../../../core/auth/auth_adapters/social/stub_social_provider.dart';
import '../../../core/auth/auth_adapters/biometric/stub_biometric_provider.dart';
import '../../space_auth/auth_state/auth_riverpod.dart';
import '../architect_auth/architect_credentials.dart';
import '../architect_registry/architect_screen_registry.dart';
import '../architect_state/architect_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ─────────────────────────────────────────────────────────────────────
const double _kToolbarHeight     = 52.0;
const double _kDeviceBarHeight   = 44.0;
const double _kDeviceBtnMinWidth = 88.0;
const double _kDeviceBtnHeight   = 32.0;
const double _kDeviceBtnFontSize = 11.5;
const double _kPreviewBgPad      = 32.0;
const double _kFrameBorderWidth  = 1.5;
const double _kFrameRadius       = 12.0;
const double _kFrameShadowBlur   = 40.0;
const double _kScaleMin          = 0.3;
const double _kScaleMax          = 1.0;

// ── Colours ────────────────────────────────────────────────────────────────────
const Color _kPreviewBg  = Color(0xFF0A0A14);
const Color _kFrameColor = Color(0xFF2A2A3A);

// ── Auth config injected into the preview ──────────────────────────────────────
// Must mirror kQSpaceAuthConfig in client_config.dart so the role toggle
// renders exactly as it would in production.
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

// ─────────────────────────────────────────────────────────────────────────────
// ScreenArchitectPreview
// ─────────────────────────────────────────────────────────────────────────────

class ScreenArchitectPreview extends ConsumerStatefulWidget {
  final ArchitectScreenEntry entry;
  const ScreenArchitectPreview({super.key, required this.entry});

  @override
  ConsumerState<ScreenArchitectPreview> createState() =>
      _ScreenArchitectPreviewState();
}

class _ScreenArchitectPreviewState
    extends ConsumerState<ScreenArchitectPreview> {
  bool   _isPortrait  = true;
  double _scaleFactor = 1.0;

  double _computeAutoScale(BoxConstraints constraints, Size deviceSize) {
    final availW = constraints.maxWidth  - _kPreviewBgPad * 2;
    final availH = constraints.maxHeight - _kPreviewBgPad * 2;
    final fitW   = availW / deviceSize.width;
    final fitH   = availH / deviceSize.height;
    return (fitW < fitH ? fitW : fitH).clamp(_kScaleMin, _kScaleMax);
  }

  @override
  Widget build(BuildContext context) {
    final device  = ref.watch(architectPreviewDeviceProvider);
    final rawSize = _isPortrait
        ? device.size
        : Size(device.size.height, device.size.width);

    return Scaffold(
      backgroundColor: _kPreviewBg,
      body: Column(
        children: [
          _PreviewToolbar(
            entry:               widget.entry,
            isPortrait:          _isPortrait,
            scaleFactor:         _scaleFactor,
            onOrientationToggle: () =>
                setState(() => _isPortrait = !_isPortrait),
            onScaleChanged:      (v) => setState(() => _scaleFactor = v),
            onClose:             () => Navigator.of(context).pop(),
          ),
          _DeviceBar(
            current:    device,
            onSelected: (d) {
              ref.read(architectPreviewDeviceProvider.notifier).state = d;
              setState(() => _scaleFactor = 1.0);
            },
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final autoScale      = _computeAutoScale(constraints, rawSize);
                final effectiveScale =
                    (_scaleFactor * autoScale).clamp(_kScaleMin, _kScaleMax);

                return Center(
                  child: _DeviceFrame(
                    width:  rawSize.width  * effectiveScale,
                    height: rawSize.height * effectiveScale,
                    child:  _LiveScreen(
                      entry:  widget.entry,
                      size:   rawSize,
                      device: device,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PreviewToolbar
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewToolbar extends StatelessWidget {
  final ArchitectScreenEntry entry;
  final bool                 isPortrait;
  final double               scaleFactor;
  final VoidCallback         onOrientationToggle;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback         onClose;

  const _PreviewToolbar({
    required this.entry,
    required this.isPortrait,
    required this.scaleFactor,
    required this.onOrientationToggle,
    required this.onScaleChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  _kToolbarHeight,
      color:   AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Tooltip(
            message: 'Close Preview',
            child: IconButton(
              icon:      const Icon(Icons.arrow_back_ios_rounded, size: 16),
              color:     AppColors.textSecondary,
              onPressed: onClose,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: AppTypography.h5.copyWith(fontSize: 13),
                ),
                Text(
                  entry.id,
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          // Zoom control
          Icon(Icons.zoom_out_rounded, size: 14, color: AppColors.textMuted),
          SizedBox(
            width: 110,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
              ),
              child: Slider(
                value:         scaleFactor.clamp(_kScaleMin, _kScaleMax),
                min:           _kScaleMin,
                max:           _kScaleMax,
                divisions:     14,
                activeColor:   AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged:     onScaleChanged,
              ),
            ),
          ),
          Icon(Icons.zoom_in_rounded, size: 14, color: AppColors.textMuted),
          SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: 'Rotate',
            child: IconButton(
              icon: AnimatedRotation(
                turns:    isPortrait ? 0 : 0.25,
                duration: AppDurations.fast,
                child: const Icon(Icons.screen_rotation_rounded, size: 18),
              ),
              color:     AppColors.textSecondary,
              onPressed: onOrientationToggle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeviceBar
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceBar extends StatelessWidget {
  final ArchitectDevice               current;
  final ValueChanged<ArchitectDevice> onSelected;

  const _DeviceBar({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kDeviceBarHeight,
      color:  AppColors.backgroundAlt,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.xs,
        ),
        child: Row(
          children: ArchitectDevice.values.map((d) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _DeviceChip(
              device:     d,
              isSelected: d == current,
              onTap:      () => onSelected(d),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final ArchitectDevice device;
  final bool            isSelected;
  final VoidCallback    onTap;

  const _DeviceChip({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        constraints: const BoxConstraints(
          minWidth:  _kDeviceBtnMinWidth,
          minHeight: _kDeviceBtnHeight,
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient:     isSelected ? AppGradients.button : null,
          color:        isSelected ? null : AppColors.surface,
          borderRadius: AppRadius.pillBR,
          border:       Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                device.label,
                style: AppTypography.badge.copyWith(
                  fontSize:   _kDeviceBtnFontSize,
                  color:      isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              Text(
                '${device.width.toInt()}×${device.height.toInt()}',
                style: AppTypography.caption.copyWith(
                  fontSize: 9,
                  color:    isSelected
                      ? AppColors.onPrimary.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeviceFrame — bezel around the live screen
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceFrame extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _DeviceFrame({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width  + _kFrameBorderWidth * 2,
      height: height + _kFrameBorderWidth * 2,
      decoration: BoxDecoration(
        color:        _kFrameColor,
        borderRadius: BorderRadius.circular(_kFrameRadius),
        border: Border.all(
          color: AppColors.border,
          width: _kFrameBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.55),
            blurRadius: _kFrameShadowBlur,
            offset:     const Offset(0, 16),
          ),
          BoxShadow(
            color:        AppColors.primary.withValues(alpha: 0.08),
            blurRadius:   _kFrameShadowBlur * 1.5,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          _kFrameRadius - _kFrameBorderWidth,
        ),
        child: SizedBox(
          width:  width,
          height: height,
          child:  child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LiveScreen — the isolated app tree that renders the actual screen
// ─────────────────────────────────────────────────────────────────────────────
//
// Built as StatefulWidget so the GoRouter is created once in initState and
// not reconstructed on every parent rebuild — that would cause the preview to
// flash/reset every time the user moves the zoom slider or switches orientation.

class _LiveScreen extends StatefulWidget {
  final ArchitectScreenEntry entry;
  final Size                 size;
  final ArchitectDevice      device;

  const _LiveScreen({
    required this.entry,
    required this.size,
    required this.device,
  });

  @override
  State<_LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<_LiveScreen> {
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
    // All auth routes map back to the preview screen so navigation calls
    // inside the screen don't crash — they just re-render the screen
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) => null,  // no redirects inside preview
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
        // Mock auth provider — auth screens get realistic success responses
        authAdapterProvider.overrideWithValue(ArchitectMockAuthProvider()),
        // Feed the production auth config so the role toggle looks right
        authConfigProvider.overrideWithValue(_kPreviewAuthConfig),
        // Disable social/biometric — avoids plugin crashes during preview
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
            // Override MediaQuery so the screen responds to the selected
            // device dimensions — breakpoints, safe areas, orientation all
            // reflect the actual device being previewed
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