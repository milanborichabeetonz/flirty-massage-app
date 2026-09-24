import '../models/love_test_metric.dart';
import '../models/zodiac_match_result.dart';
import 'deterministic_random.dart';
import 'stable_hash.dart';

class ZodiacMatchService {
  static const Map<String, String> _signElements = {
    'Aries': 'Fire',
    'Leo': 'Fire',
    'Sagittarius': 'Fire',
    'Taurus': 'Earth',
    'Virgo': 'Earth',
    'Capricorn': 'Earth',
    'Gemini': 'Air',
    'Libra': 'Air',
    'Aquarius': 'Air',
    'Cancer': 'Water',
    'Scorpio': 'Water',
    'Pisces': 'Water',
  };

  // Base compatibility ratings (0.0 to 1.0) between pairs of signs
  static const Map<String, double> _pairBaseScores = {
    // Fire + Fire
    'Aries:Aries': 0.84, 'Aries:Leo': 0.94, 'Aries:Sagittarius': 0.92,
    'Leo:Leo': 0.86, 'Leo:Sagittarius': 0.93, 'Sagittarius:Sagittarius': 0.85,

    // Fire + Air
    'Aquarius:Aries': 0.88, 'Aries:Gemini': 0.87, 'Aries:Libra': 0.89,
    'Aquarius:Leo': 0.90, 'Gemini:Leo': 0.88, 'Leo:Libra': 0.91,
    'Aquarius:Sagittarius': 0.91, 'Gemini:Sagittarius': 0.89, 'Libra:Sagittarius': 0.90,

    // Fire + Earth
    'Aries:Taurus': 0.64, 'Aries:Virgo': 0.63, 'Aries:Capricorn': 0.65,
    'Leo:Taurus': 0.70, 'Leo:Virgo': 0.68, 'Capricorn:Leo': 0.67,
    'Sagittarius:Taurus': 0.62, 'Sagittarius:Virgo': 0.66, 'Capricorn:Sagittarius': 0.65,

    // Fire + Water
    'Aries:Cancer': 0.63, 'Aries:Scorpio': 0.72, 'Aries:Pisces': 0.65,
    'Cancer:Leo': 0.71, 'Leo:Scorpio': 0.74, 'Leo:Pisces': 0.68,
    'Cancer:Sagittarius': 0.62, 'Sagittarius:Scorpio': 0.69, 'Pisces:Sagittarius': 0.67,

    // Earth + Earth
    'Taurus:Taurus': 0.88, 'Taurus:Virgo': 0.93, 'Capricorn:Taurus': 0.94,
    'Virgo:Virgo': 0.87, 'Capricorn:Virgo': 0.95, 'Capricorn:Capricorn': 0.89,

    // Earth + Water
    'Cancer:Taurus': 0.92, 'Scorpio:Taurus': 0.90, 'Pisces:Taurus': 0.91,
    'Cancer:Virgo': 0.91, 'Scorpio:Virgo': 0.93, 'Pisces:Virgo': 0.89,
    'Cancer:Capricorn': 0.88, 'Capricorn:Scorpio': 0.92, 'Capricorn:Pisces': 0.90,

    // Earth + Air
    'Gemini:Taurus': 0.64, 'Libra:Taurus': 0.73, 'Aquarius:Taurus': 0.66,
    'Gemini:Virgo': 0.72, 'Libra:Virgo': 0.69, 'Aquarius:Virgo': 0.68,
    'Capricorn:Gemini': 0.63, 'Capricorn:Libra': 0.68, 'Aquarius:Capricorn': 0.71,

    // Air + Air
    'Gemini:Gemini': 0.84, 'Gemini:Libra': 0.93, 'Aquarius:Gemini': 0.92,
    'Libra:Libra': 0.85, 'Aquarius:Libra': 0.94, 'Aquarius:Aquarius': 0.86,

    // Air + Water
    'Cancer:Gemini': 0.64, 'Gemini:Scorpio': 0.65, 'Gemini:Pisces': 0.66,
    'Cancer:Libra': 0.68, 'Libra:Scorpio': 0.70, 'Libra:Pisces': 0.69,
    'Aquarius:Cancer': 0.65, 'Aquarius:Scorpio': 0.71, 'Aquarius:Pisces': 0.72,

    // Water + Water
    'Cancer:Cancer': 0.86, 'Cancer:Scorpio': 0.95, 'Cancer:Pisces': 0.94,
    'Scorpio:Scorpio': 0.88, 'Pisces:Scorpio': 0.96, 'Pisces:Pisces': 0.87,
  };

  /// Calculates zodiac match from two birthdates
  ZodiacMatchResult calculate(DateTime dob1, DateTime dob2) {
    final sign1 = getZodiacSign(dob1);
    final sign2 = getZodiacSign(dob2);
    final element1 = _signElements[sign1] ?? 'Fire';
    final element2 = _signElements[sign2] ?? 'Fire';

    // Normalize and sort sign names to ensure symmetry
    final s1 = sign1.compareTo(sign2) <= 0 ? sign1 : sign2;
    final s2 = sign1.compareTo(sign2) <= 0 ? sign2 : sign1;
    final pairKey = '$s1:$s2';

    // Deterministic seed
    final seed = StableHash.fnv1a32(pairKey);
    final rng = DeterministicRandom(seed);

    // Deterministic base score
    final base = _pairBaseScores[pairKey] ?? _defaultElementAffinity(element1, element2);
    // Micro-variation (deterministic ±2%)
    final nudge = rng.nextDoubleRange(-0.02, 0.02);
    final score = ((base + nudge) * 100).round().clamp(50, 100);

    final elementHarmony = _elementHarmony(element1, element2);
    final signAffinity = (score / 100.0).clamp(0.0, 1.0);
    final communication = (rng.nextDoubleRange(0.70, 0.95) * (score >= 75 ? 1.0 : 0.85)).clamp(0.0, 1.0);
    final emotionalBond = (elementHarmony * 0.6 + signAffinity * 0.4).clamp(0.0, 1.0);
    final cosmicSynergy = (score / 100.0 * 0.9 + rng.nextDoubleRange(0.05, 0.10)).clamp(0.0, 1.0);
    final longTerm = (signAffinity * 0.8 + elementHarmony * 0.2).clamp(0.0, 1.0);

    final metrics = [
      LoveTestMetric(label: 'Element Harmony ($element1 + $element2)', value: elementHarmony),
      LoveTestMetric(label: 'Sign Affinity', value: signAffinity),
      LoveTestMetric(label: 'Communication Flow', value: communication),
      LoveTestMetric(label: 'Emotional Connection', value: emotionalBond),
      LoveTestMetric(label: 'Cosmic Synergy', value: cosmicSynergy),
      LoveTestMetric(label: 'Long-term Potential', value: longTerm),
    ];

    final summary = _getSummary(sign1, sign2, element1, element2, score);
    final verdictLabel = _verdictLabel(score);

    return ZodiacMatchResult(
      sign1: sign1,
      sign2: sign2,
      element1: element1,
      element2: element2,
      score: score,
      verdictLabel: verdictLabel,
      summary: summary,
      metrics: metrics,
    );
  }

  /// Determines Western zodiac sign by month and day
  static String getZodiacSign(DateTime dob) {
    final m = dob.month;
    final d = dob.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'Aries';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'Taurus';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'Gemini';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'Cancer';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'Leo';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'Virgo';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'Libra';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'Scorpio';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'Sagittarius';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'Capricorn';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  static double _defaultElementAffinity(String e1, String e2) {
    if (e1 == e2) return 0.88;
    final pair = e1.compareTo(e2) <= 0 ? '$e1:$e2' : '$e2:$e1';
    switch (pair) {
      case 'Air:Fire':
        return 0.86;
      case 'Earth:Water':
        return 0.85;
      case 'Air:Earth':
        return 0.69;
      case 'Air:Water':
        return 0.66;
      case 'Earth:Fire':
        return 0.67;
      case 'Fire:Water':
        return 0.64;
      default:
        return 0.72;
    }
  }

  static double _elementHarmony(String e1, String e2) {
    if (e1 == e2) return 0.95;
    final pair = e1.compareTo(e2) <= 0 ? '$e1:$e2' : '$e2:$e1';
    if (pair == 'Air:Fire' || pair == 'Earth:Water') return 0.88;
    return 0.65;
  }

  static String _verdictLabel(int score) {
    if (score >= 90) return 'Cosmic Soulmates';
    if (score >= 80) return 'Strong Celestial Match';
    if (score >= 70) return 'Harmonious Signs';
    if (score >= 60) return 'Playful Connection';
    return 'Curious Chemistry';
  }

  static String _getSummary(String s1, String s2, String e1, String e2, int score) {
    if (score >= 90) {
      return '$s1 and $s2 share deep astrological compatibility ($e1 & $e2), bringing natural excitement and mutual understanding.';
    }
    if (score >= 80) {
      return '$s1 and $s2 have an inspiring cosmic balance with great complementary strengths.';
    }
    if (score >= 70) {
      return '$s1 and $s2 share pleasant astrological harmony with plenty of spark to explore.';
    }
    return '$s1 and $s2 create an intriguing dynamic where differences can make conversations uniquely interesting.';
  }
}
