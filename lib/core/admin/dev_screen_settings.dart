// lib/core/admin/dev_screen_settings.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   • Initial release — DevScreenSettings ChangeNotifier + DevScreenSettingsScope
//     InheritedNotifier. Lets space_admin write controls that space_dev reads
//     at runtime. Zero extra packages — ChangeNotifier + InheritedNotifier
//     is pure Flutter. Trivial Riverpod migration when the state layer matures.
// ─────────────────────────────────────────────────────────────────────────────
//
// WHO OWNS THIS FILE:
//   lib/core/admin/ — the admin logic layer. space_admin writes to this,
//   space_dev reads from it. Neither space owns it.
//
// DEPENDENCY CHAIN:
//   DevScreenSettings ← (written by) space_admin screens
//   DevScreenSettings → (read by) space_dev screens via DevScreenSettingsScope

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Default visibility — all on so the screen shows everything out of the box ─
const bool _kDefaultShowSectionCore    = true;
const bool _kDefaultShowSectionContext = true;
const bool _kDefaultShowSectionConnect = true;
const bool _kDefaultShowCountdown      = true;
const bool _kDefaultShowProgressBar    = true;
const bool _kDefaultShowPhaseCards     = true;
const bool _kDefaultShowDistModels     = true;  // distribution model badges
const bool _kDefaultShowArchLayers     = true;  // architecture layer badges
const bool _kDefaultShowBranchStatus   = true;  // branch + phase pills

// ─────────────────────────────────────────────────────────────────────────────
// END CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// DevScreenSettings — the writable state model
// ─────────────────────────────────────────────────────────────────────────────
//
// Two tiers of control:
//   • Section-level — show/hide entire QPStructure sections (core/context/connect)
//   • Component-level — show/hide specific widgets within a visible section
//
// A hidden section means all its components are hidden regardless of component
// toggles — the section check is the outer gate.

class DevScreenSettings extends ChangeNotifier {

  // ── Section-level visibility ──────────────────────────────────────────────
  bool _showSectionCore    = _kDefaultShowSectionCore;
  bool _showSectionContext = _kDefaultShowSectionContext;
  bool _showSectionConnect = _kDefaultShowSectionConnect;

  // ── Component-level visibility ────────────────────────────────────────────
  bool _showCountdown    = _kDefaultShowCountdown;
  bool _showProgressBar  = _kDefaultShowProgressBar;
  bool _showPhaseCards   = _kDefaultShowPhaseCards;
  bool _showDistModels   = _kDefaultShowDistModels;
  bool _showArchLayers   = _kDefaultShowArchLayers;
  bool _showBranchStatus = _kDefaultShowBranchStatus;

  // ── Getters ───────────────────────────────────────────────────────────────

  bool get showSectionCore    => _showSectionCore;
  bool get showSectionContext => _showSectionContext;
  bool get showSectionConnect => _showSectionConnect;
  bool get showCountdown      => _showCountdown;
  bool get showProgressBar    => _showProgressBar;
  bool get showPhaseCards     => _showPhaseCards;
  bool get showDistModels     => _showDistModels;
  bool get showArchLayers     => _showArchLayers;
  bool get showBranchStatus   => _showBranchStatus;

  // ── Setters — each notifies so InheritedNotifier dependents rebuild ───────

  void setSectionCore(bool v)    { _showSectionCore    = v; notifyListeners(); }
  void setSectionContext(bool v) { _showSectionContext  = v; notifyListeners(); }
  void setSectionConnect(bool v) { _showSectionConnect  = v; notifyListeners(); }
  void setCountdown(bool v)      { _showCountdown      = v; notifyListeners(); }
  void setProgressBar(bool v)    { _showProgressBar    = v; notifyListeners(); }
  void setPhaseCards(bool v)     { _showPhaseCards     = v; notifyListeners(); }
  void setDistModels(bool v)     { _showDistModels     = v; notifyListeners(); }
  void setArchLayers(bool v)     { _showArchLayers     = v; notifyListeners(); }
  void setBranchStatus(bool v)   { _showBranchStatus   = v; notifyListeners(); }

  /// Wipe every override back to the defaults declared in the config block.
  void resetToDefaults() {
    _showSectionCore    = _kDefaultShowSectionCore;
    _showSectionContext = _kDefaultShowSectionContext;
    _showSectionConnect = _kDefaultShowSectionConnect;
    _showCountdown      = _kDefaultShowCountdown;
    _showProgressBar    = _kDefaultShowProgressBar;
    _showPhaseCards     = _kDefaultShowPhaseCards;
    _showDistModels     = _kDefaultShowDistModels;
    _showArchLayers     = _kDefaultShowArchLayers;
    _showBranchStatus   = _kDefaultShowBranchStatus;
    notifyListeners();
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// DevScreenSettingsScope — InheritedNotifier wrapper
// ─────────────────────────────────────────────────────────────────────────────
//
// InheritedNotifier wires the ChangeNotifier to Flutter's element rebuild
// system automatically — no manual setState() needed. Any widget that calls
// DevScreenSettingsScope.of(context) will rebuild whenever notifyListeners()
// fires, within the subtree below this scope.

class DevScreenSettingsScope extends InheritedNotifier<DevScreenSettings> {
  const DevScreenSettingsScope({
    super.key,
    required DevScreenSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Never returns null — asserts in debug builds if the scope is missing.
  static DevScreenSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DevScreenSettingsScope>();
    assert(
      scope != null,
      'DevScreenSettingsScope not found in widget tree. '
      'Wrap your widget tree (at QAdminShell level) with DevScreenSettingsScope.',
    );
    return scope!.notifier!;
  }
}