// frontend/lib/spaces/_architect/architect_model/architect_screen_registry.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-04-27 — kArchitectSpaces removed from this file. It now lives in
//                  architect_auto_registry.dart which is assembled from per-space
//                  registration files. This file is types only.
//   • 2026-04-26 — Path corrected: space_architect → _architect.
//   • 2026-04-25 — Initial.
// ─────────────────────────────────────────────────────────────────────────────
//
// Types that every registration file imports. No widgets. No instances.
// Adding a new space: create a registration file, add one line to auto_registry.

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectDevice — responsive preview presets
// ─────────────────────────────────────────────────────────────────────────────

enum ArchitectDevice {
  mobileS( label: 'SE',        icon: Icons.smartphone,      width: 375,  height: 667),
  mobileM( label: 'iPhone 14', icon: Icons.smartphone,      width: 390,  height: 844),
  mobileL( label: 'Plus',      icon: Icons.smartphone,      width: 430,  height: 932),
  tablet(  label: 'iPad',      icon: Icons.tablet,          width: 768,  height: 1024),
  tabletL( label: 'iPad Pro',  icon: Icons.tablet_mac,      width: 1024, height: 1366),
  desktop( label: 'Desktop',   icon: Icons.monitor,         width: 1280, height: 800),
  desktopW(label: 'Wide',      icon: Icons.desktop_windows, width: 1440, height: 900);

  const ArchitectDevice({
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
  });

  final String   label;
  final IconData icon;
  final double   width;
  final double   height;

  Size get size => Size(width, height);

  // Mobile frames get realistic safe-area insets injected in the preview
  bool get isMobile => width < 600;

  // Closest match — given an arbitrary pixel width, which device is it?
  // Used by the drag-resize handle to highlight the matching chip in real time.
  static ArchitectDevice closestTo(double pixelWidth) {
    return ArchitectDevice.values.reduce((a, b) =>
        (a.width - pixelWidth).abs() < (b.width - pixelWidth).abs() ? a : b);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectScreenEntry — one screen registered for preview
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectScreenEntry {
  final String            id;
  final String            label;
  final String            description;
  final Widget Function() builder;
  final ArchitectDevice   defaultDevice;

  const ArchitectScreenEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.builder,
    this.defaultDevice = ArchitectDevice.mobileM,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ArchitectSpace — a group of screens, shown as one sidebar item
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectSpace {
  final String                     id;
  final String                     label;
  final IconData                   icon;
  final Color                      accent;
  final List<ArchitectScreenEntry>  screens;

  const ArchitectSpace({
    required this.id,
    required this.label,
    required this.icon,
    required this.accent,
    required this.screens,
  });
}