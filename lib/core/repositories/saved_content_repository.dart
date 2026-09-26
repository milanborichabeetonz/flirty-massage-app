import 'package:flutter/foundation.dart';
import '../../features/love_tester/models/love_test_result.dart';
import '../models/favorite_model.dart';
import '../storage/local_cache_service.dart';

class SavedScreenshotAnalysis {
  final String id;
  final String? imagePath;
  final String tone;
  final String timestamp;
  final List<String> messages;
  final String? recipientName;
  final String? situation;
  final int? processingTime;

  SavedScreenshotAnalysis({
    required this.id,
    this.imagePath,
    required this.tone,
    required this.timestamp,
    required this.messages,
    this.recipientName,
    this.situation,
    this.processingTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'tone': tone,
        'timestamp': timestamp,
        'messages': messages,
        'recipientName': recipientName,
        'situation': situation,
        'processingTime': processingTime,
      };

  factory SavedScreenshotAnalysis.fromJson(Map<String, dynamic> json) {
    return SavedScreenshotAnalysis(
      id: json['id'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      tone: json['tone'] as String? ?? 'Funny',
      timestamp: json['timestamp'] as String? ?? '',
      messages:
          (json['messages'] as List? ?? []).map((e) => e.toString()).toList(),
      recipientName: json['recipientName'] as String?,
      situation: json['situation'] as String?,
      processingTime: json['processingTime'] as int?,
    );
  }
}

/// Locally saved pickup line card — stores exactly what PickupLineModel holds
/// (text + category, enough to recreate the card) plus a stable id and timestamp.
class SavedPickupLine {
  final String id;
  final String text;
  final String category;
  final String savedAt;

  const SavedPickupLine({
    required this.id,
    required this.text,
    required this.category,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'category': category,
        'savedAt': savedAt,
      };

  factory SavedPickupLine.fromJson(Map<String, dynamic> json) =>
      SavedPickupLine(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        category: json['category'] as String? ?? '',
        savedAt: json['savedAt'] as String? ?? '',
      );
}

/// Repository for persisting and retrieving saved Love Tester results, Screenshot Analyses,
/// and Pickup Lines.
class SavedContentRepository {
  static const String _loveTestKey = 'saved_love_tests_v1';
  static const String _screenshotKey = 'saved_screenshot_analyses_v1';
  static const String _pickupLineKey = 'saved_pickup_lines_v1';
  final LocalCacheService _cache = LocalCacheService.instance;

  // ── Love Test Results ────────────────────────────────────────

  String getLoveTestId(LoveTestResult r) {
    return 'lovetest_${r.yourName.trim().toLowerCase()}_${r.theirName.trim().toLowerCase()}_${r.testType}';
  }

  Future<List<LoveTestResult>> getSavedLoveTests() async {
    try {
      final raw = await _cache.getCache(_loveTestKey);
      if (raw is List) {
        return raw
            .map((item) =>
                loveTestResultFromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SAVED REPO] Error loading saved love tests: $e');
      }
    }
    return [];
  }

  Future<bool> saveOrUpdateLoveTest(LoveTestResult result) async {
    final tests = await getSavedLoveTests();
    final id = getLoveTestId(result);
    final index = tests.indexWhere((t) => getLoveTestId(t) == id);
    bool isNew = index == -1;

    if (index >= 0) {
      tests[index] = result;
    } else {
      tests.insert(0, result);
    }

    final rawList = tests.map((t) => loveTestResultToJson(t)).toList();
    await _cache.saveCache(_loveTestKey, rawList);
    return isNew;
  }

  Future<bool> isLoveTestSaved(LoveTestResult result) async {
    final tests = await getSavedLoveTests();
    final id = getLoveTestId(result);
    return tests.any((t) => getLoveTestId(t) == id);
  }

  Future<bool> deleteLoveTest(LoveTestResult result) async {
    final tests = await getSavedLoveTests();
    final id = getLoveTestId(result);
    tests.removeWhere((t) => getLoveTestId(t) == id);
    final rawList = tests.map((t) => loveTestResultToJson(t)).toList();
    return await _cache.saveCache(_loveTestKey, rawList);
  }

  // ── Screenshot Analyses ──────────────────────────────────────

  Future<List<SavedScreenshotAnalysis>> getSavedScreenshotAnalyses() async {
    try {
      final raw = await _cache.getCache(_screenshotKey);
      if (raw is List) {
        return raw
            .map((item) => SavedScreenshotAnalysis.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SAVED REPO] Error loading saved screenshot analyses: $e');
      }
    }
    return [];
  }

  Future<bool> saveOrUpdateScreenshotAnalysis(
      SavedScreenshotAnalysis analysis) async {
    final items = await getSavedScreenshotAnalyses();
    final index = items.indexWhere((item) => item.id == analysis.id);
    bool isNew = index == -1;

    if (index >= 0) {
      items[index] = analysis;
    } else {
      items.insert(0, analysis);
    }

    final rawList = items.map((item) => item.toJson()).toList();
    await _cache.saveCache(_screenshotKey, rawList);
    return isNew;
  }

  Future<bool> isScreenshotAnalysisSaved(String id) async {
    final items = await getSavedScreenshotAnalyses();
    return items.any((item) => item.id == id);
  }

  Future<bool> deleteScreenshotAnalysis(String id) async {
    final items = await getSavedScreenshotAnalyses();
    items.removeWhere((item) => item.id == id);
    final rawList = items.map((item) => item.toJson()).toList();
    return await _cache.saveCache(_screenshotKey, rawList);
  }

  // ── Pickup Lines ─────────────────────────────────────────────

  /// Stable id derived from the line's text (reuses FavoriteModel.stableId).
  String getPickupLineId(String text) =>
      'pickupline_${FavoriteModel.stableId(text)}';

  Future<List<SavedPickupLine>> getSavedPickupLines() async {
    try {
      final raw = await _cache.getCache(_pickupLineKey);
      if (raw is List) {
        final lines = <SavedPickupLine>[];
        for (final item in raw) {
          try {
            lines.add(SavedPickupLine.fromJson(
                Map<String, dynamic>.from(item as Map)));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[SAVED REPO] Skipping unreadable saved pickup line: $e');
            }
          }
        }
        return lines;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SAVED REPO] Error loading saved pickup lines: $e');
      }
    }
    return [];
  }

  /// Saves a pickup line. Returns true when a new record was created,
  /// false when the line was already saved (no duplicates are created).
  Future<bool> savePickupLine({
    required String text,
    required String category,
  }) async {
    final lines = await getSavedPickupLines();
    final id = getPickupLineId(text);
    final exists = lines.any((l) => l.id == id);
    if (exists) return false;

    lines.insert(
      0,
      SavedPickupLine(
        id: id,
        text: text,
        category: category,
        savedAt: DateTime.now().toIso8601String(),
      ),
    );
    await _cache.saveCache(_pickupLineKey, lines.map((l) => l.toJson()).toList());
    return true;
  }

  Future<bool> isPickupLineSaved(String text) async {
    final lines = await getSavedPickupLines();
    final id = getPickupLineId(text);
    return lines.any((l) => l.id == id);
  }

  Future<bool> removeSavedPickupLine(String text) async {
    final lines = await getSavedPickupLines();
    final id = getPickupLineId(text);
    lines.removeWhere((l) => l.id == id);
    return await _cache.saveCache(
        _pickupLineKey, lines.map((l) => l.toJson()).toList());
  }

  // ── Serialization Helpers ────────────────────────────────────

  Map<String, dynamic> loveTestResultToJson(LoveTestResult r) {
    final id = getLoveTestId(r);
    return {
      'id': id,
      'yourName': r.yourName,
      'theirName': r.theirName,
      'testType': r.testType,
      'category': r.category,
      'score': r.score,
      'verdictLabel': r.verdictLabel,
      'summary': r.summary,
      'metrics': _metricsToJson(r.metrics),
      'allTests': r.allTests != null
          ? {
              'overallScore': r.allTests!.overallScore,
              'nameMatch': {
                'score': r.allTests!.nameMatch.score,
                'verdictLabel': r.allTests!.nameMatch.verdictLabel,
                'summary': r.allTests!.nameMatch.summary,
                'lengthBalance': r.allTests!.nameMatch.lengthBalance,
                'vowelHarmony': r.allTests!.nameMatch.vowelHarmony,
                'initialMatch': r.allTests!.nameMatch.initialMatch,
                'nameEnergy': r.allTests!.nameMatch.nameEnergy,
                'sharedLetters': r.allTests!.nameMatch.sharedLetters,
                'numerology': r.allTests!.nameMatch.numerology,
                'destinyEnergy': r.allTests!.nameMatch.destinyEnergy,
                'metrics': _metricsToJson(r.allTests!.nameMatch.metrics),
              },
              'zodiacMatch': {
                'sign1': r.allTests!.zodiacMatch.sign1,
                'sign2': r.allTests!.zodiacMatch.sign2,
                'element1': r.allTests!.zodiacMatch.element1,
                'element2': r.allTests!.zodiacMatch.element2,
                'score': r.allTests!.zodiacMatch.score,
                'verdictLabel': r.allTests!.zodiacMatch.verdictLabel,
                'summary': r.allTests!.zodiacMatch.summary,
                'metrics': _metricsToJson(r.allTests!.zodiacMatch.metrics),
              },
              'chatChemistry': {
                'score': r.allTests!.chatChemistry.score,
                'verdictLabel': r.allTests!.chatChemistry.verdictLabel,
                'summary': r.allTests!.chatChemistry.summary,
                'messageLengthBalance':
                    r.allTests!.chatChemistry.messageLengthBalance,
                'sharedWords': r.allTests!.chatChemistry.sharedWords,
                'questionBalance': r.allTests!.chatChemistry.questionBalance,
                'emojiUsage': r.allTests!.chatChemistry.emojiUsage,
                'positiveWordRatio':
                    r.allTests!.chatChemistry.positiveWordRatio,
                'conversationEnergy':
                    r.allTests!.chatChemistry.conversationEnergy,
                'metrics': _metricsToJson(r.allTests!.chatChemistry.metrics),
              },
              'personalityMatch': {
                'score': r.allTests!.personalityMatch.score,
                'verdictLabel': r.allTests!.personalityMatch.verdictLabel,
                'summary': r.allTests!.personalityMatch.summary,
                'traitScores': r.allTests!.personalityMatch.traitScores,
                'metrics': _metricsToJson(r.allTests!.personalityMatch.metrics),
              },
            }
          : null,
    };
  }

  LoveTestResult loveTestResultFromJson(Map<String, dynamic> json) {
    final metrics = _metricsFromJson(json['metrics']);

    AllTestsResult? allTests;
    if (json['allTests'] != null) {
      final rawAll = Map<String, dynamic>.from(json['allTests'] as Map);
      final nm = Map<String, dynamic>.from(rawAll['nameMatch'] as Map? ?? {});
      final zm = Map<String, dynamic>.from(rawAll['zodiacMatch'] as Map? ?? {});
      final cm =
          Map<String, dynamic>.from(rawAll['chatChemistry'] as Map? ?? {});
      final pm =
          Map<String, dynamic>.from(rawAll['personalityMatch'] as Map? ?? {});

      allTests = AllTestsResult(
        overallScore: rawAll['overallScore'] as int? ?? 0,
        nameMatch: NameMatchResult(
          score: nm['score'] as int? ?? 0,
          verdictLabel: nm['verdictLabel'] as String? ?? '',
          summary: nm['summary'] as String? ?? '',
          lengthBalance: _readDouble(nm, 'lengthBalance'),
          vowelHarmony: _readDouble(nm, 'vowelHarmony'),
          initialMatch: _readDouble(nm, 'initialMatch'),
          nameEnergy: _readDouble(nm, 'nameEnergy'),
          sharedLetters: _readDouble(nm, 'sharedLetters'),
          numerology: _readDouble(nm, 'numerology'),
          destinyEnergy: _readDouble(nm, 'destinyEnergy'),
          metrics: _metricsFromJson(nm['metrics']),
        ),
        zodiacMatch: ZodiacMatchResult(
          sign1: zm['sign1'] as String? ?? '',
          sign2: zm['sign2'] as String? ?? '',
          element1: zm['element1'] as String? ?? '',
          element2: zm['element2'] as String? ?? '',
          score: zm['score'] as int? ?? 0,
          verdictLabel: zm['verdictLabel'] as String? ?? '',
          summary: zm['summary'] as String? ?? '',
          metrics: _metricsFromJson(zm['metrics']),
        ),
        chatChemistry: ChatChemistryResult(
          score: cm['score'] as int? ?? 0,
          verdictLabel: cm['verdictLabel'] as String? ?? '',
          summary: cm['summary'] as String? ?? '',
          messageLengthBalance: _readDouble(cm, 'messageLengthBalance'),
          sharedWords: _readDouble(cm, 'sharedWords'),
          questionBalance: _readDouble(cm, 'questionBalance'),
          emojiUsage: _readDouble(cm, 'emojiUsage'),
          positiveWordRatio: _readDouble(cm, 'positiveWordRatio'),
          conversationEnergy: _readDouble(cm, 'conversationEnergy'),
          metrics: _metricsFromJson(cm['metrics']),
        ),
        personalityMatch: PersonalityMatchResult(
          score: pm['score'] as int? ?? 0,
          verdictLabel: pm['verdictLabel'] as String? ?? '',
          summary: pm['summary'] as String? ?? '',
          traitScores: _readTraitScores(pm['traitScores']),
          metrics: _metricsFromJson(pm['metrics']),
        ),
      );
    }

    return LoveTestResult(
      yourName: json['yourName'] as String? ?? '',
      theirName: json['theirName'] as String? ?? '',
      testType: json['testType'] as String? ?? 'name',
      category: json['category'] as String? ?? 'Romantic',
      score: json['score'] as int? ?? 0,
      verdictLabel: json['verdictLabel'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      metrics: metrics,
      allTests: allTests,
    );
  }

  static List<Map<String, dynamic>> _metricsToJson(List<LoveTestMetric> metrics) {
    return metrics
        .map((m) => {'label': m.label, 'value': m.value})
        .toList();
  }

  static List<LoveTestMetric> _metricsFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return LoveTestMetric(
        label: map['label'] as String? ?? '',
        value: (map['value'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  static double _readDouble(Map<String, dynamic> map, String key) {
    return (map[key] as num?)?.toDouble() ?? 0.0;
  }

  static Map<String, double> _readTraitScores(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) =>
        MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0));
  }
}
