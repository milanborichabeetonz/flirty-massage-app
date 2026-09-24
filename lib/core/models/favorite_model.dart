import 'dart:convert';

class FavoriteModel {
  final String text;
  final String category;
  final String id;
  final String type; // 'pickup_line' | 'dating_tip'
  final int? colorIndex;

  const FavoriteModel({
    required this.text,
    required this.category,
    required this.id,
    this.type = 'pickup_line',
    this.colorIndex,
  });

  /// Stable identity based on text content (used for pickup lines)
  static String stableId(String text) =>
      text.trim().toLowerCase().hashCode.toString();

  Map<String, dynamic> toMap() => {
        'text': text,
        'category': category,
        'id': id,
        'type': type,
        if (colorIndex != null) 'colorIndex': colorIndex,
      };

  factory FavoriteModel.fromMap(Map<String, dynamic> map) => FavoriteModel(
        text: (map['text'] as String?) ?? '',
        category: (map['category'] as String?) ?? '',
        id: (map['id'] as String?) ?? '',
        type: (map['type'] as String?) ?? 'pickup_line',
        colorIndex: map['colorIndex'] as int?,
      );

  String toJson() => jsonEncode(toMap());

  factory FavoriteModel.fromJson(String source) =>
      FavoriteModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
