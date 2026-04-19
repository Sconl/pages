// lib/core/nav/nav_item.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QNavItem + QNavGroup — pure data, project agnostic.
//             Replaces NavItem, MarketingNavItem, and any ad-hoc nav data
//             classes. One model serves all three nav surfaces.
// ─────────────────────────────────────────────────────────────────────────────
//
// DESIGN DECISION
// ─────────────────────────────────────────────────────────────────────────────
//   QNavItem is intentionally lean: label, route, icons, badge, semantics.
//   Nothing else. The widgets decide how to render them — the model doesn't
//   know about surfaces, active states, or colours.
//
//   QNavGroup is used by the admin sidebar only (grouped sections with a header
//   label). Public nav surfaces use flat QNavItem lists.
//
//   Badge is a raw string because the caller owns the count logic — null means
//   no badge, "99+" is valid. We don't cap it here.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QNavItem
// ─────────────────────────────────────────────────────────────────────────────

class QNavItem {
  /// Visible label — used in sidebar text, bottom bar labels, mobile menus.
  final String label;

  /// GoRouter route path, e.g. '/home' or '/admin/content'.
  final String route;

  /// Icon shown when the item is NOT active.
  final IconData icon;

  /// Icon shown when the item IS active. Defaults to [icon] when null.
  final IconData? activeIcon;

  /// Optional badge string — '3', '99+', 'NEW'. Null means no badge.
  final String? badge;

  /// Screen-reader override. Falls back to [label] when null.
  final String? semanticLabel;

  /// Tooltip for collapsed sidebar / icon-only contexts.
  /// Falls back to [label] when null.
  final String? tooltip;

  const QNavItem({
    required this.label,
    required this.route,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.semanticLabel,
    this.tooltip,
  });

  /// The icon to show in the active state — falls back to [icon] if no
  /// activeIcon was provided. Saves every call site from null-checking.
  IconData get resolvedActiveIcon => activeIcon ?? icon;

  /// Tooltip text for collapsed contexts — falls back to label.
  String get resolvedTooltip => tooltip ?? label;

  /// Semantic label for accessibility — falls back to label.
  String get resolvedSemanticLabel => semanticLabel ?? label;

  @override
  bool operator ==(Object other) =>
      other is QNavItem && other.route == route;

  @override
  int get hashCode => route.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
// QNavGroup
// ─────────────────────────────────────────────────────────────────────────────
//
// Used by QAdminNav. Groups of items with an optional section header label.
// Public nav surfaces use flat QNavItem lists — groups are admin-only.

class QNavGroup {
  /// Optional group header label. Null → no header rendered.
  final String? header;

  /// Items in this group.
  final List<QNavItem> items;

  const QNavGroup({this.header, required this.items});
}

// ─────────────────────────────────────────────────────────────────────────────
// QNavUserProfile
// ─────────────────────────────────────────────────────────────────────────────
//
// User identity data for the sidebar user tile. The nav shell doesn't know
// about auth providers — whoever wires the shell passes this in.

class QNavUserProfile {
  final String displayName;
  final String? photoUrl;
  final String? roleName; // e.g. 'Member', 'Trainer', 'Admin'

  const QNavUserProfile({
    required this.displayName,
    this.photoUrl,
    this.roleName,
  });

  String get initial =>
      displayName.trim().isNotEmpty ? displayName.trim()[0].toUpperCase() : '?';

  String get firstName => displayName.trim().split(' ').first;
}