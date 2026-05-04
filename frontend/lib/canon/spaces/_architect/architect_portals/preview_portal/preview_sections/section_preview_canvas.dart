// frontend/lib/spaces/_architect/architect_portals/preview_portal/preview_sections/section_preview_canvas.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — Added draggable width handle. customWidth overrides the
//                  device preset width when non-null. Drag left/right to resize
//                  the preview in real time. Double-tap handle to reset to the
//                  preset width. onWidthChanged callback reports the current
//                  width to the shell so the info strip stays in sync.
//   • 2026-04-26 — Initial. Auto-scale + device frame + live screen.
// ─────────────────────────────────────────────────────────────────────────────
//
// Layout:
//   [dark canvas background]
//     → Center(
//         [horizontal resize container]
//           ← [left drag handle]  [device frame + live screen]  [right drag handle] →
//       )
//
// Drag mechanics:
//   GestureDetector.onHorizontalDragUpdate on each handle adjusts a local
//   _currentWidth clamp(minWidth, maxWidth). The frame re-renders every frame.
//   Auto-scale is applied on top so the frame always fits the canvas at any
//   custom width — the architect is scaling the device's logical viewport, not
//   the rendered pixels.

import 'package:flutter/material.dart';

import '../../../../../../core/style/app_style.dart';
import '../../../architect_model/architect_screen_registry.dart';
import '../preview_widgets/widget_preview_device_frame.dart';
import '../preview_widgets/widget_preview_live_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change values here, not inside widgets
// ─────────────────────────────────────────────────────────────────────────────

const double _kCanvasPad    = 40.0;   // breathing room around the device frame
const double _kScaleMin     = 0.3;
const double _kScaleMax     = 1.0;
const Color  _kCanvasBg     = Color(0xFF0A0A14);

// ── Drag handle ───────────────────────────────────────────────────────────────
const double _kHandleWidth       = 16.0;   // invisible hit area
const double _kHandleBarWidth    = 3.0;    // visible pill
const double _kHandleBarHeight   = 40.0;
const double _kHandleBarRadius   = 3.0;
const double _kMinPreviewWidth   = 280.0;  // narrowest allowed resize
const double _kMaxPreviewWidth   = 1600.0; // widest allowed resize

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class SectionPreviewCanvas extends StatefulWidget {
  final ArchitectScreenEntry entry;
  final ArchitectDevice      device;
  final bool                 isPortrait;
  final double               scaleFactor;

  // Called whenever the logical width changes (drag or device switch).
  // Shell uses this to keep the info strip in sync.
  final ValueChanged<double> onWidthChanged;

  // Null = use device preset. Non-null = custom drag width.
  final double? customWidth;

  const SectionPreviewCanvas({
    super.key,
    required this.entry,
    required this.device,
    required this.isPortrait,
    required this.scaleFactor,
    required this.onWidthChanged,
    this.customWidth,
  });

  @override
  State<SectionPreviewCanvas> createState() => _SectionPreviewCanvasState();
}

class _SectionPreviewCanvasState extends State<SectionPreviewCanvas> {
  // Internal drag state — mirrors widget.customWidth on first build, then
  // tracks locally so drag updates are silky smooth without waiting for
  // setState to propagate up and back down
  double? _dragWidth;

  double get _logicalWidth {
    if (_dragWidth != null) return _dragWidth!;
    if (widget.customWidth != null) return widget.customWidth!;
    return widget.isPortrait
        ? widget.device.width
        : widget.device.height;
  }

  double get _logicalHeight {
    return widget.isPortrait
        ? widget.device.height
        : widget.device.width;
  }

  Size get _rawSize => Size(_logicalWidth, _logicalHeight);

  double _computeAutoScale(BoxConstraints constraints) {
    final availW = constraints.maxWidth  - _kCanvasPad * 2 - _kHandleWidth * 2;
    final availH = constraints.maxHeight - _kCanvasPad * 2;
    final fitW   = availW / _rawSize.width;
    final fitH   = availH / _rawSize.height;
    return (fitW < fitH ? fitW : fitH).clamp(_kScaleMin, _kScaleMax);
  }

  void _onDrag(double delta) {
    // Each handle drags one edge: left handle moves left = wider, right = narrower.
    // We expose a single _onDrag(delta) and negate for the left handle at call site.
    final current = _dragWidth ?? _logicalWidth;
    final next    = (current + delta).clamp(_kMinPreviewWidth, _kMaxPreviewWidth);
    setState(() => _dragWidth = next);
    widget.onWidthChanged(next);
  }

  void _resetDrag() {
    final preset = widget.isPortrait ? widget.device.width : widget.device.height;
    setState(() => _dragWidth = null);
    widget.onWidthChanged(preset);
  }

  @override
  void didUpdateWidget(SectionPreviewCanvas old) {
    super.didUpdateWidget(old);
    // When the device preset is switched via a chip tap, clear any drag override
    // so the frame snaps to the new preset
    if (old.device != widget.device || old.isPortrait != widget.isPortrait) {
      _dragWidth = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kCanvasBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final auto      = _computeAutoScale(constraints);
          final effective = (widget.scaleFactor * auto).clamp(_kScaleMin, _kScaleMax);
          final scaledW   = _rawSize.width  * effective;
          final scaledH   = _rawSize.height * effective;

          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left drag handle
                _ResizeHandle(
                  isLeft:    true,
                  onDrag:    (d) => _onDrag(-d),   // left handle: drag right = narrower
                  onReset:   _resetDrag,
                ),

                // Device frame
                WidgetPreviewDeviceFrame(
                  width:  scaledW,
                  height: scaledH,
                  child:  WidgetPreviewLiveScreen(
                    entry:  widget.entry,
                    size:   _rawSize,
                    device: widget.device,
                  ),
                ),

                // Right drag handle
                _ResizeHandle(
                  isLeft:    false,
                  onDrag:    (d) => _onDrag(d),    // right handle: drag right = wider
                  onReset:   _resetDrag,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ResizeHandle — invisible hit area + visible pill bar
// ─────────────────────────────────────────────────────────────────────────────

class _ResizeHandle extends StatefulWidget {
  final bool             isLeft;
  final ValueChanged<double> onDrag;
  final VoidCallback     onReset;

  const _ResizeHandle({
    required this.isLeft,
    required this.onDrag,
    required this.onReset,
  });

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _hovered  = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _hovered || _dragging;

    return MouseRegion(
      cursor:  SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onHorizontalDragStart:  (_) => setState(() => _dragging = true),
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        onHorizontalDragEnd:    (_) => setState(() => _dragging = false),
        onDoubleTap:            widget.onReset,
        child: SizedBox(
          width:  _kHandleWidth,
          height: double.infinity,
          child: Center(
            child: Tooltip(
              message: 'Drag to resize  •  Double-tap to reset',
              child: AnimatedContainer(
                duration: AppDurations.fast,
                width:  _kHandleBarWidth,
                height: _kHandleBarHeight,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(_kHandleBarRadius),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:      AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}