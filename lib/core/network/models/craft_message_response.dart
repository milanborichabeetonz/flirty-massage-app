class CraftMessageResponse {
  final bool success;
  final List<String> messages;
  final String? recipientName;
  final String? situation;
  final String? mode;
  final String? detectedMode;
  final int? processingTime;
  final int? messageId;
  final String? userId;

  CraftMessageResponse({
    required this.success,
    required this.messages,
    this.recipientName,
    this.situation,
    this.mode,
    this.detectedMode,
    this.processingTime,
    this.messageId,
    this.userId,
  });

  factory CraftMessageResponse.fromJson(Map<String, dynamic> json) {
    return CraftMessageResponse(
      success: json['success'] as bool? ?? false,
      messages: List<String>.from(json['messages'] ?? []),
      recipientName: json['recipient_name'] as String?,
      situation: json['situation'] as String?,
      mode: json['mode'] as String?,
      detectedMode: json['detectedMode'] as String?,
      processingTime: json['processingTime'] as int?,
      messageId: json['messageId'] as int?,
      userId: json['userId'] as String?,
    );
  }
}
