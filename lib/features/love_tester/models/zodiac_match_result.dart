import 'love_test_metric.dart';

class ZodiacMatchResult {
  final String sign1;
  final String sign2;
  final String element1;
  final String element2;
  final int score;
  final String verdictLabel;
  final String summary;
  final List<LoveTestMetric> metrics;

  const ZodiacMatchResult({
    required this.sign1,
    required this.sign2,
    required this.element1,
    required this.element2,
    required this.score,
    required this.verdictLabel,
    required this.summary,
    required this.metrics,
  });
}
