// lib/experience/spaces/space_admin/shell/q_admin_shell.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — QAdminShell, the navigation wrapper for space_admin.
//     Owns DevScreenSettings instance (wraps tree in DevScreenSettingsScope).
//     Adaptive layout: persistent sidebar ≥ 768px, Drawer on mobile.
//     IndexedStack keeps admin screens alive between nav switches.
//     Content/Assets/Preview are locked stubs until Cycle 3.
// ─────────────────────────────────────────────────────────────────────────────
//
// WHAT THIS FILE OWNS:
//   • DevScreenSettings instance (created + disposed here)
//   • Admin navigation state (_selectedIndex)
//   • Adaptive sidebar / drawer layout
//
// WHAT IT DOES NOT OWN:
//   • Any screen content — that lives in the screens/ folder
//   • Any business logic — this is pure navigation/layout shell
//
// TO USE: Set QAdminShell() as the home: in MaterialApp(theme: AppTheme.dark)
//
// Canon rule: QAdminShell must never share a navigation shell with the
// public QPagesApp (space_value, space_system, space_auxiliary).

import 'package:flutter/material.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/dev_screen_settings.dart';
import '../screens/screen_admin_overview.dart';
import '../screens/screen_admin_brand.dart';
import '../screens/screen_admin_features.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Layout ────────────────────────────────────────────────────────────────────
const double _kSidebarWidth      = 240.0;
const double _kSidebarHeaderH    = 72.0;   // logo + "Admin" label area
const double _kNavItemHeight     = 44.0;
const double _kNavItemHorizPad   = 16.0;
const double _kNavItemBorderR    = 8.0;
const double _kNavIconSize       = 18.0;
const double _kBreakpointSidebar = 768.0;  // below this → drawer mode

// ── Copy ──────────────────────────────────────────────────────────────────────
const String _kAdminLabel   = 'Admin Panel';
const String _kVersionLabel = 'QSpace Pages v2.0.0';
const String _kLockedSuffix = ' — Cycle 3';

// ── Nav item definitions — (icon, label, locked) ──────────────────────────────
// locked=true → shows a lock icon + coming-soon stub instead of the real screen
const _kNavItems = [
  (icon: Icons.space_dashboard_outlined, label: 'Overview',  locked: false),
  (icon: Icons.palette_outlined,         label: 'Brand',     locked: false),
  (icon: Icons.edit_note_outlined,       label: 'Content',   locked: true),
  (icon: Icons.photo_library_outlined,   label: 'Assets',    locked: true),
  (icon: Icons.tune_outlined,            label: 'Features',  locked: false),
  (icon: Icons.preview_outlined,         label: 'Preview',   locked: true),
];

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
  // The settings instance lives here — it's the single source of truth for
  // everything space_admin writes and space_dev reads. Wrapped in
  // DevScreenSettingsScope below so the entire shell subtree can access it.
  final _devSettings = DevScreenSettings();

  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _devSettings.dispose();
    super.dispose();
  }

  // Screens in order matching _kNavItems. Locked screens show a stub.
  // Using a getter so screens rebuild with the current index — IndexedStack
  // in build() keeps them alive, this just defines the order.
  List<Widget> get _screens => [
    const ScreenAdminOverview(),
    const ScreenAdminBrand(),
    const _LockedScreen(label: 'Content'),
    const _LockedScreen(label: 'Assets'),
    const ScreenAdminFeatures(),
    const _LockedScreen(label: 'Preview'),
  ];

  void _selectIndex(int i) {
    // Locked screens can't be navigated to
    if (_kNavItems[i].locked) return;
    setState(() => _selectedIndex = i);
    // Close drawer on mobile after selection
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // DevScreenSettingsScope at the very top so all admin screens AND
    // any Navigator.push'd dev screens (re-wrapped with the same instance)
    // can read settings without prop drilling.
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

  // ── Desktop: persistent sidebar + content area ────────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _AdminSidebar(
            selectedIndex: _selectedIndex,
            onSelect: _selectIndex,
          ),
          // Hairline separator matching the system border style
          VerticalDivider(
            width: 1, thickness: 1, color: AppColors.border,
          ),
          // Content area fills the rest — IndexedStack keeps screens alive
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

  // ── Mobile: AppBar + Drawer ───────────────────────────────────────────────

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
// _AdminSidebar — the nav column (used in both desktop and drawer)
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
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _kNavItems.length,
              itemBuilder: (context, i) {
                final item = _kNavItems[i];
                return _AdminNavItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: selectedIndex == i && !item.locked,
                  isLocked: item.locked,
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
// _SidebarHeader — logo + admin label
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
            // Brand icon — falls back gracefully to typographic wordmark
            BrandLogoEngine.iconWhite(width: 24, height: 24),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BrandCopy.appName,
                  style: AppTypography.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _kAdminLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
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
// _SidebarFooter — version info + back-to-app hint
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
                  color: itemColor,
                  fontSize: 13,
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
// _LockedScreen — placeholder for screens not yet implemented
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
            'Available$_kLockedSuffix',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}