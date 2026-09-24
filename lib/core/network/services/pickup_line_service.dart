import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../storage/local_cache_service.dart';
import '../models/pickup_line_model.dart';

class PickupLineService {
  static const String _cacheKey = 'pickup_lines_all';
  final LocalCacheService _cache = LocalCacheService.instance;

  /// Fetches pickup lines offline-first:
  /// 1. Reads local cache if available.
  /// 2. Immediately returns cached lines if present and revalidates via API in background.
  /// 3. If cache miss, calls API directly, saves response to cache, and returns data.
  /// 4. If API fails and cache exists, returns cached data safely without throwing an error.
  Future<List<PickupLineModel>> fetchPickUpLines({bool forceRefresh = false}) async {
    if (kDebugMode) {
      debugPrint('[CACHE] Reading pickup lines');
    }

    // 1. Attempt to read from local cache
    List<PickupLineModel>? cachedList;
    try {
      final cachedData = await _cache.getCache(_cacheKey);
      if (cachedData is List) {
        cachedList = cachedData
            .map((item) => PickupLineModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CACHE] Failed to parse cached pickup lines: $e');
      }
    }

    // 2. Stale-While-Revalidate: If valid cache exists and forceRefresh is false
    if (cachedList != null && cachedList.isNotEmpty && !forceRefresh) {
      if (kDebugMode) {
        debugPrint('[CACHE] Cache hit: Returning ${cachedList.length} cached pickup lines');
      }
      // Revalidate in background to fetch fresh data
      _revalidateApiInBackground();
      return cachedList;
    }

    // 3. Cache miss or forceRefresh -> Call API
    return await _fetchAndCache(cachedList);
  }

  Future<List<PickupLineModel>> _fetchAndCache(List<PickupLineModel>? fallbackCache) async {
    if (kDebugMode) {
      debugPrint('[API] Fetching pickup lines');
    }

    try {
      final url = 'https://rizzapi.vercel.app';
      final uri = Uri.parse('$url/list');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List;
        final list = data
            .map((json) => PickupLineModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        // Save fresh API data to local cache
        await _cache.saveCache(_cacheKey, data);
        if (kDebugMode) {
          debugPrint('[CACHE] Pickup lines saved/updated in cache (${list.length} items)');
        }
        return list;
      } else {
        if (kDebugMode) {
          debugPrint('[API] Request failed with status code ${response.statusCode}');
        }
        if (fallbackCache != null && fallbackCache.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('[API] Request failed, using cache');
          }
          return fallbackCache;
        }
        throw Exception('Failed to load pickup lines');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[API] Request failed, error: $e');
      }
      if (fallbackCache != null && fallbackCache.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[API] Request failed, using cache');
        }
        return fallbackCache;
      }
      rethrow;
    }
  }

  void _revalidateApiInBackground() {
    _fetchAndCache(null).then((_) {
      if (kDebugMode) {
        debugPrint('[CACHE] Background revalidation succeeded');
      }
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint('[API] Request failed, using cache: $e');
      }
    });
  }
}
