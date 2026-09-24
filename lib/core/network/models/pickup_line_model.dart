class PickupLineModel {
  final String text;
  final String category;

  PickupLineModel({
    required this.text,
    required this.category,
  });

  factory PickupLineModel.fromJson(Map<String, dynamic> json) {
    return PickupLineModel(
      text: (json['text'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'category': category,
    };
  }
}
