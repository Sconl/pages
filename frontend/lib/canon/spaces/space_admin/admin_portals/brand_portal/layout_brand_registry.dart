// lib/spaces/space_admin/admin_portals/brand_portal/layout_brand_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Ordered section list for the brand portal.
//             ShellBrandRoot renders these in a scrollable column.
// ─────────────────────────────────────────────────────────────────────────────

import '../../admin_model/admin_portal_model.dart';
import 'brand_sections/section_brand_colors.dart';
import 'brand_sections/section_brand_typography.dart';
import 'brand_sections/section_brand_identity.dart';
import 'brand_sections/section_brand_canvas.dart';

// Order here = render order in the scroll view.
final List<AdminSectionEntry> kBrandSections = const [

  AdminSectionEntry(
    id:                 'colors',
    label:              'Color System',
    section:            SectionBrandColors(),
    requiresEditAccess: true,
  ),

  AdminSectionEntry(
    id:                 'typography',
    label:              'Typography Roles',
    section:            SectionBrandTypography(),
    requiresEditAccess: true,
  ),

  AdminSectionEntry(
    id:                 'identity',
    label:              'Brand Identity',
    section:            SectionBrandIdentity(),
    requiresEditAccess: true,
  ),

  AdminSectionEntry(
    id:                 'canvas',
    label:              'Canvas & Motion',
    section:            SectionBrandCanvas(),
    requiresEditAccess: true,
  ),

];