import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../storage/local_cache_service.dart';
import '../models/craft_message_response.dart';

class CraftMessageService {
  Future<CraftMessageResponse> analyzeScreenshot({
    required File imageFile,
    required String instructions,
  }) async {
    final baseUrl = dotenv.env['FLIRT_COPILOT_BASE_URL'] ?? 'https://flirt-copilot.onrender.com';
    final uri = Uri.parse('$baseUrl/api/craft-message-text');

    // Read image bytes and convert to base64
    final bytes = await imageFile.readAsBytes();
    final mimeType = imageFile.path.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    final base64Image = 'data:$mimeType;base64,${base64Encode(bytes)}';

    final body = jsonEncode({
      'image': base64Image,
      'instructions': instructions.toLowerCase(),
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CraftMessageResponse.fromJson(json);
    } else {
      debugPrint('API error body: ${response.body}');
      throw Exception('API error: ${response.statusCode} — ${response.body}');
    }
  }

  Future<CraftMessageResponse> generateOpener({
    required String profileText,
    required String instructions,
    String? existingUserId,
    File? imageFile,
  }) async {
    final baseUrl =
        dotenv.env['FLIRT_COPILOT_BASE_URL'] ?? 'https://flirt-copilot.onrender.com';
    final uri = Uri.parse('$baseUrl/api/craft-message-text');

    final userId = existingUserId ?? _generateUserId();
    final requestId = _generateRequestId();

    String? base64Image;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = imageFile.path.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      base64Image = 'data:$mimeType;base64,${base64Encode(bytes)}';
    }

    final Map<String, dynamic> requestMap = {
      'userId': userId,
      'platform': 'guide',
      'requestId': requestId,
      'profileText': profileText.isNotEmpty ? profileText : 'Analyze attached image',
      'instructions': instructions.toLowerCase(),
    };

    if (base64Image != null) {
      requestMap['image'] = base64Image;
    }

    final body = jsonEncode(requestMap);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CraftMessageResponse.fromJson(json);
    } else {
      debugPrint('Opener API error: ${response.body}');
      throw Exception('API error: ${response.statusCode}');
    }
  }

  String _generateUserId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = math.Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final suffix =
        List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'visitor_${ts}_$suffix';
  }

  String _generateRequestId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = math.Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final suffix =
        List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'guide_${ts}_$suffix';
  }

  static const Map<String, String> _categoryInstructions = {
    'cute': 'cute, sweet, wholesome, short, playful and flirty pickup lines',
    'bad': 'intentionally bad, cheesy, funny and playful pickup lines',
    'cheesy': 'cheesy, playful, light-hearted and flirty pickup lines',
    'dirty': 'bold, daring, adult and flirty pickup lines',
    'romantic': 'romantic, sweet, charming and emotional pickup lines',
    'nerdy': 'nerdy, geeky, clever and funny pickup lines',
    'funny': 'funny, witty, playful and flirty pickup lines',
    'food': 'food-related, funny, playful and flirty pickup lines',
    'hookup': 'bold, direct, confident and flirty pickup lines',
    'clever': 'clever, witty, intellectual and charming pickup lines',
    'flirty': 'bold and flirty pickup lines',
    'complimentary': 'complimentary, sweet and charming pickup lines',
  };

  static String _instructionForCategory(String category) {
    return _categoryInstructions[category.trim().toLowerCase()] ??
        '${category.trim().toLowerCase()}, flirty and playful pickup lines';
  }

  /// Generates pickup lines for a category with offline-first local caching.
  Future<List<String>> generatePickupLines({
    required String category,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'pickup_lines_category_${category.trim().toLowerCase()}';
    final cache = LocalCacheService.instance;

    if (kDebugMode) {
      debugPrint('[CACHE] Reading category pickup lines for: $category');
    }

    // 1. Check local cache
    List<String>? cachedList;
    try {
      final cachedData = await cache.getCache(cacheKey);
      if (cachedData is List) {
        cachedList = cachedData.map((e) => e.toString()).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CACHE] Error reading category cache: $e');
      }
    }

    // 2. Stale-While-Revalidate if cached data exists
    if (cachedList != null && cachedList.isNotEmpty && !forceRefresh) {
      if (kDebugMode) {
        debugPrint('[CACHE] Cache hit for category: $category');
      }
      _revalidateCategoryInBackground(category, cacheKey);
      return cachedList;
    }

    // 3. Cache miss or force refresh
    return await _fetchCategoryFromApi(category, cacheKey, cachedList);
  }

  Future<List<String>> _fetchCategoryFromApi(
    String category,
    String cacheKey,
    List<String>? fallbackCache,
  ) async {
    final baseUrl =
        dotenv.env['FLIRT_COPILOT_BASE_URL'] ?? 'https://flirt-copilot.onrender.com';
    final uri = Uri.parse('$baseUrl/api/craft-message-text');
    final ts = DateTime.now().millisecondsSinceEpoch;
    final instructions = _instructionForCategory(category);

    final body = jsonEncode({
      'userId': 'visitor_flutter_$ts',
      'platform': 'guide',
      'requestId': 'guide_${category.toLowerCase()}_$ts',
      'profileText': 'Generate pickup lines for the $category category.',
      'instructions': instructions,
    });

    if (kDebugMode) {
      debugPrint('[API] Fetching category pickup lines for: $category');
    }

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = CraftMessageResponse.fromJson(json);
        if (!data.success || data.messages.isEmpty) {
          if (fallbackCache != null && fallbackCache.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('[API] Request failed, using cache');
            }
            return fallbackCache;
          }
          throw Exception('API returned success=false or empty messages');
        }

        // Save successful response to cache
        await LocalCacheService.instance.saveCache(cacheKey, data.messages);
        if (kDebugMode) {
          debugPrint('[CACHE] Cache updated for category: $category');
        }
        return data.messages;
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
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[API] Request failed for category $category: $e');
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

  void _revalidateCategoryInBackground(String category, String cacheKey) {
    _fetchCategoryFromApi(category, cacheKey, null).then((_) {
      if (kDebugMode) {
        debugPrint('[CACHE] Category revalidation succeeded for: $category');
      }
    }).catchError((e) {
      if (kDebugMode) {
        debugPrint('[API] Category revalidation failed for $category: $e');
      }
    });
  }
}
