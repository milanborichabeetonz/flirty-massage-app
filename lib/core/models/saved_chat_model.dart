import 'dart:io';

/// Data model representing a locally saved Personalized Openers chat conversation.
class SavedChatModel {
  final String id;
  final String name;
  final String interests;
  final String tone;
  final String userId;
  final String updatedAt;
  final List<Map<String, dynamic>> chatHistory;

  SavedChatModel({
    required this.id,
    required this.name,
    required this.interests,
    required this.tone,
    required this.userId,
    required this.updatedAt,
    required this.chatHistory,
  });

  /// Converts JSON-decoded lists (`List<dynamic>`) into `List<String>`.
  static List<String> stringListFrom(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((item) => item.toString()).toList();
  }

  static String _stringOf(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  /// Normalizes a stored history entry so UI code can use typed values.
  static Map<String, dynamic> normalizeHistoryItem(dynamic item) {
    if (item is! Map) {
      return <String, dynamic>{'type': 'error', 'text': ''};
    }

    final map = Map<String, dynamic>.from(item);

    if (map.containsKey('messages') || map['type'] == 'ai') {
      map['messages'] = stringListFrom(map['messages']);
    }

    for (final key in ['type', 'text', 'name', 'interests', 'tone']) {
      if (map.containsKey(key) && map[key] != null && map[key] is! String) {
        map[key] = map[key].toString();
      }
    }

    final imagePath = map['imagePath']?.toString() ?? '';
    if (imagePath.isNotEmpty) {
      map['imagePath'] = imagePath;
      map['image'] = File(imagePath);
    }

    return map;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'interests': interests,
        'tone': tone,
        'userId': userId,
        'updatedAt': updatedAt,
        'chatHistory': chatHistory.map((item) {
          final copy = Map<String, dynamic>.from(item);
          if (copy['image'] is File) {
            copy['imagePath'] = (copy['image'] as File).path;
            copy.remove('image');
          }
          if (copy.containsKey('messages')) {
            copy['messages'] = stringListFrom(copy['messages']);
          }
          return copy;
        }).toList(),
      };

  factory SavedChatModel.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['chatHistory'] as List? ?? [];
    final history = rawHistory.map(normalizeHistoryItem).toList();

    return SavedChatModel(
      id: _stringOf(json['id']),
      name: _stringOf(json['name']),
      interests: _stringOf(json['interests']),
      tone: _stringOf(json['tone']),
      userId: _stringOf(json['userId']),
      updatedAt: _stringOf(json['updatedAt']),
      chatHistory: history,
    );
  }
}
