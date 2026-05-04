// lib/spaces/space_admin/shell/q_admin_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QAdminShell with registry-driven nav, three scopes
//             (DevScreenSettings, AdminBrandDraft, AdminPanelController),
//             auth-ready sidebar header with greeting + profile popup + logout.
//   v1.1.0 — Added QAdminConfigScope. Shell now reads QAdminConfig to decide
//             per-portal visibility and lock state. Registry locked=true always
//             wins. Config hidden portals are excluded from the nav entirely.
//             devModeEnabled badge reads from config — no more hardcoded const.
//             Sidebar disabled portals shown greyed without tapping.
//             Import paths corrected to lib/spaces/... structure.
// ─────────────────────────────────────────────────────────────────────────────
//
// SCOPE CHAIN (outer → inner):
//   QAdminConfigScope       → portals read access rules
//   DevScreenSettingsScope  → space_dev reads toggles
//   AdminBrandDraftScope    → brand portal + preview panel
//   AdminPanelControllerScope → any screen can open/close the preview panel

import 'package:flutter/material.dart';
import '../../../core/style/app_style.dart';
import '../../../core/admin/dev_screen_settings.dart';
import '../../../core/admin/admin_brand_draft.dart';
import '../../../core/admin/admin_screen_registry.dart';
import '../../../core/admin/admin_config.dart';
import 'admin_views/admin_widgets/admin_preview_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kSidebarWidth      = 240.0;
const double _kSidebarHeaderH    = 76.0;
const double _kNavItemH          = 44.0;
const double _kNavItemHPad       = 12.0;
const double _kNavItemBorderR    = 8.0;
const double _kNavIconSize       = 18.0;
const double _kPreviewPanelWidth = 440.0;
const double _kBreakpoint        = 768.0;

// ── Copy ──────────────────────────────────────────────────────────────────────
const String _kLockedSuffix    = 'Cycle 3+';
const String _kProfileSettings = 'Settings';
const String _kProfileLogout   = 'Log Out';
const String _kDevLogoutNote   =
    'Auth is not wired yet — this is a dev stub. '
    'Wire QAdminShell with your AuthPort.signOut() call when auth is live.';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


class QAdminShell extends StatefulWidget {
  // The config is injected here (from client_config.dart via AppRoot or main.dart)
  // so the shell is reusable across tenants without importing client_config directly.
  final QAdminConfig config;

  const QAdminShell({super.key, required this.config});

  @override
  State<QAdminShell> createState() => _QAdminShellState();
}

class _QAdminShellState extends State<QAdminShell> {

  final _devSettings = DevScreenSettings();
  final _brandDraft  = AdminBrandDraft();
  final _panelCtrl   = AdminPanelController();

  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _devSettings.dispose();
    _brandDraft.dispose();
    _panelCtrl.dispose();
    super.dispose();
  }

  // Builds the visible portal list by merging registry with config.
  // Portals hidden in config are excluded from the list entirely — their
  // IndexedStack slot simply doesn't exist.
  List<AdminScreenEntry> get _visiblePortals {
    return kAdminScreenRegistry.where((entry) {
      final access = widget.config.effectiveAccessFor(
        entry.id,
        registryLocked:  entry.locked,
        registryLockNote: entry.lockNote,
      );
      return access.enabled;
    }).toList();
  }

  List<Widget> get _screens {
    return _visiblePortals.map((entry) {
      final access = widget.config.effectiveAccessFor(
        entry.id,
        registryLocked:  entry.locked,
        registryLockNote: entry.lockNote,
      );
      if (access.locked) {
        return _LockedScreenStub(label: entry.label, note: access.lockNote);
      }
      return entry.screen;
    }).toList();
  }

  void _selectIndex(int i) {
    final entry = _visiblePortals[i];
    final access = widget.config.effectiveAccessFor(
      entry.id,
      registryLocked: entry.locked,
      registryLockNote: entry.lockNote,
    );
    if (access.locked || !access.enabled) return;
    setState(() => _selectedIndex = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _handleLogout(BuildContext context) {
    // TODO(auth): replace this snackbar with AuthPort.signOut() + GoRouter redirect.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_kDevLogoutNote,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.surfaceLit,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Clamp index in case portal count changes between builds.
    if (_selectedIndex >= _visiblePortals.length) {
      _selectedIndex = 0;
    }

    return QAdminConfigScope(
      config: widget.config,
      child: DevScreenSettingsScope(
        settings: _devSettings,
        child: AdminBrandDraftScope(
          draft: _brandDraft,
          child: AdminPanelControllerScope(
            controller: _panelCtrl,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth >= _kBreakpoint
                    ? _buildDesktop(context)
                    : _buildMobile(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final panelOpen = AdminPanelControllerScope.of(context).isOpen;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _AdminSidebar(
            portals:       _visiblePortals,
            selectedIndex: _selectedIndex,
            config:        widget.config,
            onSelect:      _selectIndex,
            onLogout:      () => _handleLogout(context),
            onSettingsTap: () => _snack(context, 'Settings coming in Cycle 3.'),
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
          // Animated preview panel — OverflowBox keeps content at full width
          // while the AnimatedContainer width collapses to 0.
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: panelOpen ? _kPreviewPanelWidth + 1 : 0,
            child: OverflowBox(
              maxWidth: _kPreviewPanelWidth + 1,
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _kPreviewPanelWidth + 1,
                child: Row(
                  children: [
                    VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                    const Expanded(child: AdminPreviewPanel()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final label = _visiblePortals.isNotEmpty
        ? _visiblePortals[_selectedIndex].label
        : 'Admin';
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(label, style: AppTypography.h4),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: _AdminSidebar(
          portals:       _visiblePortals,
          selectedIndex: _selectedIndex,
          config:        widget.config,
          onSelect:      _selectIndex,
          onLogout:      () => _handleLogout(context),
          onSettingsTap: () {},
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.surfaceLit,
      behavior: SnackBarBehavior.floating,
    ));
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _AdminSidebar
// ─────────────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final List<AdminScreenEntry> portals;
  final int            selectedIndex;
  final QAdminConfig   config;
  final ValueChanged<int> onSelect;
  final VoidCallback   onLogout;
  final VoidCallback   onSettingsTap;

  const _AdminSidebar({
    required this.portals,
    required this.selectedIndex,
    required this.config,
    required this.onSelect,
    required this.onLogout,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSidebarWidth,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarHeader(
            config:        config,
            onLogout:      onLogout,
            onSettingsTap: onSettingsTap,
          ),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: portals.length,
              itemBuilder: (context, i) {
                final entry = portals[i];
                final access = config.effectiveAccessFor(
                  entry.id,
                  registryLocked:  entry.locked,
                  registryLockNote: entry.lockNote,
                );
                return _AdminNavItem(
                  icon:       entry.icon,
                  label:      entry.label,
                  isSelected: selectedIndex == i && !access.locked,
                  isLocked:   access.locked,
                  onTap:      () => onSelect(i),
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          _SidebarFooter(versionLabel: config.versionLabel),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SidebarHeader — auth-ready, reads dev info from QAdminConfig
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final QAdminConfig config;
  final VoidCallback onLogout;
  final VoidCallback onSettingsTap;

  const _SidebarHeader({
    required this.config,
    required this.onLogout,
    required this.onSettingsTap,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // In dev mode: use config dev stubs.
    // TODO(auth): replace with ref.watch(currentSessionProvider) when auth is live.
    final displayName = config.devModeEnabled ? config.devDisplayName : 'Admin';
    final roleLabel   = config.devModeEnabled ? config.devRoleLabel   : '';

    return SizedBox(
      height: _kSidebarHeaderH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kNavItemHPad, vertical: 10),
        child: Row(
          children: [
            BrandLogoEngine.iconWhite(width: 22, height: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, $displayName',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary, fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(config.adminTitle, style: AppTypography.h5.copyWith(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  if (config.devModeEnabled) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                      ),
                      child: Text('DEV MODE', style: AppTypography.caption.copyWith(
                        color: AppColors.warning, fontSize: 7,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      )),
                    ),
                  ],
                ],
              ),
            ),
            _ProfileMenu(
              displayName:   displayName,
              email:         config.devModeEnabled ? config.devEmail : '',
              roleLabel:     roleLabel,
              onLogout:      onLogout,
              onSettingsTap: onSettingsTap,
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ProfileMenu
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileMenu extends StatelessWidget {
  final String displayName;
  final String email;
  final String roleLabel;
  final VoidCallback onLogout;
  final VoidCallback onSettingsTap;

  const _ProfileMenu({
    required this.displayName,
    required this.email,
    required this.roleLabel,
    required this.onLogout,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 44),
      color: AppColors.surfaceLit,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBR,
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (value) {
        if (value == 'logout') onLogout();
        if (value == 'settings') onSettingsTap();
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName.isNotEmpty ? displayName : 'Admin',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              if (email.isNotEmpty)
                Text(email, style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted, fontSize: 10,
                )),
              if (roleLabel.isNotEmpty) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(roleLabel, style: AppTypography.caption.copyWith(
                    color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700,
                  )),
                ),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(_kProfileSettings, style: AppTypography.bodySmall),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 14, color: AppColors.error),
              const SizedBox(width: 8),
              Text(_kProfileLogout, style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              )),
            ],
          ),
        ),
      ],
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          gradient: AppGradients.avatar,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
            style: AppTypography.caption.copyWith(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SidebarFooter
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarFooter extends StatelessWidget {
  final String versionLabel;
  const _SidebarFooter({required this.versionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_kNavItemHPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(versionLabel, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text('Control Plane · Canon v2.2.0', style: AppTypography.caption.copyWith(
            color: AppColors.textMuted, fontSize: 9,
          )),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _AdminNavItem
// ─────────────────────────────────────────────────────────────────────────────

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isSelected;
  final bool     isLocked;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLocked
        ? AppColors.textMuted
        : isSelected
            ? AppColors.primary
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: _kNavItemH,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: _kNavItemHPad),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(_kNavItemBorderR),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: _kNavIconSize, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: AppTypography.body.copyWith(
                color: color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              )),
            ),
            if (isLocked) Icon(Icons.lock_outline, size: 11, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _LockedScreenStub
// ─────────────────────────────────────────────────────────────────────────────

class _LockedScreenStub extends StatelessWidget {
  final String  label;
  final String? note;
  const _LockedScreenStub({required this.label, this.note});

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
            child: Icon(Icons.lock_outline, color: AppColors.textMuted, size: 28),
          ),
          const SizedBox(height: 20),
          Text(label, style: AppTypography.h4),
          const SizedBox(height: 8),
          Text('Available in $_kLockedSuffix', style: AppTypography.bodySmall),
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