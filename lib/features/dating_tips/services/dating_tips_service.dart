import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/dating_tip_model.dart';

class DatingTipsService {
  static const String _assetPath = 'assets/data/dating_tips.json';

  List<DatingTipModel>? _cachedTips;

  /// Loads all dating tips from local asset JSON
  Future<List<DatingTipModel>> getDatingTips({bool forceReload = false}) async {
    if (!forceReload && _cachedTips != null && _cachedTips!.isNotEmpty) {
      return _cachedTips!;
    }

    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        throw const FormatException('Expected a JSON list of dating tips');
      }

      final tips = decoded
          .map((item) => DatingTipModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _validateTips(tips);

      _cachedTips = tips;
      return tips;
    } catch (e, stack) {
      debugPrint('DatingTipsService error loading $_assetPath: $e\n$stack');
      rethrow;
    }
  }

  /// Validates requirement constraints:
  /// - Exactly 200 records
  /// - Unique IDs
  /// - Non-empty text
  /// - colorIndex between 0 and 5
  void _validateTips(List<DatingTipModel> tips) {
    if (tips.length != 200) {
      debugPrint('WARNING: Expected exactly 200 tips, but found ${tips.length}');
    }

    final idSet = <String>{};
    for (final tip in tips) {
      if (idSet.contains(tip.id)) {
        debugPrint('ERROR: Duplicate tip ID detected: "${tip.id}"');
      }
      idSet.add(tip.id);

      if (tip.text.trim().isEmpty) {
        debugPrint('ERROR: Tip ID "${tip.id}" has empty text.');
      }

      if (tip.colorIndex < 0 || tip.colorIndex > 5) {
        debugPrint(
          'ERROR: Tip ID "${tip.id}" has invalid colorIndex: ${tip.colorIndex} (expected 0..5)',
        );
      }
    }
  }
}
