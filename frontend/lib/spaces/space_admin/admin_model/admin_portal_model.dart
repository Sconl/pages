// lib/spaces/space_admin/admin_model/admin_portal_model.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AdminSectionEntry — the data model used by portal-level
//             section registries (layout_*_registry.dart files). Keeps the
//             pattern consistent across every portal.
// ─────────────────────────────────────────────────────────────────────────────
//
// TOP LEVEL vs PORTAL LEVEL:
//   AdminScreenEntry (core/admin/admin_screen_registry.dart)
//     → used by QAdminShell to build the sidebar nav (portals as top-level items)
//   AdminSectionEntry (this file)
//     → used inside each portal shell to build its internal tabs/scroll structure

import 'package:flutter/material.dart';


// ─────────────────────────────────────────────────────────────────────────────
// AdminSectionEntry — one section inside a portal
// ─────────────────────────────────────────────────────────────────────────────
//
// Used by layout_*_registry.dart files inside each portal.
// The portal shell reads its registry and builds tabs or a scroll layout.

@immutable
class AdminSectionEntry {
  /// Machine-readable id — for analytics, keying, etc.
  final String id;

  /// Tab or section heading shown in the portal UI.
  final String label;

  /// Optional icon — used in tabbed portals.
  final IconData? icon;

  /// The widget to render for this section.
  /// The portal shell is responsible for providing the right context/scope.
  final Widget section;

  /// If true, the section is shown but edit controls are disabled.
  /// The portal shell gates this based on QAdminConfigScope.accessFor().editable.
  final bool requiresEditAccess;

  const AdminSectionEntry({
    required this.id,
    required this.label,
    this.icon,
    required this.section,
    this.requiresEditAccess = false,
  });
}