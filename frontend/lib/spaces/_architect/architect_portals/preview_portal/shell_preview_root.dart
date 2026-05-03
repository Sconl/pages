// frontend/lib/spaces/_architect/architect_portals/preview_portal/shell_preview_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Added customWidth state for drag-resize. Wires closestDevice
//                  to the device bar so the matching chip highlights in real
//                  time. Added SectionPreviewInfoStrip between device bar and
//                  canvas. Zoom slider reset on device switch preserved.
//   • 2026-04-26 — Initial. Preview portal shell.
// ─────────────────────────────────────────────────────────────────────────────
//
// SCRTSC: Shell → Config → Sections → Widgets.
// All mutable state lives here. Every section is stateless.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../core/style/app_style.dart';
import '../../architect_model/architect_screen_registry.dart';
import '../../architect_state/architect_riverpod.dart';
import 'layout_preview_config.dart';
import 'preview_sections/section_preview_toolbar.dart';
import 'preview_sections/section_preview_device_bar.dart';
import 'preview_sections/section_preview_info_strip.dart';
import 'preview_sections/section_preview_canvas.dart';

class ShellPreviewRoot extends ConsumerStatefulWidget {
  final ArchitectScreenEntry entry;
  const ShellPreviewRoot({super.key, required this.entry});

  @override
  ConsumerState<ShellPreviewRoot> createState() => _ShellPreviewRootState();
}

class _ShellPreviewRootState extends ConsumerState<ShellPreviewRoot> {
  // ── State ──────────────────────────────────────────────────────────────────
  bool   _isPortrait   = true;
  double _scaleFactor  = 1.0;
  // customWidth is null when using device preset, non-null after drag-resize
  double? _customWidth;
  // Tracks the current logical width so the info strip stays in sync
  // without needing to re-read from canvas internals
  late double _currentDisplayWidth;

  @override
  void initState() {
    super.initState();
    final device = ref.read(architectPreviewDeviceProvider);
    _currentDisplayWidth = device.width;
  }

  // Called by the canvas on every drag delta and on device switch
  void _onWidthChanged(double w) {
    if (_currentDisplayWidth != w) {
      setState(() {
        _currentDisplayWidth = w;
        _customWidth         = w;
      });
    }
  }

  // Called when a chip in the device bar is tapped — clears custom width
  void _onDeviceSelected(ArchitectDevice d) {
    ref.read(architectPreviewDeviceProvider.notifier).state = d;
    setState(() {
      _scaleFactor         = 1.0;
      _customWidth         = null;
      _currentDisplayWidth = _isPortrait ? d.width : d.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    const config = PreviewLayoutConfig.standard;
    final vis    = config.sections;
    final device = ref.watch(architectPreviewDeviceProvider);

    // The logical height always comes from the preset — only width is adjustable
    final displayHeight = _isPortrait ? device.height : device.width;

    // Which device chip to highlight as "closest" — drives real-time feedback
    // while the architect drags the resize handle
    final closest = ArchitectDevice.closestTo(_currentDisplayWidth);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Column(
        children: [
          // ── Toolbar ────────────────────────────────────────────────────────
          if (vis.toolbar)
            SectionPreviewToolbar(
              entry:               widget.entry,
              isPortrait:          _isPortrait,
              scaleFactor:         _scaleFactor,
              onOrientationToggle: () {
                setState(() {
                  _isPortrait          = !_isPortrait;
                  _customWidth         = null;
                  _currentDisplayWidth = _isPortrait ? device.width : device.height;
                });
              },
              onScaleChanged: (v) => setState(() => _scaleFactor = v),
              onClose:        () => Navigator.of(context).pop(),
            ),

          // ── Device chip bar ────────────────────────────────────────────────
          if (vis.deviceBar)
            SectionPreviewDeviceBar(
              current:       device,
              closestDevice: closest,
              onSelected:    _onDeviceSelected,
            ),

          // ── Info strip ─────────────────────────────────────────────────────
          SectionPreviewInfoStrip(
            displayWidth:  _currentDisplayWidth,
            displayHeight: displayHeight,
            closestDevice: closest,
            isPortrait:    _isPortrait,
            scaleFactor:   _scaleFactor,
          ),

          // ── Canvas ─────────────────────────────────────────────────────────
          if (vis.canvas)
            Expanded(
              child: SectionPreviewCanvas(
                entry:          widget.entry,
                device:         device,
                isPortrait:     _isPortrait,
                scaleFactor:    _scaleFactor,
                customWidth:    _customWidth,
                onWidthChanged: _onWidthChanged,
              ),
            ),
        ],
      ),
    );
  }
}