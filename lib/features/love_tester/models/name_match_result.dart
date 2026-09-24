import 'love_test_metric.dart';

class NameMatchResult {
  final int score;
  final String verdictLabel;
  final String summary;
  final double lengthBalance;
  final double vowelHarmony;
  final double initialMatch;
  final double nameEnergy;
  final double sharedLetters;
  final double numerology;
  final double destinyEnergy;
  final List<LoveTestMetric> metrics;

  const NameMatchResult({
    required this.score,
    required this.verdictLabel,
    required this.summary,
    required this.lengthBalance,
    required this.vowelHarmony,
    required this.initialMatch,
    required this.nameEnergy,
    required this.sharedLetters,
    required this.numerology,
    required this.destinyEnergy,
    required this.metrics,
  });
}
