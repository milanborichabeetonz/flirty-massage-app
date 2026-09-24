import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_model.dart';

class FavoriteController extends GetxController {
  static const String _prefsKey = 'flirty_favorites_v1';

  final RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  // -------------------------------------------------------
  //  Persistence
  // -------------------------------------------------------

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? [];
      final loaded = raw
          .map((s) {
            try {
              return FavoriteModel.fromMap(
                  jsonDecode(s) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<FavoriteModel>()
          .toList();
      favorites.assignAll(loaded);
    } catch (e) {
      debugPrint('FavoriteController._loadFavorites error: $e');
    }
  }

  Future<void> _persistFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefsKey,
        favorites.map((f) => jsonEncode(f.toMap())).toList(),
      );
    } catch (e) {
      debugPrint('FavoriteController._persistFavorites error: $e');
    }
  }

  // -------------------------------------------------------
  //  Public API - Pickup Lines (Text-based identity)
  // -------------------------------------------------------

  bool isFavorite(String text) {
    final id = FavoriteModel.stableId(text);
    return favorites.any((f) => f.id == id && f.type != 'dating_tip');
  }

  Future<void> toggleFavorite(String text, {String category = ''}) async {
    final id = FavoriteModel.stableId(text);
    final alreadyFav = favorites.any((f) => f.id == id && f.type != 'dating_tip');
    if (alreadyFav) {
      favorites.removeWhere((f) => f.id == id && f.type != 'dating_tip');
    } else {
      favorites.add(FavoriteModel(
        text: text,
        category: category,
        id: id,
        type: 'pickup_line',
      ));
    }
    await _persistFavorites();
  }

  Future<void> removeFavorite(String text) async {
    final id = FavoriteModel.stableId(text);
    favorites.removeWhere((f) => f.id == id && f.type != 'dating_tip');
    await _persistFavorites();
  }

  // -------------------------------------------------------
  //  Public API - Dating Tips (Stable ID-based identity)
  // -------------------------------------------------------

  bool isDatingTipFavorite(String id) {
    return favorites.any((f) => f.type == 'dating_tip' && f.id == id);
  }

  Future<void> toggleDatingTipFavorite({
    required String id,
    required String text,
    required String category,
    required int colorIndex,
  }) async {
    final alreadyFav = favorites.any((f) => f.type == 'dating_tip' && f.id == id);
    if (alreadyFav) {
      favorites.removeWhere((f) => f.type == 'dating_tip' && f.id == id);
    } else {
      favorites.add(FavoriteModel(
        text: text,
        category: category,
        id: id,
        type: 'dating_tip',
        colorIndex: colorIndex,
      ));
    }
    await _persistFavorites();
  }

  List<FavoriteModel> get datingTipFavorites =>
      favorites.where((f) => f.type == 'dating_tip').toList();

  int get datingTipFavoriteCount =>
      favorites.where((f) => f.type == 'dating_tip').length;

  // -------------------------------------------------------
  //  Convenience accessor
  // -------------------------------------------------------

  static FavoriteController get to => Get.find<FavoriteController>();
}
