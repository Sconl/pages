// lib/core/admin/admin_brand_draft.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AdminBrandDraft ChangeNotifier + AdminBrandDraftScope.
//             Holds draft* and live* parallel copies of every brand token.
//             publishDraft() promotes draft → live. discardDraft() reverts.
//             generateConfigSnippet() produces a paste-ready CONFIG BLOCK.
//   v1.1.0 — Added discardGeneration counter. Increments on every discardDraft()
//             call. Brand portal sections use this as a widget key so their
//             TextEditingControllers rebuild and re-sync when discard fires.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../style/brand_config.dart';


class AdminBrandDraft extends ChangeNotifier {

  // ── Draft state ───────────────────────────────────────────────────────────

  Color _draftPrimary   = kBrandDefault.primary;
  Color _draftSecondary = kBrandDefault.secondary;
  Color _draftTertiary  = kBrandDefault.tertiary;

  String _draftFontHero      = kBrandDefault.fontHero;
  String _draftFontDisplay   = kBrandDefault.fontDisplay;
  String _draftFontText      = kBrandDefault.fontText;
  String _draftFontAccent    = kBrandDefault.fontAccent;
  String _draftFontSignature = kBrandDefault.fontSignature;

  String _draftWordBold  = kBrandDefault.wordBold;
  String _draftWordLight = kBrandDefault.wordLight;
  String _draftAppName   = kBrandDefault.appName;
  String _draftTagline   = kBrandDefault.tagline;
  String _draftDomain    = kBrandDefault.domain;
  String _draftCopyright = kBrandDefault.copyright;

  CanvasPersonality _draftCanvasPersonality = kBrandDefault.canvasPersonality;
  MotionIntensity   _draftMotionIntensity   = kBrandDefault.motionIntensity;

  // ── Live (published) state ────────────────────────────────────────────────

  Color _livePrimary   = kBrandDefault.primary;
  Color _liveSecondary = kBrandDefault.secondary;
  Color _liveTertiary  = kBrandDefault.tertiary;

  String _liveFontHero      = kBrandDefault.fontHero;
  String _liveFontDisplay   = kBrandDefault.fontDisplay;
  String _liveFontText      = kBrandDefault.fontText;
  String _liveFontAccent    = kBrandDefault.fontAccent;
  String _liveFontSignature = kBrandDefault.fontSignature;

  String _liveWordBold  = kBrandDefault.wordBold;
  String _liveWordLight = kBrandDefault.wordLight;
  String _liveAppName   = kBrandDefault.appName;
  String _liveTagline   = kBrandDefault.tagline;
  String _liveDomain    = kBrandDefault.domain;
  String _liveCopyright = kBrandDefault.copyright;

  CanvasPersonality _liveCanvasPersonality = kBrandDefault.canvasPersonality;
  MotionIntensity   _liveMotionIntensity   = kBrandDefault.motionIntensity;

  // Incremented on every discardDraft(). Sections key on this so their
  // TextEditingControllers rebuild completely instead of drifting out of sync.
  int _discardGeneration = 0;
  int get discardGeneration => _discardGeneration;

  // ── Draft getters ─────────────────────────────────────────────────────────

  Color get draftPrimary   => _draftPrimary;
  Color get draftSecondary => _draftSecondary;
  Color get draftTertiary  => _draftTertiary;

  String get draftFontHero      => _draftFontHero;
  String get draftFontDisplay   => _draftFontDisplay;
  String get draftFontText      => _draftFontText;
  String get draftFontAccent    => _draftFontAccent;
  String get draftFontSignature => _draftFontSignature;

  String get draftWordBold  => _draftWordBold;
  String get draftWordLight => _draftWordLight;
  String get draftAppName   => _draftAppName;
  String get draftTagline   => _draftTagline;
  String get draftDomain    => _draftDomain;
  String get draftCopyright => _draftCopyright;

  CanvasPersonality get draftCanvasPersonality => _draftCanvasPersonality;
  MotionIntensity   get draftMotionIntensity   => _draftMotionIntensity;

  // ── Computed BrandConfig ─────────────────────────────────────────────────

  BrandConfig get draftConfig => kBrandDefault.copyWith(
    primary: _draftPrimary, secondary: _draftSecondary, tertiary: _draftTertiary,
    fontHero: _draftFontHero, fontDisplay: _draftFontDisplay,
    fontText: _draftFontText, fontAccent: _draftFontAccent,
    fontSignature: _draftFontSignature, wordBold: _draftWordBold,
    wordLight: _draftWordLight, appName: _draftAppName, tagline: _draftTagline,
    domain: _draftDomain, copyright: _draftCopyright,
    canvasPersonality: _draftCanvasPersonality, motionIntensity: _draftMotionIntensity,
  );

  BrandConfig get liveConfig => kBrandDefault.copyWith(
    primary: _livePrimary, secondary: _liveSecondary, tertiary: _liveTertiary,
    fontHero: _liveFontHero, fontDisplay: _liveFontDisplay,
    fontText: _liveFontText, fontAccent: _liveFontAccent,
    fontSignature: _liveFontSignature, wordBold: _liveWordBold,
    wordLight: _liveWordLight, appName: _liveAppName, tagline: _liveTagline,
    domain: _liveDomain, copyright: _liveCopyright,
    canvasPersonality: _liveCanvasPersonality, motionIntensity: _liveMotionIntensity,
  );

  bool get hasDraftChanges =>
      _draftPrimary != _livePrimary || _draftSecondary != _liveSecondary ||
      _draftTertiary != _liveTertiary || _draftFontHero != _liveFontHero ||
      _draftFontDisplay != _liveFontDisplay || _draftFontText != _liveFontText ||
      _draftFontAccent != _liveFontAccent || _draftFontSignature != _liveFontSignature ||
      _draftWordBold != _liveWordBold || _draftWordLight != _liveWordLight ||
      _draftAppName != _liveAppName || _draftTagline != _liveTagline ||
      _draftDomain != _liveDomain || _draftCopyright != _liveCopyright ||
      _draftCanvasPersonality != _liveCanvasPersonality ||
      _draftMotionIntensity != _liveMotionIntensity;

  // ── Setters ───────────────────────────────────────────────────────────────

  void setPrimary(Color c)                       { _draftPrimary           = c; notifyListeners(); }
  void setSecondary(Color c)                     { _draftSecondary         = c; notifyListeners(); }
  void setTertiary(Color c)                      { _draftTertiary          = c; notifyListeners(); }
  void setFontHero(String s)                     { _draftFontHero          = s; notifyListeners(); }
  void setFontDisplay(String s)                  { _draftFontDisplay       = s; notifyListeners(); }
  void setFontText(String s)                     { _draftFontText          = s; notifyListeners(); }
  void setFontAccent(String s)                   { _draftFontAccent        = s; notifyListeners(); }
  void setFontSignature(String s)                { _draftFontSignature     = s; notifyListeners(); }
  void setWordBold(String s)                     { _draftWordBold          = s; notifyListeners(); }
  void setWordLight(String s)                    { _draftWordLight         = s; notifyListeners(); }
  void setAppName(String s)                      { _draftAppName           = s; notifyListeners(); }
  void setTagline(String s)                      { _draftTagline           = s; notifyListeners(); }
  void setDomain(String s)                       { _draftDomain            = s; notifyListeners(); }
  void setCopyright(String s)                    { _draftCopyright         = s; notifyListeners(); }
  void setCanvasPersonality(CanvasPersonality v) { _draftCanvasPersonality = v; notifyListeners(); }
  void setMotionIntensity(MotionIntensity v)     { _draftMotionIntensity   = v; notifyListeners(); }

  // ── Publish / Discard ─────────────────────────────────────────────────────

  void publishDraft() {
    _livePrimary = _draftPrimary; _liveSecondary = _draftSecondary;
    _liveTertiary = _draftTertiary; _liveFontHero = _draftFontHero;
    _liveFontDisplay = _draftFontDisplay; _liveFontText = _draftFontText;
    _liveFontAccent = _draftFontAccent; _liveFontSignature = _draftFontSignature;
    _liveWordBold = _draftWordBold; _liveWordLight = _draftWordLight;
    _liveAppName = _draftAppName; _liveTagline = _draftTagline;
    _liveDomain = _draftDomain; _liveCopyright = _draftCopyright;
    _liveCanvasPersonality = _draftCanvasPersonality;
    _liveMotionIntensity = _draftMotionIntensity;
    notifyListeners();
  }

  void discardDraft() {
    _draftPrimary = _livePrimary; _draftSecondary = _liveSecondary;
    _draftTertiary = _liveTertiary; _draftFontHero = _liveFontHero;
    _draftFontDisplay = _liveFontDisplay; _draftFontText = _liveFontText;
    _draftFontAccent = _liveFontAccent; _draftFontSignature = _liveFontSignature;
    _draftWordBold = _liveWordBold; _draftWordLight = _liveWordLight;
    _draftAppName = _liveAppName; _draftTagline = _liveTagline;
    _draftDomain = _liveDomain; _draftCopyright = _liveCopyright;
    _draftCanvasPersonality = _liveCanvasPersonality;
    _draftMotionIntensity = _liveMotionIntensity;
    _discardGeneration++; // triggers section key-based rebuilds
    notifyListeners();
  }

  // ── Dev code generation ───────────────────────────────────────────────────

  String generateConfigSnippet() {
    String hex(Color c) {
      final argb = c.value.toRadixString(16).padLeft(8, '0').toUpperCase();
      return '0xFF${argb.substring(2)}';
    }
    return '''
// CONFIG BLOCK — paste into brand_config.dart, replacing the existing block
// Generated: ${DateTime.now().toIso8601String().substring(0, 16)}

const Color _kPrimary   = Color(${hex(_draftPrimary)});
const Color _kSecondary = Color(${hex(_draftSecondary)});
const Color _kTertiary  = Color(${hex(_draftTertiary)});

const String _kFontHero      = '${_draftFontHero}';
const String _kFontDisplay   = '${_draftFontDisplay}';
const String _kFontText      = '${_draftFontText}';
const String _kFontAccent    = '${_draftFontAccent}';
const String _kFontSignature = '${_draftFontSignature}';

const String _kWordBold  = '${_draftWordBold}';
const String _kWordLight = '${_draftWordLight}';
const String _kAppName   = '${_draftAppName}';
const String _kTagline   = '${_draftTagline}';
const String _kDomain    = '${_draftDomain}';
const String _kCopyright = '${_draftCopyright}';

const CanvasPersonality _kCanvasPersonality = CanvasPersonality.${_draftCanvasPersonality.name};
const MotionIntensity   _kMotionIntensity   = MotionIntensity.${_draftMotionIntensity.name};
''';
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// AdminBrandDraftScope
// ─────────────────────────────────────────────────────────────────────────────

class AdminBrandDraftScope extends InheritedNotifier<AdminBrandDraft> {
  const AdminBrandDraftScope({
    super.key,
    required AdminBrandDraft draft,
    required super.child,
  }) : super(notifier: draft);

  static AdminBrandDraft of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdminBrandDraftScope>();
    assert(scope != null, 'AdminBrandDraftScope not found. Wrap at QAdminShell level.');
    return scope!.notifier!;
  }
}