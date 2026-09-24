class DatingTipModel {
  final String id;
  final String text;
  final String category;
  final int colorIndex;

  const DatingTipModel({
    required this.id,
    required this.text,
    required this.category,
    required this.colorIndex,
  });

  factory DatingTipModel.fromJson(Map<String, dynamic> json) {
    return DatingTipModel(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      colorIndex: (json['colorIndex'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'colorIndex': colorIndex,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatingTipModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
