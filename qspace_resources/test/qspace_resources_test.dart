// qspace_resources/test/qspace_resources_test.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG (newest first)
// ─────────────────────────────────────────────────────────────────────────────
//   • 2026-05-03 — Updated class references: *Logos → *Logo (singular).
//                  Group names updated to match.
//   • 2026-05-03 — Replaced stale Calculator boilerplate with logo registry
//                  smoke tests. Validates path format and nullability contracts
//                  for all three QSpace systems.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';

import 'package:qspace_resources/qspace_resources.dart';

void main() {
  // ── QSpace Pages logo (assets exist — all three must be non-empty strings) ──

  group('QSpacePagesLogo', () {
    test('horizontal path is defined and non-empty', () {
      expect(QSpacePagesLogo.horizontal, isNotEmpty);
    });

    test('vertical path is defined and non-empty', () {
      expect(QSpacePagesLogo.vertical, isNotEmpty);
    });

    test('icon path is defined and non-empty', () {
      expect(QSpacePagesLogo.icon, isNotEmpty);
    });

    test('all paths reference the qspace_resources package', () {
      const prefix = 'packages/qspace_resources/';
      expect(QSpacePagesLogo.horizontal, startsWith(prefix));
      expect(QSpacePagesLogo.vertical,   startsWith(prefix));
      expect(QSpacePagesLogo.icon,       startsWith(prefix));
    });

    test('all paths target SVG files', () {
      expect(QSpacePagesLogo.horizontal, endsWith('.svg'));
      expect(QSpacePagesLogo.vertical,   endsWith('.svg'));
      expect(QSpacePagesLogo.icon,       endsWith('.svg'));
    });
  });

  // ── QSpace Pay logo (pending — must be null until assets are added) ──────────

  group('QSpacePayLogo', () {
    test('horizontal is null until asset is created', () {
      expect(QSpacePayLogo.horizontal, isNull);
    });

    test('vertical is null until asset is created', () {
      expect(QSpacePayLogo.vertical, isNull);
    });

    test('icon is null until asset is created', () {
      expect(QSpacePayLogo.icon, isNull);
    });
  });

  // ── QSpace Pulse logo (pending — must be null until assets are added) ────────

  group('QSpacePulseLogo', () {
    test('horizontal is null until asset is created', () {
      expect(QSpacePulseLogo.horizontal, isNull);
    });

    test('vertical is null until asset is created', () {
      expect(QSpacePulseLogo.vertical, isNull);
    });

    test('icon is null until asset is created', () {
      expect(QSpacePulseLogo.icon, isNull);
    });
  });
}