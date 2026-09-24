import 'love_test_metric.dart';
import 'name_match_result.dart';
import 'zodiac_match_result.dart';
import 'chat_chemistry_result.dart';
import 'personality_match_result.dart';

export 'love_test_metric.dart';
export 'name_match_result.dart';
export 'zodiac_match_result.dart';
export 'chat_chemistry_result.dart';
export 'personality_match_result.dart';

/// Base / unified result passed to the result screen
class LoveTestResult {
  final String yourName;
  final String theirName;
  final String testType; // "name" | "zodiac" | "chat" | "personality" | "all"
  final String category; // e.g. "Romantic", "Flirty", "Funny", "First Date", etc.
  final int score; // 50–100
  final String verdictLabel;
  final String summary;
  final List<LoveTestMetric> metrics;
  final AllTestsResult? allTests;

  const LoveTestResult({
    required this.yourName,
    required this.theirName,
    required this.testType,
    this.category = 'Romantic',
    required this.score,
    required this.verdictLabel,
    required this.summary,
    required this.metrics,
    this.allTests,
  });
}

/// Container for when all 4 tests are calculated
class AllTestsResult {
  final NameMatchResult nameMatch;
  final ZodiacMatchResult zodiacMatch;
  final ChatChemistryResult chatChemistry;
  final PersonalityMatchResult personalityMatch;
  final int overallScore;

  const AllTestsResult({
    required this.nameMatch,
    required this.zodiacMatch,
    required this.chatChemistry,
    required this.personalityMatch,
    required this.overallScore,
  });
}
