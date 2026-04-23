// lib/spaces/space_admin/admin_portals/settings_portal/shell_settings_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Settings portal stub. Reads QAdminConfigScope to decide
//             whether to render a locked stub or future settings content.
//             The registry does NOT lock this entry — the config controls it
//             so different tenants can expose settings at different times.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/admin_config.dart';

class ShellSettingsRoot extends StatelessWidget {
  const ShellSettingsRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final access = QAdminConfigScope.of(context).accessFor('settings');

    // If the config marks settings as locked (or hidden, which the shell
    // already gates), show a clean coming-soon stub.
    if (access.locked || !access.enabled) {
      return _LockedStub(note: access.lockNote);
    }

    // TODO(Cycle3): replace with real settings content once the
    // settings portal is implemented. For now even an unlocked settings
    // config shows the stub — the content simply isn't built yet.
    return _LockedStub(
      note: 'Settings content is being built. '
            'The portal is structurally wired — content ships in Cycle 3.',
    );
  }
}

class _LockedStub extends StatelessWidget {
  final String? note;
  const _LockedStub({this.note});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 28),
          ),
          const SizedBox(height: 20),
          Text('Settings', style: AppTypography.h4),
          const SizedBox(height: 8),
          Text('Available in Cycle 3+', style: AppTypography.bodySmall),
          if (note != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 360,
              child: Text(note!, textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted, height: 1.5,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}