import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Common offline-first local cache service.
/// Provides structured persistence for JSON objects, JSON lists, models, and metadata.
class LocalCacheService {
  static LocalCacheService? _instance;
  SharedPreferences? _prefs;

  LocalCacheService._();

  static LocalCacheService get instance {
    _instance ??= LocalCacheService._();
    return _instance!;
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Saves raw JSON data (List or Map) with metadata (`cachedAt` ISO timestamp).
  Future<bool> saveCache(String key, dynamic data) async {
    try {
      final prefs = await _getPrefs();
      final payload = jsonEncode({
        'cachedAt': DateTime.now().toIso8601String(),
        'data': data,
      });
      final success = await prefs.setString(key, payload);
      if (kDebugMode) {
        debugPrint('[CACHE] Saved cache for key: $key');
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CACHE] Error saving cache for key $key: $e');
      }
      return false;
    }
  }

  /// Retrieves cached data if present and valid.
  Future<dynamic> getCache(String key) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) {
        if (kDebugMode) {
          debugPrint('[CACHE] Cache miss for key: $key');
        }
        return null;
      }

      final Map<String, dynamic> decoded = jsonDecode(raw);
      if (kDebugMode) {
        final cachedAt = decoded['cachedAt'];
        debugPrint('[CACHE] Cache hit for key: $key (cachedAt: $cachedAt)');
      }
      return decoded['data'];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CACHE] Error reading cache for key $key: $e');
      }
      return null;
    }
  }

  /// Checks if valid cache exists for key.
  Future<bool> hasCache(String key) async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  /// Removes cache entry for a given key.
  Future<bool> removeCache(String key) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.remove(key);
    } catch (_) {
      return false;
    }
  }

  /// Clears all local cache entries.
  Future<bool> clearAll() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.clear();
    } catch (_) {
      return false;
    }
  }
}
