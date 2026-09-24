import 'dart:math' as math;
import '../models/love_test_metric.dart';
import '../models/name_match_result.dart';
import 'deterministic_random.dart';
import 'stable_hash.dart';

class NameMatchService {
  static const Map<int, double> _archetypeTable = {
    1: 0.78,
    2: 0.85,
    3: 0.92,
    4: 0.68,
    5: 0.82,
    6: 0.90,
    7: 0.74,
    8: 0.65,
    9: 0.98,
  };

  /// Calculates deterministic name match result
  NameMatchResult calculate(String name1, String name2) {
    final norm1 = StableHash.normalizeLetters(name1);
    final norm2 = StableHash.normalizeLetters(name2);

    // Symmetric ordering
    final first = norm1.compareTo(norm2) <= 0 ? norm1 : norm2;
    final second = norm1.compareTo(norm2) <= 0 ? norm2 : norm1;

    // Stable FNV-1a 32-bit seed
    final seed = StableHash.fnv1a32('$first:$second');
    final rng = DeterministicRandom(seed);

    // Three deterministic pseudo-random values
    final r1 = rng.nextDouble();
    final r2 = rng.nextDouble();
    final r3 = rng.nextDouble();

    // 1. Length Balance
    final len1 = first.length;
    final len2 = second.length;
    final maxLen = math.max(len1, len2);
    final lengthBalance = maxLen == 0
        ? 1.0
        : (1.0 - (len1 - len2).abs() / maxLen).clamp(0.0, 1.0);

    // 2. Vowel Harmony
    const vowels = {'a', 'e', 'i', 'o', 'u'};
    final setA = first.split('').where(vowels.contains).toSet();
    final setB = second.split('').where(vowels.contains).toSet();
    final vowelUnion = setA.union(setB).length;
    final vowelHarmony = vowelUnion == 0
        ? 0.0
        : (setA.intersection(setB).length / vowelUnion).clamp(0.0, 1.0);

    // 3. Initial Match
    final initialMatch =
        (first.isNotEmpty && second.isNotEmpty && first[0] == second[0])
            ? 1.0
            : 0.0;

    // 4. Signal
    final signal =
        (lengthBalance * 0.4) + (vowelHarmony * 0.4) + (initialMatch * 0.2);

    // 5. Noise
    final noise = (r1 * 0.5) + (r2 * 0.3) + (r3 * 0.2);

    // 6. Base
    final base = (signal * 0.3) + (noise * 0.7);

    // 7. Final Score (50–100)
    final score = (50 + (base * 50)).round().clamp(50, 100);

    // Additional Deterministic Metrics
    final nameEnergy = _calculateNameEnergy(first, second, seed);
    final sharedLetters = _calculateSharedLetters(first, second);
    final numerology = _calculateNumerology(first, second);
    final destinyEnergy = _calculateDestinyEnergy(first, second, seed);

    final verdictLabel = _verdictLabel(score);
    final summary = _explanation(score);

    final metrics = [
      LoveTestMetric(label: 'Name Energy', value: nameEnergy),
      LoveTestMetric(label: 'Shared Letters', value: sharedLetters),
      LoveTestMetric(label: 'Length Balance', value: lengthBalance),
      LoveTestMetric(label: 'Vowel Harmony', value: vowelHarmony),
      LoveTestMetric(label: 'Numerology', value: numerology),
      LoveTestMetric(label: 'Destiny Energy', value: destinyEnergy),
    ];

    return NameMatchResult(
      score: score,
      verdictLabel: verdictLabel,
      summary: summary,
      lengthBalance: lengthBalance,
      vowelHarmony: vowelHarmony,
      initialMatch: initialMatch,
      nameEnergy: nameEnergy,
      sharedLetters: sharedLetters,
      numerology: numerology,
      destinyEnergy: destinyEnergy,
      metrics: metrics,
    );
  }

  /// Calculates Name Energy: stable numeric value from both names (a=1..z=26)
  static double _calculateNameEnergy(String a, String b, int seed) {
    if (a.isEmpty && b.isEmpty) return 0.75;
    double avgLetter(String s) {
      if (s.isEmpty) return 0.5;
      final sum = s.codeUnits.fold<int>(0, (prev, c) => prev + (c - 96));
      return (sum / (s.length * 26.0)).clamp(0.0, 1.0);
    }

    final avgA = avgLetter(a);
    final avgB = avgLetter(b);
    final similarity = 1.0 - (avgA - avgB).abs();
    final seedFactor = ((seed >> 4) % 100) / 100.0;
    return (similarity * 0.75 + seedFactor * 0.25).clamp(0.0, 1.0);
  }

  /// Calculates actual shared characters between both names
  static double _calculateSharedLetters(String a, String b) {
    final setA = a.split('').toSet();
    final setB = b.split('').toSet();
    final union = setA.union(setB).length;
    if (union == 0) return 0.0;
    return (setA.intersection(setB).length / union).clamp(0.0, 1.0);
  }

  /// Reduces a name to a single Pythagorean digit (1-9)
  static int _digitRoot(String name) {
    if (name.isEmpty) return 1;
    int rawSum = 0;
    for (final c in name.codeUnits) {
      if (c >= 97 && c <= 122) {
        rawSum += ((c - 97) % 9) + 1;
      }
    }
    if (rawSum == 0) return 1;
    while (rawSum >= 10) {
      int s = 0;
      while (rawSum > 0) {
        s += rawSum % 10;
        rawSum ~/= 10;
      }
      rawSum = s;
    }
    return rawSum == 0 ? 9 : rawSum;
  }

  /// Calculates numerology compatibility (0.0 to 1.0)
  static double _calculateNumerology(String a, String b) {
    final rootA = _digitRoot(a);
    final rootB = _digitRoot(b);
    final diff = (rootA - rootB).abs();
    return (1.0 - diff / 8.0).clamp(0.0, 1.0);
  }

  /// Destiny energy from normalized name characters, combined seed, numerology values
  static double _calculateDestinyEnergy(String a, String b, int seed) {
    final pairRoot = _digitRoot(a + b);
    final archetype = _archetypeTable[pairRoot] ?? 0.80;
    final seedFactor = ((seed >> 8) % 100) / 100.0;
    return (archetype * 0.7 + seedFactor * 0.3).clamp(0.0, 1.0);
  }

  static String _verdictLabel(int score) {
    if (score >= 90) return 'Special Connection';
    if (score >= 80) return 'Strong Match';
    if (score >= 70) return 'Nice Connection';
    if (score >= 60) return 'Fun Chemistry';
    return 'Interesting Connection';
  }

  static String _explanation(int score) {
    if (score >= 90) {
      return 'Your names show a playful and highly harmonious pattern.';
    }
    if (score >= 75) {
      return 'Your names show several interesting points of connection.';
    }
    if (score >= 60) {
      return 'Your names have a balanced mix of similarities and differences.';
    }
    return 'Your names have a fun mix of different patterns.';
  }
}
