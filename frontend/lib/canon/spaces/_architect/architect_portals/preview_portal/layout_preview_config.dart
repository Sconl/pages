// frontend/lib/spaces/space_architect/architect_portals/preview_portal/layout_preview_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Initial. Layout config for the preview portal.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// PreviewSectionVisibility
// ─────────────────────────────────────────────────────────────────────────────

class PreviewSectionVisibility {
  final bool toolbar;    // back button, screen label, zoom slider, rotate toggle
  final bool deviceBar;  // horizontal device preset selector
  final bool canvas;     // device frame + live screen

  const PreviewSectionVisibility({
    this.toolbar   = true,
    this.deviceBar = true,
    this.canvas    = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PreviewLayoutConfig
// ─────────────────────────────────────────────────────────────────────────────

class PreviewLayoutConfig {
  final PreviewSectionVisibility sections;

  const PreviewLayoutConfig({required this.sections});

  static const PreviewLayoutConfig standard = PreviewLayoutConfig(
    sections: PreviewSectionVisibility(),
  );
}