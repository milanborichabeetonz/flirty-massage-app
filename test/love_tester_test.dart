import 'package:flutter_test/flutter_test.dart';
import 'package:flirtymessages/features/love_tester/services/love_tester_service.dart';

void main() {
  group('StableHash and DeterministicRandom', () {
    test('Input normalization and symmetric seed', () {
      final s1 = StableHash.symmetricSeed('Milan', 'Sujal');
      final s2 = StableHash.symmetricSeed('Sujal', 'Milan');
      final s3 = StableHash.symmetricSeed(' MILAN ', ' sujal ');

      expect(s1, equals(s2));
      expect(s1, equals(s3));
      expect(s1, isNot(equals(0)));
    });

    test('DeterministicRandom produces identical sequences for same seed', () {
      final rng1 = DeterministicRandom(123456789);
      final rng2 = DeterministicRandom(123456789);

      for (int i = 0; i < 20; i++) {
        expect(rng1.nextInt(), equals(rng2.nextInt()));
        expect(rng1.nextDouble(), equals(rng2.nextDouble()));
      }
    });
  });

  group('NameMatchService - Deterministic and Symmetric', () {
    final service = NameMatchService();

    test('Milan + Sujal is symmetric with Sujal + Milan', () {
      final r1 = service.calculate('Milan', 'Sujal');
      final r2 = service.calculate('Sujal', 'Milan');

      expect(r1.score, equals(r2.score));
      expect(r1.verdictLabel, equals(r2.verdictLabel));
      expect(r1.summary, equals(r2.summary));
      expect(r1.lengthBalance, equals(r2.lengthBalance));
      expect(r1.vowelHarmony, equals(r2.vowelHarmony));
      expect(r1.nameEnergy, equals(r2.nameEnergy));
      expect(r1.sharedLetters, equals(r2.sharedLetters));
      expect(r1.numerology, equals(r2.numerology));
      expect(r1.destinyEnergy, equals(r2.destinyEnergy));
    });

    test('Case and spacing differences normalize to identical result', () {
      final r1 = service.calculate('Milan', 'Sujal');
      final r2 = service.calculate('MILAN', 'SUJAL');
      final r3 = service.calculate('  Milan  ', ' Sujal ');

      expect(r1.score, equals(r2.score));
      expect(r1.score, equals(r3.score));
      expect(r1.summary, equals(r3.summary));
      for (int i = 0; i < r1.metrics.length; i++) {
        expect(r1.metrics[i].value, equals(r3.metrics[i].value));
      }
    });

    test('Multiple calls return strictly identical result', () {
      final first = service.calculate('Romeo', 'Juliet');
      for (int i = 0; i < 5; i++) {
        final repeated = service.calculate('Romeo', 'Juliet');
        expect(repeated.score, equals(first.score));
        expect(repeated.verdictLabel, equals(first.verdictLabel));
        expect(repeated.summary, equals(first.summary));
      }
    });

    test('Identical names return valid symmetric score', () {
      final r = service.calculate('Alex', 'Alex');
      expect(r.score, greaterThanOrEqualTo(50));
      expect(r.score, lessThanOrEqualTo(100));
      expect(r.lengthBalance, equals(1.0));
      expect(r.sharedLetters, equals(1.0));
    });
  });

  group('ZodiacMatchService - Deterministic and Symmetric', () {
    final service = ZodiacMatchService();

    test('Aries + Leo is symmetric with Leo + Aries', () {
      final dobAries = DateTime(1998, 3, 25);
      final dobLeo = DateTime(2000, 8, 10);

      final r1 = service.calculate(dobAries, dobLeo);
      final r2 = service.calculate(dobLeo, dobAries);

      expect(r1.score, equals(r2.score));
      expect(r1.verdictLabel, equals(r2.verdictLabel));
      expect(r1.sign1, isIn(['Aries', 'Leo']));
      expect(r1.sign2, isIn(['Aries', 'Leo']));
    });

    test('Same dates return identical result across repeated calls', () {
      final d1 = DateTime(1995, 11, 5);
      final d2 = DateTime(1996, 5, 15);

      final first = service.calculate(d1, d2);
      for (int i = 0; i < 5; i++) {
        final next = service.calculate(d1, d2);
        expect(next.score, equals(first.score));
        expect(next.summary, equals(first.summary));
      }
    });
  });

  group('ChatChemistryService - Deterministic and Symmetric', () {
    final service = ChatChemistryService();

    test('Same messages return identical result', () {
      const m1 = 'Hey! Are you excited for coffee tonight?';
      const m2 = 'Yes haha cant wait! See you soon 😊';

      final r1 = service.calculate(m1, m2);
      final r2 = service.calculate(m1, m2);

      expect(r1.score, equals(r2.score));
      expect(r1.summary, equals(r2.summary));
      expect(r1.conversationEnergy, equals(r2.conversationEnergy));
    });

    test('Swapped order produces symmetric score', () {
      const m1 = 'Hey! Are you excited for coffee tonight?';
      const m2 = 'Yes haha cant wait! See you soon 😊';

      final r1 = service.calculate(m1, m2);
      final r2 = service.calculate(m2, m1);

      expect(r1.score, equals(r2.score));
      expect(r1.verdictLabel, equals(r2.verdictLabel));
    });
  });

  group('PersonalityMatchService - Deterministic and Symmetric', () {
    final service = PersonalityMatchService();

    test('Identical answers produce 100% score', () {
      final a = [0, 1, 2, 3, 0, 1, 2, 3];
      final r = service.calculate(a, a);

      expect(r.score, equals(100));
      for (final m in r.metrics) {
        expect(m.value, equals(1.0));
      }
    });

    test('Swapped answer sets produce symmetric score', () {
      final a1 = [0, 1, 2, 3, 0, 1, 2, 3];
      final a2 = [3, 2, 1, 0, 3, 2, 1, 0];

      final r1 = service.calculate(a1, a2);
      final r2 = service.calculate(a2, a1);

      expect(r1.score, equals(r2.score));
      expect(r1.verdictLabel, equals(r2.verdictLabel));
    });
  });

  group('LoveTesterService - Calculate All Tests', () {
    final service = LoveTesterService();

    test('Calculates all 4 tests and compiles valid overall score', () {
      final res = service.calculateAllTests(
        yourName: 'Milan',
        theirName: 'Sujal',
        dob1: DateTime(1997, 4, 15),
        dob2: DateTime(1999, 8, 20),
        msg1: 'Hey! Hope you are having a wonderful day!',
        msg2: 'Thanks! Super excited to see you today 😊',
        answers1: [1, 2, 0, 3, 1, 2, 0, 1],
        answers2: [1, 2, 1, 3, 0, 2, 0, 2],
      );

      expect(res.testType, equals('all'));
      expect(res.score, greaterThanOrEqualTo(50));
      expect(res.score, lessThanOrEqualTo(100));
      expect(res.allTests, isNotNull);
      expect(res.allTests!.nameMatch.score, greaterThanOrEqualTo(50));
      expect(res.allTests!.zodiacMatch.score, greaterThanOrEqualTo(50));
      expect(res.allTests!.chatChemistry.score, greaterThanOrEqualTo(50));
      expect(res.allTests!.personalityMatch.score, greaterThanOrEqualTo(50));
    });
  });
}
