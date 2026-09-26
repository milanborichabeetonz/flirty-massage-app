import 'package:flutter/foundation.dart';
import '../models/saved_chat_model.dart';
import '../storage/local_cache_service.dart';

/// Repository for persisting and retrieving saved Personalized Opener chat conversations.
class PersonalizedChatRepository {
  static const String _storageKey = 'saved_personalized_chats_v1';
  final LocalCacheService _cache = LocalCacheService.instance;

  /// Retrieves all saved chat conversations.
  Future<List<SavedChatModel>> getSavedChats() async {
    try {
      final raw = await _cache.getCache(_storageKey);
      if (raw is List) {
        final chats = <SavedChatModel>[];
        for (final item in raw) {
          try {
            if (item is! Map) continue;
            chats.add(
              SavedChatModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[CHAT REPO] Skipping unreadable saved chat: $e');
            }
          }
        }
        return chats;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CHAT REPO] Error loading saved chats: $e');
      }
    }
    return [];
  }

  /// Saves or updates a conversation in local storage.
  /// Returns true if newly created, false if updated.
  Future<bool> saveOrUpdateChat(SavedChatModel chat) async {
    final chats = await getSavedChats();
    final index = chats.indexWhere((c) => c.id == chat.id);
    bool isNew = index == -1;

    if (index >= 0) {
      chats[index] = chat;
    } else {
      chats.insert(0, chat);
    }

    final rawList = chats.map((c) => c.toJson()).toList();
    await _cache.saveCache(_storageKey, rawList);
    return isNew;
  }

  /// Checks if a conversation ID is already saved.
  Future<bool> isChatSaved(String conversationId) async {
    final chats = await getSavedChats();
    return chats.any((c) => c.id == conversationId);
  }

  /// Removes a saved chat.
  Future<bool> deleteChat(String conversationId) async {
    final chats = await getSavedChats();
    chats.removeWhere((c) => c.id == conversationId);
    final rawList = chats.map((c) => c.toJson()).toList();
    return await _cache.saveCache(_storageKey, rawList);
  }
}
