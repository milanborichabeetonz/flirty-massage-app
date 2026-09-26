import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/models/saved_chat_model.dart';
import 'package:flirtymessages/core/repositories/personalized_chat_repository.dart';
import 'package:flirtymessages/core/storage/local_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.instance
        .removeCache('saved_personalized_chats_v1');
  });

  group('PersonalizedChatRepository Tests', () {
    test('Saves and retrieves a chat conversation', () async {
      final repository = PersonalizedChatRepository();

      final chat = SavedChatModel(
        id: 'chat_sujal_123',
        name: 'Sujal',
        interests: 'Romantic',
        tone: 'Romantic',
        userId: 'visitor_123',
        updatedAt: DateTime.now().toIso8601String(),
        chatHistory: [
          {'type': 'user_context', 'name': 'Sujal', 'interests': 'Romantic', 'tone': 'Romantic'},
          {'type': 'ai', 'messages': ['Are you a camera? Because every time I look at you, I smile.']},
        ],
      );

      final isNew = await repository.saveOrUpdateChat(chat);
      expect(isNew, isTrue);

      expect(await repository.isChatSaved('chat_sujal_123'), isTrue);

      final savedChats = await repository.getSavedChats();
      expect(savedChats.length, equals(1));
      expect(savedChats[0].name, equals('Sujal'));
      expect(savedChats[0].chatHistory.length, equals(2));
    });

    test('Updating existing chat does not create duplicate entries', () async {
      final repository = PersonalizedChatRepository();

      final chat1 = SavedChatModel(
        id: 'chat_sujal_123',
        name: 'Sujal',
        interests: 'Romantic',
        tone: 'Romantic',
        userId: 'visitor_123',
        updatedAt: DateTime.now().toIso8601String(),
        chatHistory: [
          {'type': 'user_context', 'name': 'Sujal', 'interests': 'Romantic', 'tone': 'Romantic'},
        ],
      );

      await repository.saveOrUpdateChat(chat1);

      final chat2 = SavedChatModel(
        id: 'chat_sujal_123',
        name: 'Sujal',
        interests: 'Romantic',
        tone: 'Romantic',
        userId: 'visitor_123',
        updatedAt: DateTime.now().toIso8601String(),
        chatHistory: [
          {'type': 'user_context', 'name': 'Sujal', 'interests': 'Romantic', 'tone': 'Romantic'},
          {'type': 'user_message', 'text': 'Can you make it funnier?'},
          {'type': 'ai', 'messages': ['I must be a snowflake, because I fell for you!']},
        ],
      );

      final isNew = await repository.saveOrUpdateChat(chat2);
      expect(isNew, isFalse);

      final savedChats = await repository.getSavedChats();
      expect(savedChats.length, equals(1));
      expect(savedChats[0].chatHistory.length, equals(3));
    });

    test('fromJson converts JSON List<dynamic> messages to List<String>', () {
      final decoded = jsonDecode(jsonEncode({
        'id': 'chat_old_1',
        'name': 'Alex',
        'interests': 'Music',
        'tone': 'Flirty',
        'userId': 'visitor_old',
        'updatedAt': '2026-01-01T00:00:00.000',
        'chatHistory': [
          {
            'type': 'user_context',
            'name': 'Alex',
            'interests': 'Music',
            'tone': 'Flirty',
          },
          {
            'type': 'ai',
            'messages': ['Hey there', 'Want to grab coffee?'],
          },
          {
            'type': 'user_message',
            'text': 'Make it bolder',
          },
        ],
      })) as Map<String, dynamic>;

      final model = SavedChatModel.fromJson(decoded);
      final messages = model.chatHistory[1]['messages'];

      expect(messages, isA<List<String>>());
      expect(messages, equals(['Hey there', 'Want to grab coffee?']));
      expect(model.chatHistory.length, equals(3));
    });

    test('fromJson handles missing or null messages without crashing', () {
      final model = SavedChatModel.fromJson({
        'id': 'chat_sparse',
        'name': 'Sam',
        'interests': 'Travel',
        'tone': 'Soft',
        'userId': 'visitor_sparse',
        'updatedAt': '',
        'chatHistory': [
          {'type': 'ai'},
          {'type': 'ai', 'messages': null},
          {'type': 'ai', 'messages': []},
        ],
      });

      expect(model.chatHistory[0]['messages'], isA<List<String>>());
      expect(model.chatHistory[0]['messages'], isEmpty);
      expect(model.chatHistory[1]['messages'], isEmpty);
      expect(model.chatHistory[2]['messages'], isEmpty);
    });

    test('round-trip save preserves message list types after decode', () async {
      final repository = PersonalizedChatRepository();
      final original = SavedChatModel(
        id: 'chat_roundtrip',
        name: 'Riley',
        interests: 'Coffee',
        tone: 'Funny',
        userId: 'visitor_roundtrip',
        updatedAt: DateTime.now().toIso8601String(),
        chatHistory: [
          {'type': 'ai', 'messages': ['Are you a parking ticket?']},
        ],
      );

      await repository.saveOrUpdateChat(original);
      final loaded = await repository.getSavedChats();

      expect(loaded.length, equals(1));
      expect(loaded[0].id, equals('chat_roundtrip'));
      expect(loaded[0].chatHistory[0]['messages'], isA<List<String>>());
      expect(
        loaded[0].chatHistory[0]['messages'],
        equals(['Are you a parking ticket?']),
      );
    });
  });
}
