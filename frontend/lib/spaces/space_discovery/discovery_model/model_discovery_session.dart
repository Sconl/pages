// frontend/lib/spaces/space_discovery/discovery_model/model_discovery_session.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A tenant space the user has previously visited in the QPages mobile app.
/// Persisted locally across app restarts via SharedPreferences.
class SavedTenantSpace {
  final String tenantId;
  final String displayName;  // brand name at time of visit (from BrandConfig.appName)
  final String? iconUrl;     // brand icon URL at time of visit (from BrandConfig.logo.icon)
  final DateTime lastVisited;

  const SavedTenantSpace({
    required this.tenantId,
    required this.displayName,
    this.iconUrl,
    required this.lastVisited,
  });

  Map<String, dynamic> toJson() => {
    'tenantId':    tenantId,
    'displayName': displayName,
    'iconUrl':     iconUrl,
    'lastVisited': lastVisited.toIso8601String(),
  };

  factory SavedTenantSpace.fromJson(Map<String, dynamic> json) =>
      SavedTenantSpace(
        tenantId:    json['tenantId'] as String,
        displayName: json['displayName'] as String,
        iconUrl:     json['iconUrl'] as String?,
        lastVisited: DateTime.parse(json['lastVisited'] as String),
      );
}

/// Manages the list of recently visited tenant spaces.
/// Max 5 saved spaces — oldest evicted when limit is exceeded.
/// Stored as JSON in SharedPreferences under key 'discovery_recent_spaces'.
class DiscoverySession {
  static const _key     = 'discovery_recent_spaces';
  static const _maxSaved = 5;

  static Future<List<SavedTenantSpace>> getRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getStringList(_key) ?? [];
      return raw
          .map((s) => SavedTenantSpace.fromJson(jsonDecode(s)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveVisit(SavedTenantSpace space) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final current = await getRecent();

      // Remove existing entry for this tenantId (deduplication)
      final deduped = current
          .where((s) => s.tenantId != space.tenantId)
          .toList();

      // Prepend new visit, trim to max
      final updated = [space, ...deduped].take(_maxSaved).toList();

      await prefs.setStringList(
        _key,
        updated.map((s) => jsonEncode(s.toJson())).toList(),
      );
    } catch (_) {
      // Non-fatal — discovery still works, just without persistence
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}