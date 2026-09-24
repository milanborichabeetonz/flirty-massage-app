import 'love_test_metric.dart';

class ChatChemistryResult {
  final int score;
  final String verdictLabel;
  final String summary;
  final double messageLengthBalance;
  final double sharedWords;
  final double questionBalance;
  final double emojiUsage;
  final double positiveWordRatio;
  final double conversationEnergy;
  final List<LoveTestMetric> metrics;

  const ChatChemistryResult({
    required this.score,
    required this.verdictLabel,
    required this.summary,
    required this.messageLengthBalance,
    required this.sharedWords,
    required this.questionBalance,
    required this.emojiUsage,
    required this.positiveWordRatio,
    required this.conversationEnergy,
    required this.metrics,
  });
}
