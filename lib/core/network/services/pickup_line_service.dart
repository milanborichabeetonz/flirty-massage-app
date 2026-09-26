import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/pickup_line_local_data.dart';
import '../models/pickup_line_model.dart';
import '../../storage/local_cache_service.dart';
import 'craft_message_service.dart';

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

  // =================================================================
  //  Unified category endpoints (merges API + AI cache + local data)
  // =================================================================

  static const int kMinCategorySize = 50;

  String _cacheKeyForCategory(String category) =>
      'unified_category_v1_${category.trim().toLowerCase()}';

  static String normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '');
  }

  List<PickupLineModel> _dedupeByNormalizedText(
    List<PickupLineModel> list,
  ) {
    final seen = <String>{};
    final result = <PickupLineModel>[];
    for (final m in list) {
      final key = normalizeText(m.text);
      if (key.isEmpty) continue;
      if (seen.add(key)) result.add(m);
    }
    return result;
  }

  List<PickupLineModel> _augmentToMinimum(
    List<PickupLineModel> current,
    String targetCategory, {
    required int minimum,
    required math.Random rng,
  }) {
    final targetNorm = targetCategory.trim().toLowerCase();
    final augmented = List<PickupLineModel>.from(current);

    final fallbackCats = <String>[
      targetCategory,
      ...PickupLineLocalData.allKnownCategories
          .where((c) => c.trim().toLowerCase() != targetNorm),
    ];

    for (final cat in fallbackCats) {
      if (augmented.length >= minimum) break;
      final locals = PickupLineLocalData.modelsForCategory(cat);
      if (locals.isEmpty) continue;
      final shuffled = List<PickupLineModel>.from(locals)..shuffle(rng);
      for (final m in shuffled) {
        if (augmented.length >= minimum) break;
        final override = PickupLineModel(
          text: m.text,
          category: targetCategory,
        );
        augmented.add(override);
      }
    }

    return _dedupeByNormalizedText(augmented);
  }

  /// Returns a unified, deduped, minimum-size list of pickup lines for a
  /// single category. Merges API lines + category-specific cached AI lines
  /// from CraftMessageService, then fills up to 50+ with curated local data.
  Future<List<PickupLineModel>> getCategoryPickupLines(
    String category, {
    bool forceRefresh = false,
  }) async {
    final normalized = category.trim();
    final isRandom =
        normalized.toLowerCase() == PickupLineLocalData.kRandom.toLowerCase();
    if (isRandom) return getRandomPickupLines(forceRefresh: forceRefresh);
    if (normalized.isEmpty) return const <PickupLineModel>[];

    final cacheKey = _cacheKeyForCategory(normalized);
    final rng = math.Random(
        normalized.toLowerCase().hashCode ^ DateTime.now().day.hashCode);

    // 1. Attempt cache (short-circuit on warm, stable reads)
    if (!forceRefresh) {
      final cached = _parseModelList(await _cache.getCache(cacheKey));
      if (cached != null &&
          cached.length >= kMinCategorySize &&
          _dedupeByNormalizedText(cached).length >= kMinCategorySize) {
        if (kDebugMode) {
          debugPrint(
              '[CACHE] Unified category cache hit for "$normalized" (${cached.length} items)');
        }
        _revalidateCategoryInBackground(normalized, cacheKey);
        return _dedupeByNormalizedText(cached);
      }
    }

    // 2. Merge sources: API + AI/craft cached lines + curated local
    final List<PickupLineModel> merged = [];

    // 2a. API lines (filter by category)
    try {
      final apiLines = await fetchPickUpLines(forceRefresh: forceRefresh);
      final key = normalized.toLowerCase();
      merged.addAll(apiLines.where((p) {
        return p.category.trim().toLowerCase() == key;
      }));
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[API] Unified: failed to fetch API lines for category: $e');
      }
    }

    // 2b. AI generated category lines via CraftMessageService (cached-first)
    try {
      final CraftMessageService craftService = CraftMessageService();
      final aiLines = await craftService.generatePickupLines(
        category: normalized,
      );
      merged.addAll(aiLines.map((text) => PickupLineModel(
            text: text,
            category: normalized,
          )));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CRAFT] Unified: AI category fetch failed: $e');
      }
    }

    // 2c. Local curated exact-category lines
    merged.addAll(PickupLineLocalData.modelsForCategory(normalized));

    // 3. Dedupe by normalized text
    var finalList = _dedupeByNormalizedText(merged);

    // 4. If still <50, augment by pulling from every known category
    if (finalList.length < kMinCategorySize) {
      finalList = _augmentToMinimum(
        finalList,
        normalized,
        minimum: kMinCategorySize,
        rng: rng,
      );
    }

    // 5. Light deterministic shuffle (stability: no per-rebuild shuffle)
    if (finalList.length >= 2) {
      final shuffle = List<PickupLineModel>.from(finalList);
      shuffle.shuffle(rng);
      finalList = shuffle;
    }

    // 6. Persist to cache
    try {
      await _cache.saveCache(
          cacheKey, finalList.map((m) => m.toJson()).toList());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CACHE] Failed to save unified category cache: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[UNIFIED] "$normalized" -> ${finalList.length} lines');
    }
    return finalList;
  }

  /// Returns a randomized, multi-category, deduped list of 50+ pickup lines.
  /// Shuffles only once per call (not on every widget rebuild).
  Future<List<PickupLineModel>> getRandomPickupLines(
      {bool forceRefresh = false}) async {
    const cacheKey = 'unified_category_v1_RANDOM';
    final rng = math.Random(DateTime.now().millisecondsSinceEpoch ~/
        1000); // stable for 1s -> not per rebuild

    // Try cache first if it has >=50 items
    if (!forceRefresh) {
      final cached = _parseModelList(await _cache.getCache(cacheKey));
      if (cached != null && cached.length >= kMinCategorySize) {
        final deduped = _dedupeByNormalizedText(cached);
        if (deduped.length >= kMinCategorySize) {
          if (kDebugMode) {
            debugPrint(
                '[CACHE] Unified Random cache hit (${deduped.length} items)');
          }
          final reroll = List<PickupLineModel>.from(deduped)..shuffle(rng);
          return reroll;
        }
      }
    }

    // Collect lines from: all API categories + each known category's local
    final pool = <PickupLineModel>[];

    try {
      final apiLines = await fetchPickUpLines(forceRefresh: forceRefresh);
      pool.addAll(apiLines);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[API] Random: API fetch failed, using local only: $e');
      }
    }

    // Also add AI-generated cached lines per known category
    final craftService = CraftMessageService();
    for (final cat in PickupLineLocalData.allKnownCategories) {
      try {
        final aiLines =
            await craftService.generatePickupLines(category: cat);
        pool.addAll(aiLines
            .map((t) => PickupLineModel(text: t, category: cat))
            .toList());
      } catch (_) {}
      // Local curated
      pool.addAll(PickupLineLocalData.modelsForCategory(cat));
    }

    var finalList = _dedupeByNormalizedText(pool);

    // Augment (should almost never be needed given we have 12 cats * 55 local)
    if (finalList.length < kMinCategorySize) {
      finalList = _augmentToMinimum(
        finalList,
        PickupLineLocalData.allKnownCategories.first,
        minimum: kMinCategorySize,
        rng: rng,
      );
    }

    // Shuffle once per call
    if (finalList.length >= 2) {
      finalList = List<PickupLineModel>.from(finalList)..shuffle(rng);
    }

    // Save cache
    try {
      await _cache.saveCache(
          cacheKey, finalList.map((m) => m.toJson()).toList());
    } catch (e) {
      if (kDebugMode) debugPrint('[CACHE] Random save failed: $e');
    }

    if (kDebugMode) {
      debugPrint('[UNIFIED] Random -> ${finalList.length} lines');
    }
    return finalList;
  }

  List<PickupLineModel>? _parseModelList(dynamic raw) {
    if (raw is! List) return null;
    try {
      return raw
          .map((e) =>
              PickupLineModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  void _revalidateCategoryInBackground(String category, String cacheKey) {
    getCategoryPickupLines(category, forceRefresh: true)
        .then((_) {})
        .catchError((e) {
      if (kDebugMode) {
        debugPrint('[CACHE] Background category revalidate failed: $e');
      }
    });
  }
}
