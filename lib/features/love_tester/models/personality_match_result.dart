import 'love_test_metric.dart';

class PersonalityMatchResult {
  final int score;
  final String verdictLabel;
  final String summary;
  final Map<String, double> traitScores;
  final List<LoveTestMetric> metrics;

  const PersonalityMatchResult({
    required this.score,
    required this.verdictLabel,
    required this.summary,
    required this.traitScores,
    required this.metrics,
  });
}
