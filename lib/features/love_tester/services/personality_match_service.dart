import '../models/love_test_metric.dart';
import '../models/personality_match_result.dart';

class PersonalityQuestion {
  final String question;
  final List<String> options;
  final String traitName;

  const PersonalityQuestion({
    required this.question,
    required this.options,
    required this.traitName,
  });
}

class PersonalityMatchService {
  static const List<PersonalityQuestion> questions = [
    PersonalityQuestion(
      question: 'Ideal weekend activity?',
      options: ['Cozy time at home', 'Going out dancing/parties', 'Exploring somewhere new', 'Chilling with close friends'],
      traitName: 'Social Compatibility',
    ),
    PersonalityQuestion(
      question: 'Adventure level?',
      options: ['Comfort & calm', 'Spontaneous road trips', 'Moderate sightseeing', 'Extreme sports & thrill'],
      traitName: 'Adventure Spirit',
    ),
    PersonalityQuestion(
      question: 'Communication preference?',
      options: ['Constant texting', 'Phone & video calls', 'Brief check-ins', 'Deep evening talks'],
      traitName: 'Communication Style',
    ),
    PersonalityQuestion(
      question: 'Ideal romantic date?',
      options: ['Cute cozy café', 'Exciting outdoor adventure', 'Dinner & movie', 'Home cooked candlelight'],
      traitName: 'Romance Language',
    ),
    PersonalityQuestion(
      question: 'Trip planning style?',
      options: ['Minute-by-minute plan', 'Rough daily outline', 'Completely spontaneous', 'Go with their flow'],
      traitName: 'Planning Harmony',
    ),
    PersonalityQuestion(
      question: 'When unexpected plans pop up?',
      options: ['Stick to original plan', 'Happy to pivot', 'Love surprises', 'Need time to adjust'],
      traitName: 'Spontaneity Balance',
    ),
    PersonalityQuestion(
      question: 'Humor & vibe in conversation?',
      options: ['Witty & dry sarcasm', 'Goofy & silly laughter', 'Warm & wholesome jokes', 'Playful tease & banter'],
      traitName: 'Humor & Banter',
    ),
    PersonalityQuestion(
      question: 'Daily routine & lifestyle?',
      options: ['Early bird structured', 'Flexible night owl', 'Balanced regular habits', 'Changes every single week'],
      traitName: 'Lifestyle & Routine',
    ),
  ];

  /// Calculates personality match from both lists of answer indices (0-3)
  PersonalityMatchResult calculate(List<int> answers1, List<int> answers2) {
    assert(answers1.length == questions.length && answers2.length == questions.length);

    final traitScores = <String, double>{};
    final metrics = <LoveTestMetric>[];

    double sumSimilarity = 0.0;
    for (int i = 0; i < questions.length; i++) {
      final a1 = answers1[i].clamp(0, 3);
      final a2 = answers2[i].clamp(0, 3);
      final diff = (a1 - a2).abs();
      // Difference: 0 => 1.0 (100%), 1 => 0.78, 2 => 0.60, 3 => 0.45
      final double traitComp;
      switch (diff) {
        case 0:
          traitComp = 1.00;
          break;
        case 1:
          traitComp = 0.80;
          break;
        case 2:
          traitComp = 0.62;
          break;
        default:
          traitComp = 0.48;
          break;
      }

      sumSimilarity += traitComp;
      final traitName = questions[i].traitName;
      traitScores[traitName] = traitComp;
      metrics.add(LoveTestMetric(label: traitName, value: traitComp));
    }

    final avgSimilarity = sumSimilarity / questions.length;
    final score = (50 + avgSimilarity * 50).round().clamp(50, 100);

    final verdictLabel = _verdictLabel(score);
    final summary = _getSummary(score);

    return PersonalityMatchResult(
      score: score,
      verdictLabel: verdictLabel,
      summary: summary,
      traitScores: traitScores,
      metrics: metrics,
    );
  }

  static String _verdictLabel(int score) {
    if (score >= 90) return 'Personality Soulmates';
    if (score >= 80) return 'Complementary Dynamics';
    if (score >= 70) return 'Harmonious Personalities';
    if (score >= 60) return 'Engaging Contrast';
    return 'Unique Chemistry';
  }

  static String _getSummary(int score) {
    if (score >= 90) {
      return 'Remarkable compatibility! Your core habits, communication choices, and lifestyle instincts align almost effortlessly.';
    }
    if (score >= 80) {
      return 'Great personality balance! You have matching values in key areas and enough differences to keep each other intrigued.';
    }
    if (score >= 70) {
      return 'You share a comfortable foundation with diverse perspectives that make for vibrant discussions.';
    }
    return 'Your distinct personality styles offer an exciting dynamic where opposites create curiosity and mutual growth.';
  }
}
