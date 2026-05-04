// lib/spaces/space_admin/admin_portals/brand_portal/layout_brand_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. All tunable layout, copy, and UX constants for the brand portal.
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double kBrandPagePad      = 32.0;
const double kBrandMaxWidth     = 920.0;
const double kBrandSectionGap   = 36.0;
const double kBrandActionBtnH   = 48.0;

// ── Copy ──────────────────────────────────────────────────────────────────────
const String kBrandTitle    = 'Brand';
const String kBrandSubtitle =
    'Edit and preview brand tokens. Changes are drafts until you generate the config snippet.';
const String kBrandEditNote =
    'Changes are saved as a draft. Use "Preview" to see them applied, '
    '"Generate Snippet" to export the brand_config.dart CONFIG BLOCK, '
    'and "Discard" to revert to the last published state.';
const String kBrandUnsavedMsg =
    'Unsaved changes — preview before generating the config snippet.';