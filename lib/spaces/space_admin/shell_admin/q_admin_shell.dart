// lib/experience/spaces/space_admin/shell/q_admin_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Refactored nav to read from kAdminScreenRegistry — adding a screen is
//     now a one-file change (admin_screen_registry.dart), never this file.
//   • Added AdminBrandDraftScope + AdminPanelControllerScope wrappers so brand
//     editing and preview state is accessible anywhere in the admin subtree.
//   • Auth-ready sidebar: greeting, profile icon with dropdown (Settings +
//     Logout), dev mode badge. Wire QAuthSession when auth is live.
//   • Preview panel slides in from the right using AnimatedContainer with
//     OverflowBox so content stays full-width during the width animation.
//   • _LockedScreenStub updated to show lockNote from the registry entry.
// ─────────────────────────────────────────────────────────────────────────────
//
// DEPENDENCY CHAIN:
//   QAdminShell
//     → DevScreenSettingsScope (owns _devSettings)
//     → AdminBrandDraftScope   (owns _brandDraft)
//     → AdminPanelControllerScope (owns _panelCtrl)
//       → sidebar / IndexedStack / AdminPreviewPanel

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/dev_screen_settings.dart';
import '../../../../core/admin/admin_brand_draft.dart';
import '../../../../core/admin/admin_screen_registry.dart';
import '../widgets/admin_preview_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kSidebarWidth        = 240.0;
const double _kSidebarHeaderH      = 76.0;
const double _kNavItemHeight       = 44.0;
const double _kNavItemHorizPad     = 12.0;
const double _kNavItemBorderR      = 8.0;
const double _kNavIconSize         = 18.0;
const double _kPreviewPanelWidth   = 440.0;  // matches Claude artifact panel feel
const double _kBreakpointSidebar   = 768.0;  // below this → drawer mode

// ── Dev mode auth stub ────────────────────────────────────────────────────────
// Replace these with QAuthSession fields once auth is wired.
// TODO(auth): replace with ref.watch(currentSessionProvider) when live.
const String _kDevDisplayName  = 'Dev Admin';
const String _kDevEmail        = 'dev@qspace.local';
const String _kDevRole         = 'architect';  // highest access during dev
const String _kDevModeBadge    = 'DEV MODE';

// ── Copy ──────────────────────────────────────────────────────────────────────
const String _kAdminLabel      = 'Admin Panel';
const String _kVersionLabel    = 'QSpace Pages v2.2.0';
const String _kFooterSubLabel  = 'Control Plane · Canon v2.2.0';
const String _kLockedSuffix    = 'Cycle 3+';
const String _kProfileSettings = 'Settings';
const String _kProfileLogout   = 'Log Out';
const String _kDevLogoutNote   =
    'Auth not wired yet — this is a dev stub. '
    'Wire QAdminShell.onLogout to your AuthPort.signOut() call.';

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// QAdminShell
// ─────────────────────────────────────────────────────────────────────────────

class QAdminShell extends StatefulWidget {
  const QAdminShell({super.key});

  @override
  State<QAdminShell> createState() => _QAdminShellState();
}

class _QAdminShellState extends State<QAdminShell> {

  // These three live here and are the single owners of their respective state.
  // The scopes below make them accessible anywhere in the admin subtree.
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

  // Builds the screen list from the registry — locked entries get a stub.
  // The IndexedStack keeps these alive between nav switches.
  List<Widget> get _screens {
    return kAdminScreenRegistry.map((entry) {
      if (entry.locked) {
        return _LockedScreenStub(label: entry.label, note: entry.lockNote);
      }
      return entry.screen;
    }).toList();
  }

  void _selectIndex(int i) {
    if (kAdminScreenRegistry[i].locked) return;
    setState(() => _selectedIndex = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  // Dev-mode logout stub. Wire this to AuthPort.signOut() when auth is live.
  void _handleLogout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _kDevLogoutNote,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surfaceLit,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Three scopes, innermost to outermost:
    //   DevScreenSettingsScope → space_dev reads this
    //   AdminBrandDraftScope   → brand screen + preview panel read this
    //   AdminPanelControllerScope → any screen can open/close the panel
    return DevScreenSettingsScope(
      settings: _devSettings,
      child: AdminBrandDraftScope(
        draft: _brandDraft,
        child: AdminPanelControllerScope(
          controller: _panelCtrl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= _kBreakpointSidebar;
              return isDesktop
                  ? _buildDesktopLayout(context)
                  : _buildMobileLayout(context);
            },
          ),
        ),
      ),
    );
  }

  // ── Desktop: sidebar + content + optional preview panel ──────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    // Reading panelCtrl here makes the Row rebuild when the panel opens/closes.
    final panelOpen = AdminPanelControllerScope.of(context).isOpen;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _AdminSidebar(
            selectedIndex: _selectedIndex,
            onSelect: _selectIndex,
            displayName: _kDevDisplayName,
            email: _kDevEmail,
            role: _kDevRole,
            onLogout: () => _handleLogout(context),
            onSettingsTap: () {
              // TODO(auth): navigate to profile/settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Settings coming in Cycle 3.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                  backgroundColor: AppColors.surfaceLit,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.border),

          // Content — fills remaining space, compresses when panel opens
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),

          // Preview panel — animates its width using OverflowBox so the
          // panel content stays at full width during the animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: panelOpen ? _kPreviewPanelWidth + 1 : 0, // +1 for divider
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

  // ── Mobile: AppBar + Drawer ───────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final currentLabel = kAdminScreenRegistry[_selectedIndex].label;
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
        title: Text(currentLabel, style: AppTypography.h4),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: _AdminSidebar(
          selectedIndex: _selectedIndex,
          onSelect: _selectIndex,
          displayName: _kDevDisplayName,
          email: _kDevEmail,
          role: _kDevRole,
          onLogout: () => _handleLogout(context),
          onSettingsTap: () {},
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _AdminSidebar — the nav column used in both desktop and mobile drawer
// ─────────────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String displayName;
  final String email;
  final String role;
  final VoidCallback onLogout;
  final VoidCallback onSettingsTap;

  const _AdminSidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.displayName,
    required this.email,
    required this.role,
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
            displayName: displayName,
            email: email,
            role: role,
            onLogout: onLogout,
            onSettingsTap: onSettingsTap,
          ),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 6),

          // Nav items built from registry
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: kAdminScreenRegistry.length,
              itemBuilder: (context, i) {
                final entry = kAdminScreenRegistry[i];
                return _AdminNavItem(
                  icon: entry.icon,
                  label: entry.label,
                  isSelected: selectedIndex == i && !entry.locked,
                  isLocked: entry.locked,
                  onTap: () => onSelect(i),
                );
              },
            ),
          ),

          Divider(height: 1, color: AppColors.border),
          _SidebarFooter(),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SidebarHeader — auth-ready header with greeting + profile
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String role;
  final VoidCallback onLogout;
  final VoidCallback onSettingsTap;

  const _SidebarHeader({
    required this.displayName,
    required this.email,
    required this.role,
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
    return SizedBox(
      height: _kSidebarHeaderH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kNavItemHorizPad, vertical: 10),
        child: Row(
          children: [
            // Logo icon
            BrandLogoEngine.iconWhite(width: 22, height: 22),
            const SizedBox(width: 10),

            // Greeting + admin label
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, $displayName',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _kAdminLabel,
                    style: AppTypography.h5.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Dev mode badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      _kDevModeBadge,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile icon → popup menu
            _ProfileMenu(
              displayName: displayName,
              email: email,
              role: role,
              onLogout: onLogout,
              onSettingsTap: onSettingsTap,
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ProfileMenu — avatar icon that opens a popup with Settings + Logout
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileMenu extends StatelessWidget {
  final String displayName;
  final String email;
  final String role;
  final VoidCallback onLogout;
  final VoidCallback onSettingsTap;

  const _ProfileMenu({
    required this.displayName,
    required this.email,
    required this.role,
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
        // User info — not selectable
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                email,
                style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  role,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
              Text(
                _kProfileLogout,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: AppGradients.avatar,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SidebarFooter — version + plane label
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_kNavItemHorizPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_kVersionLabel, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(
            _kFooterSubLabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _AdminNavItem — single sidebar nav row
// ─────────────────────────────────────────────────────────────────────────────

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLocked;
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
        height: _kNavItemHeight,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: _kNavItemHorizPad),
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
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: color,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isLocked)
              Icon(Icons.lock_outline, size: 11, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _LockedScreenStub — placeholder for unbuilt screens
// ─────────────────────────────────────────────────────────────────────────────

class _LockedScreenStub extends StatelessWidget {
  final String label;
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
          Text(
            'Available in $_kLockedSuffix',
            style: AppTypography.bodySmall,
          ),
          if (note != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 360,
              child: Text(
                note!,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}