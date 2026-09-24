import '../models/love_test_result.dart';
import 'name_match_service.dart';
import 'zodiac_match_service.dart';
import 'chat_chemistry_service.dart';
import 'personality_match_service.dart';

export 'deterministic_random.dart';
export 'stable_hash.dart';
export 'name_match_service.dart';
export 'zodiac_match_service.dart';
export 'chat_chemistry_service.dart';
export 'personality_match_service.dart';

/// Unified Love Tester Service providing local, deterministic calculations
class LoveTesterService {
  final NameMatchService nameMatchService;
  final ZodiacMatchService zodiacMatchService;
  final ChatChemistryService chatChemistryService;
  final PersonalityMatchService personalityMatchService;

  LoveTesterService({
    NameMatchService? nameMatchService,
    ZodiacMatchService? zodiacMatchService,
    ChatChemistryService? chatChemistryService,
    PersonalityMatchService? personalityMatchService,
  })  : nameMatchService = nameMatchService ?? NameMatchService(),
        zodiacMatchService = zodiacMatchService ?? ZodiacMatchService(),
        chatChemistryService = chatChemistryService ?? ChatChemistryService(),
        personalityMatchService =
            personalityMatchService ?? PersonalityMatchService();

  NameMatchResult calculateNameMatch(String yourName, String theirName) {
    return nameMatchService.calculate(yourName, theirName);
  }

  ZodiacMatchResult calculateZodiacMatch(DateTime dob1, DateTime dob2) {
    return zodiacMatchService.calculate(dob1, dob2);
  }

  ChatChemistryResult calculateChatChemistry(String msg1, String msg2) {
    return chatChemistryService.calculate(msg1, msg2);
  }

  PersonalityMatchResult calculatePersonalityMatch(
    List<int> answers1,
    List<int> answers2,
  ) {
    return personalityMatchService.calculate(answers1, answers2);
  }

  /// Calculates all 4 tests and compiles an AllTestsResult
  LoveTestResult calculateAllTests({
    required String yourName,
    required String theirName,
    required DateTime dob1,
    required DateTime dob2,
    required String msg1,
    required String msg2,
    required List<int> answers1,
    required List<int> answers2,
  }) {
    final nameRes = calculateNameMatch(yourName, theirName);
    final zodiacRes = calculateZodiacMatch(dob1, dob2);
    final chatRes = calculateChatChemistry(msg1, msg2);
    final personalityRes = calculatePersonalityMatch(answers1, answers2);

    final overallScore = ((nameRes.score +
                zodiacRes.score +
                chatRes.score +
                personalityRes.score) /
            4.0)
        .round()
        .clamp(50, 100);

    final allTests = AllTestsResult(
      nameMatch: nameRes,
      zodiacMatch: zodiacRes,
      chatChemistry: chatRes,
      personalityMatch: personalityRes,
      overallScore: overallScore,
    );

    final String verdict;
    if (overallScore >= 90) {
      verdict = 'Legendary Soulmates';
    } else if (overallScore >= 80) {
      verdict = 'Deep Multi-Layered Match';
    } else if (overallScore >= 70) {
      verdict = 'Harmonious Connection';
    } else {
      verdict = 'Vibrant & Complementary';
    }

    final summary =
        'Comprehensive analysis across Name Harmony (${nameRes.score}%), '
        'Zodiac Synergy (${zodiacRes.score}%), Chat Chemistry (${chatRes.score}%), '
        'and Personality Alignment (${personalityRes.score}%).';

    final topMetrics = [
      LoveTestMetric(label: 'Name Harmony', value: nameRes.score / 100.0),
      LoveTestMetric(
          label: 'Zodiac Chemistry (${zodiacRes.sign1} & ${zodiacRes.sign2})',
          value: zodiacRes.score / 100.0),
      LoveTestMetric(label: 'Chat Rhythm', value: chatRes.score / 100.0),
      LoveTestMetric(label: 'Personality Compatibility', value: personalityRes.score / 100.0),
    ];

    return LoveTestResult(
      yourName: yourName,
      theirName: theirName,
      testType: 'all',
      score: overallScore,
      verdictLabel: verdict,
      summary: summary,
      metrics: topMetrics,
      allTests: allTests,
    );
  }
}
