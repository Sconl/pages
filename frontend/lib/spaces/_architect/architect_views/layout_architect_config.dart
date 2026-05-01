// frontend/lib/spaces/space_architect/architect_views/layout_architect_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-26 — Path corrected: space_architect_views → architect_views.
//   • 2026-04-26 — Initial. Layout config for the architect login view.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectLayoutVariant
// ─────────────────────────────────────────────────────────────────────────────

enum ArchitectLayoutVariant {
  /// Single centred column — the only login variant for now.
  stack,
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectLoginVisibility
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectLoginVisibility {
  final bool header;   // badge → logo → heading → subheading
  final bool form;     // username + password fields
  final bool actions;  // error banner + submit button

  const ArchitectLoginVisibility({
    this.header  = true,
    this.form    = true,
    this.actions = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectLayoutConfig
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectLayoutConfig {
  final ArchitectLayoutVariant   variant;
  final ArchitectLoginVisibility sections;

  const ArchitectLayoutConfig({
    this.variant  = ArchitectLayoutVariant.stack,
    required this.sections,
  });

  static const ArchitectLayoutConfig login = ArchitectLayoutConfig(
    variant:  ArchitectLayoutVariant.stack,
    sections: ArchitectLoginVisibility(),
  );
}