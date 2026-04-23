// lib/spaces/space_admin/admin_portals/features_portal/layout_features_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Ordered section list for the features portal.
// ─────────────────────────────────────────────────────────────────────────────

import '../../../../spaces/space_admin/admin_model/admin_portal_model.dart';
import 'features_sections/section_features_dev_screen.dart';
import 'features_sections/section_features_flags.dart';

final List<AdminSectionEntry> kFeaturesSections = const [

  AdminSectionEntry(
    id:      'dev_screen',
    label:   'Dev Screen Controls',
    section: SectionFeaturesDevScreen(),
  ),

  AdminSectionEntry(
    id:      'feature_flags',
    label:   'Feature Flags',
    section: SectionFeaturesFlags(),
  ),

];