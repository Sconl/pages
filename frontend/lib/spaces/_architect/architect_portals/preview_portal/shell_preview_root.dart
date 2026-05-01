// frontend/lib/spaces/space_architect/architect_portals/preview_portal/shell_preview_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Preview portal shell — owns orientation and zoom
//                  state, delegates rendering to sections.
// ─────────────────────────────────────────────────────────────────────────────
//
// SCRTSC: Shell → Config → (Registry) → (Template) → Sections → Widgets.
//
// The preview has a fixed vertical layout (toolbar → device bar → canvas) so
// no swappable template is needed. Config still controls section visibility.
// All mutable state (orientation, zoom) lives here — sections are stateless.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/style/app_style.dart';
import '../../architect_model/architect_screen_registry.dart';
import '../../architect_state/architect_riverpod.dart';
import 'layout_preview_config.dart';
import 'preview_sections/section_preview_toolbar.dart';
import 'preview_sections/section_preview_device_bar.dart';
import 'preview_sections/section_preview_canvas.dart';

class ShellPreviewRoot extends ConsumerStatefulWidget {
  final ArchitectScreenEntry entry;
  const ShellPreviewRoot({super.key, required this.entry});

  @override
  ConsumerState<ShellPreviewRoot> createState() => _ShellPreviewRootState();
}

class _ShellPreviewRootState extends ConsumerState<ShellPreviewRoot> {
  // ── Local state owned by the shell ──────────────────────────────────────────
  bool   _isPortrait  = true;
  double _scaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    // Config — visibility switches for sections
    const config = PreviewLayoutConfig.standard;
    final vis    = config.sections;

    final device = ref.watch(architectPreviewDeviceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Column(
        children: [
          // Toolbar
          if (vis.toolbar)
            SectionPreviewToolbar(
              entry:               widget.entry,
              isPortrait:          _isPortrait,
              scaleFactor:         _scaleFactor,
              onOrientationToggle: () =>
                  setState(() => _isPortrait = !_isPortrait),
              onScaleChanged:      (v) => setState(() => _scaleFactor = v),
              onClose:             () => Navigator.of(context).pop(),
            ),

          // Device bar
          if (vis.deviceBar)
            SectionPreviewDeviceBar(
              current:    device,
              onSelected: (d) {
                ref.read(architectPreviewDeviceProvider.notifier).state = d;
                // Reset zoom on device switch so the new frame always fits
                setState(() => _scaleFactor = 1.0);
              },
            ),

          // Canvas
          if (vis.canvas)
            Expanded(
              child: SectionPreviewCanvas(
                entry:       widget.entry,
                device:      device,
                isPortrait:  _isPortrait,
                scaleFactor: _scaleFactor,
              ),
            ),
        ],
      ),
    );
  }
}