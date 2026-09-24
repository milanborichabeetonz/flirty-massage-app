import 'dart:math' as math;
import '../models/chat_chemistry_result.dart';
import '../models/love_test_metric.dart';
import 'deterministic_random.dart';
import 'stable_hash.dart';

class ChatChemistryService {
  static const Set<String> _positiveWords = {
    'love', 'hey', 'hello', 'hi', 'sweet', 'cool', 'cute', 'great',
    'amazing', 'happy', 'good', 'awesome', 'nice', 'beautiful',
    'wonderful', 'fantastic', 'yes', 'sure', 'ok', 'okay', 'thanks',
    'thank', 'haha', 'lol', 'fun', 'babe', 'baby', 'date', 'coffee',
    'kiss', 'hug', 'smile', 'laugh', 'tonight', 'tomorrow', 'miss',
    'perfect', 'excited', 'enjoy', 'favorite', 'glad',
  };

  /// Calculates chat chemistry metrics and score deterministically
  ChatChemistryResult calculate(String message1, String message2) {
    final t1 = StableHash.normalizeInput(message1);
    final t2 = StableHash.normalizeInput(message2);

    // Symmetric seed
    final s1 = t1.compareTo(t2) <= 0 ? t1 : t2;
    final s2 = t1.compareTo(t2) <= 0 ? t2 : t1;
    final seed = StableHash.fnv1a32('$s1|||$s2');
    final rng = DeterministicRandom(seed);

    final words1 = t1.split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
    final words2 = t2.split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();

    // 1. Message Length Balance
    final len1 = words1.length;
    final len2 = words2.length;
    final maxLen = math.max(len1, len2);
    final msgBalance = maxLen == 0
        ? 1.0
        : (1.0 - (len1 - len2).abs() / maxLen).clamp(0.0, 1.0);

    // 2. Shared Words
    final set1 = words1.toSet();
    final set2 = words2.toSet();
    final unionCount = set1.union(set2).length;
    final rawShared = unionCount == 0 ? 0.0 : set1.intersection(set2).length / unionCount;
    final sharedScore = (rawShared * 3.5 + 0.35).clamp(0.0, 1.0);

    // 3. Question/Answer Balance
    final q1 = '?'.allMatches(message1).length;
    final q2 = '?'.allMatches(message2).length;
    final qTotal = q1 + q2;
    final double qBalance;
    if (qTotal == 0) {
      qBalance = 0.78; // conversational statement match
    } else {
      final diff = (q1 - q2).abs();
      qBalance = (1.0 - diff / (qTotal + 1.0)).clamp(0.5, 1.0);
    }

    // 4. Emoji Usage
    final e1 = message1.runes.where((r) => r > 127).length;
    final e2 = message2.runes.where((r) => r > 127).length;
    final totalEmoji = e1 + e2;
    final emojiScore = totalEmoji == 0
        ? 0.65
        : (0.65 + math.min(totalEmoji, 8) / 8.0 * 0.35).clamp(0.0, 1.0);

    // 5. Positive Word Ratio
    final allWords = [...words1, ...words2];
    final posCount = allWords.where(_positiveWords.contains).length;
    final posRatio = allWords.isEmpty
        ? 0.70
        : (0.50 + (posCount / allWords.length) * 2.5).clamp(0.0, 1.0);

    // 6. Conversation Energy
    final exclamationCount = '!'.allMatches(message1).length + '!'.allMatches(message2).length;
    final enthusiasm = (math.min(exclamationCount, 5) / 5.0 * 0.3).clamp(0.0, 0.3);
    final energy = (msgBalance * 0.35 + posRatio * 0.35 + enthusiasm + rng.nextDoubleRange(0.05, 0.20)).clamp(0.0, 1.0);

    // Combined Score
    final signal = msgBalance * 0.20 +
        sharedScore * 0.20 +
        qBalance * 0.15 +
        emojiScore * 0.15 +
        posRatio * 0.15 +
        energy * 0.15;

    final noise = rng.nextDoubleRange(-0.02, 0.04);
    final score = (50 + (signal + noise) * 50).round().clamp(50, 100);

    final metrics = [
      LoveTestMetric(label: 'Message Length Balance', value: msgBalance),
      LoveTestMetric(label: 'Shared Words', value: sharedScore),
      LoveTestMetric(label: 'Question/Answer Flow', value: qBalance),
      LoveTestMetric(label: 'Emoji Chemistry', value: emojiScore),
      LoveTestMetric(label: 'Positive Vibes', value: posRatio),
      LoveTestMetric(label: 'Conversation Energy', value: energy),
    ];

    final summary = _getSummary(score);
    final verdictLabel = _verdictLabel(score);

    return ChatChemistryResult(
      score: score,
      verdictLabel: verdictLabel,
      summary: summary,
      messageLengthBalance: msgBalance,
      sharedWords: sharedScore,
      questionBalance: qBalance,
      emojiUsage: emojiScore,
      positiveWordRatio: posRatio,
      conversationEnergy: energy,
      metrics: metrics,
    );
  }

  static String _verdictLabel(int score) {
    if (score >= 90) return 'Electric Connection';
    if (score >= 80) return 'High Text Chemistry';
    if (score >= 70) return 'Great Conversational Flow';
    if (score >= 60) return 'Playful Banter';
    return 'Casual Rhythm';
  }

  static String _getSummary(int score) {
    if (score >= 90) {
      return 'Your texting styles mesh seamlessly with lively energy, mutual engagement, and natural warmth.';
    }
    if (score >= 80) {
      return 'Strong chat chemistry! Your messages show balanced participation and a fun, comfortable back-and-forth.';
    }
    if (score >= 70) {
      return 'You communicate easily with good rhythm and plenty of positive vibes.';
    }
    return 'Your chat shows a pleasant pace with room to unlock deeper conversations.';
  }
}
