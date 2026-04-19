// lib/core/nav/README_nav_wiring.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// NAV SYSTEM — WIRING REFERENCE
// ─────────────────────────────────────────────────────────────────────────────
//
// This file is a non-compiled reference doc. It shows exactly how to wire
// the nav system into the QSpace architecture. Delete this file once you've
// completed the integration — it's scaffolding, not production code.
//
// ─────────────────────────────────────────────────────────────────────────────

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 1 — Define nav items (per-space, single source of truth)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Conventionally in:  lib/interface/nav_items.dart
// (replaces the old nav_items.dart from the WellPath codebase)
//
// ---------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:qspace_pages/core/nav/nav.dart';
//
// // Public marketing links — used by QMarketingNav
// const kMarketingNavItems = [
//   QNavItem(label: 'About',    route: '/about',    icon: Icons.info_outline),
//   QNavItem(label: 'Features', route: '/features', icon: Icons.star_outline),
//   QNavItem(label: 'Pricing',  route: '/pricing',  icon: Icons.attach_money),
// ];
//
// // Authenticated user nav — used by QAppNavShell
// const kUserNavItems = [
//   QNavItem(
//     icon:       Icons.home_outlined,
//     activeIcon: Icons.home_rounded,
//     label:      'Home',
//     route:      '/home',
//   ),
//   QNavItem(
//     icon:       Icons.search_outlined,
//     activeIcon: Icons.search_rounded,
//     label:      'Discover',
//     route:      '/discover',
//   ),
//   QNavItem(
//     icon:       Icons.person_outline_rounded,
//     activeIcon: Icons.person_rounded,
//     label:      'Profile',
//     route:      '/profile',
//   ),
// ];
//
// // Admin control plane nav — used by QAdminNav
// const kAdminNavGroups = [
//   QNavGroup(
//     header: 'Content',
//     items: [
//       QNavItem(
//         icon:       Icons.edit_outlined,
//         activeIcon: Icons.edit_rounded,
//         label:      'Overview',
//         route:      '/admin',
//       ),
//       QNavItem(
//         icon:       Icons.article_outlined,
//         activeIcon: Icons.article_rounded,
//         label:      'Content',
//         route:      '/admin/content',
//       ),
//     ],
//   ),
//   QNavGroup(
//     header: 'Brand',
//     items: [
//       QNavItem(
//         icon:       Icons.palette_outlined,
//         activeIcon: Icons.palette_rounded,
//         label:      'Brand',
//         route:      '/admin/brand',
//       ),
//       QNavItem(
//         icon:       Icons.tune_outlined,
//         activeIcon: Icons.tune_rounded,
//         label:      'Features',
//         route:      '/admin/features',
//       ),
//     ],
//   ),
//   QNavGroup(
//     header: 'Preview',
//     items: [
//       QNavItem(
//         icon:       Icons.preview_outlined,
//         activeIcon: Icons.preview_rounded,
//         label:      'Preview',
//         route:      '/admin/preview',
//       ),
//     ],
//   ),
// ];
// ---------------------------------------------------------------------------


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 2 — Pick the nav template in client_config.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// lib/client/qspace/client_config.dart
// ---------------------------------------------------------------------------
// import 'package:qspace_pages/core/nav/nav.dart';
//
// // The nav template used across the entire client deployment.
// // Change this one line to switch the nav personality for any client.
// const kClientNavTemplate = kNavTemplateDefault;
//
// // ... rest of client_config.dart unchanged
// ---------------------------------------------------------------------------


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 3 — Wire authenticated shell in app_router.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Inside ShellRoute or each authenticated GoRoute builder:
// ---------------------------------------------------------------------------
// import 'package:qspace_pages/core/nav/nav.dart';
// import 'package:qspace_pages/client/qspace/client_config.dart';
// import 'package:qspace_pages/interface/nav_items.dart';
//
// // Inside routerProvider, wrap authenticated routes:
// ShellRoute(
//   builder: (context, state, child) {
//     final session = ref.read(currentSessionProvider);
//     return QAppNavShell(
//       currentRoute: state.uri.path,
//       items:        kUserNavItems,
//       template:     kClientNavTemplate,  // ← from client_config
//       onNavigate:   (route) => context.go(route),
//       userProfile:  session != null
//           ? QNavUserProfile(
//               displayName: session.displayName,
//               roleName:    session.role.name,
//             )
//           : null,
//       child: child,
//     );
//   },
//   routes: [
//     GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
//     GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
//     // ... all authenticated routes
//   ],
// )
// ---------------------------------------------------------------------------


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 4 — Wire marketing nav on marketing pages
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Inside any public page (screen_home_entry.dart, screen_features_entry.dart…):
// ---------------------------------------------------------------------------
// @override
// Widget build(BuildContext context) {
//   return Stack(
//     children: [
//       // Page scrollable content
//       SingleChildScrollView(
//         controller: _scrollCtrl,
//         child: Column(children: [
//           SizedBox(height: kNavBarHeightMarketing), // reserve space for nav
//           // ... page sections
//         ]),
//       ),
//       // Floating nav — always last in the Stack so it renders on top
//       QMarketingNav(
//         items:          kMarketingNavItems,
//         ctaLabel:       'Begin Journey',
//         onCta:          () => context.push('/signup'),
//         onNavigate:     (r) => context.push(r),
//         onProfileTap:   () => context.push('/login'),
//         scrollController: _scrollCtrl,
//         template:       kClientNavTemplate,
//       ),
//     ],
//   );
// }
// ---------------------------------------------------------------------------


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 5 — Wire admin nav in q_admin_shell.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Replace QAdminShell body with QAdminNav:
// ---------------------------------------------------------------------------
// @override
// Widget build(BuildContext context) {
//   return QAdminNav(
//     groups:       kAdminNavGroups,
//     currentRoute: GoRouterState.of(context).uri.path,
//     onNavigate:   (r) => context.go(r),
//     breadcrumb:   _resolveBreadcrumb(context),
//     topStripTrailing: _AdminPublishBar(),  // your publish toolbar widget
//     child:        widget.child,
//   );
// }
// ---------------------------------------------------------------------------


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STEP 6 — Use QHamburgerButton in page headers (drawer mode only)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// QHamburgerButton reads QNavScope automatically. Drop it anywhere in a
// screen header — it self-hides when mode != drawer.
// ---------------------------------------------------------------------------
// Row(children: [
//   const QHamburgerButton(),   // ← just this, no conditions needed
//   const SizedBox(width: 12),
//   Text('Page Title', style: AppTypography.h3),
// ])
// ---------------------------------------------------------------------------


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TEMPLATE QUICK-PICK
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//   kNavTemplateDefault   — collapsible sidebar, pill active, user tile
//   kNavTemplateCompact   — icon-only sidebar, no user tile
//   kNavTemplatePortal    — top horizontal strip on desktop (suite.portal)
//   kNavTemplateAccent    — accentBar active style, no dot (portfolio/agency)
//   kNavTemplateAdmin     — fixed admin sidebar with group headers
//
// To create a client-specific variation without defining a new template:
//   const kClientNavTemplate = kNavTemplateDefault.copyWith(
//     startsCollapsed: true,   // ← e.g. client wants sidebar collapsed by default
//     showActiveDot:   false,
//   );