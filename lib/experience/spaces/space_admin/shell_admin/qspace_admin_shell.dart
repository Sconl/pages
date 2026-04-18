// lib/experience/spaces/space_admin/shell_admin/qspace_admin_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — QAdminShell, the navigation wrapper for space_admin.
//     Owns DevScreenSettings instance (wraps tree in DevScreenSettingsScope).
//     Adaptive layout: persistent sidebar ≥ 768px, Drawer on mobile.
//     IndexedStack keeps admin screens alive between nav switches.
//     Content/Assets/Preview are locked stubs until Cycle 3.
//   • v1.0.1 — Fixed: QAdminShell correctly declared as StatefulWidget.
//              Removed orphaned StatelessWidget stub that broke _QAdminShellState.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/dev_screen_settings.dart';
import '../screen_admin/screen_admin_overview.dart';
import '../screen_admin/screen_admin_brand.dart';
import '../screen_admin/screen_admin_features.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ──
const double _kSidebarWidth      = 240.0;
const double _kSidebarHeaderH    = 72.0;
const double _kNavItemHeight     = 44.0;
const double _kNavItemHorizPad   = 16.0;
const double _kNavItemBorderR    = 8.0;
const double _kNavIconSize       = 18.0;
const double _kBreakpointSidebar = 768.0;

// ── Copy ──
const String _kAdminLabel   = 'Admin Panel';
const String _kVersionLabel = 'QSpace Pages v2.0.0';
const String _kLockedSuffix = ' — Cycle 3';

// ── Nav item definitions ──
const _kNavItems = [
  (icon: Icons.space_dashboard_outlined, label: 'Overview',  locked: false),
  (icon: Icons.palette_outlined,         label: 'Brand',     locked: false),
  (icon: Icons.edit_note_outlined,       label: 'Content',   locked: true),
  (icon: Icons.photo_library_outlined,   label: 'Assets',    locked: true),
  (icon: Icons.tune_outlined,            label: 'Features',  locked: false),
  (icon: Icons.preview_outlined,         label: 'Preview',   locked: true),
];

// ─────────────────────────────────────────────────────────────────────────────
// QAdminShell
// ─────────────────────────────────────────────────────────────────────────────

class QAdminShell extends StatefulWidget {
  /// [body] is provided by GoRouter's ShellRoute. When QAdminShell is used
  /// standalone (outside GoRouter), pass the desired child widget directly.
  final Widget body;

  const QAdminShell({super.key, required this.body});

  @override
  State<QAdminShell> createState() => _QAdminShellState();
}

class _QAdminShellState extends State<QAdminShell> {
  final _devSettings = DevScreenSettings();

  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _devSettings.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    const ScreenAdminOverview(),
    const ScreenAdminBrand(),
    const _LockedScreen(label: 'Content'),
    const _LockedScreen(label: 'Assets'),
    const ScreenAdminFeatures(),
    const _LockedScreen(label: 'Preview'),
  ];

  void _selectIndex(int i) {
    if (_kNavItems[i].locked) return;
    setState(() => _selectedIndex = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DevScreenSettingsScope(
      settings: _devSettings,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= _kBreakpointSidebar;
          return isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _AdminSidebar(
            selectedIndex: _selectedIndex,
            onSelect: _selectIndex,
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final currentLabel = _kNavItems[_selectedIndex].label;
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
// _AdminSidebar
// ─────────────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _AdminSidebar({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSidebarWidth,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarHeader(),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _kNavItems.length,
              itemBuilder: (context, i) {
                final item = _kNavItems[i];
                return _AdminNavItem(
                  icon:       item.icon,
                  label:      item.label,
                  isSelected: selectedIndex == i && !item.locked,
                  isLocked:   item.locked,
                  onTap:      () => onSelect(i),
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
// _SidebarHeader
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kSidebarHeaderH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kNavItemHorizPad),
        child: Row(
          children: [
            BrandLogoEngine.iconWhite(width: 24, height: 24),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BrandCopy.appName,
                  style: AppTypography.h5.copyWith(
                    color:      AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize:   13,
                  ),
                ),
                Text(
                  _kAdminLabel,
                  style: AppTypography.caption.copyWith(
                    color:         AppColors.primary,
                    fontSize:      10,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarFooter
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
            'Control Plane · Canon v2.0.0',
            style: AppTypography.caption.copyWith(
              color:    AppColors.textMuted,
              fontSize: 9,
            ),
          ),
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
    final itemColor = isLocked
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
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_kNavItemBorderR),
          border: isSelected
              ? Border.all(color: AppColors.primary.withAlpha(40))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: _kNavIconSize, color: itemColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color:      itemColor,
                  fontSize:   13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isLocked)
              Icon(Icons.lock_outline, size: 12, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LockedScreen
// ─────────────────────────────────────────────────────────────────────────────

class _LockedScreen extends StatelessWidget {
  final String label;
  const _LockedScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:  AppColors.surface,
              shape:  BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.lock_outline, color: AppColors.textMuted, size: 28),
          ),
          const SizedBox(height: 20),
          Text(label, style: AppTypography.h4),
          const SizedBox(height: 8),
          Text('Available$_kLockedSuffix', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}