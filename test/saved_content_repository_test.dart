import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/repositories/saved_content_repository.dart';
import 'package:flirtymessages/core/storage/local_cache_service.dart';
import 'package:flirtymessages/features/love_tester/models/love_test_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.instance.removeCache('saved_pickup_lines_v1');
    await LocalCacheService.instance.removeCache('saved_love_tests_v1');
  });

  group('Saved Pickup Lines', () {
    test('Save marks line as saved and stores text + category', () async {
      final repository = SavedContentRepository();

      final isNew = await repository.savePickupLine(
        text: 'Are you a camera? Because every time I look at you, I smile.',
        category: 'Cheesy',
      );

      expect(isNew, isTrue);
      expect(
        await repository.isPickupLineSaved(
            'Are you a camera? Because every time I look at you, I smile.'),
        isTrue,
      );

      final saved = await repository.getSavedPickupLines();
      expect(saved.length, equals(1));
      expect(saved[0].text,
          equals('Are you a camera? Because every time I look at you, I smile.'));
      expect(saved[0].category, equals('Cheesy'));
    });

    test('Saving the same line twice does not create duplicates', () async {
      final repository = SavedContentRepository();

      await repository.savePickupLine(text: 'Are you Wi-Fi?', category: 'Clever');
      final isNew = await repository.savePickupLine(
          text: 'Are you Wi-Fi?', category: 'Clever');

      expect(isNew, isFalse);

      final saved = await repository.getSavedPickupLines();
      expect(saved.length, equals(1));
    });

    test('Stable id ignores case and surrounding whitespace', () async {
      final repository = SavedContentRepository();

      await repository.savePickupLine(text: '  You must be a parking ticket.  ', category: 'Funny');

      expect(
        await repository.isPickupLineSaved('you must be a parking ticket.'),
        isTrue,
      );
    });

    test('Remove deletes only the targeted line', () async {
      final repository = SavedContentRepository();

      await repository.savePickupLine(text: 'Line one', category: 'Romantic');
      await repository.savePickupLine(text: 'Line two', category: 'Flirty');

      await repository.removeSavedPickupLine('Line one');

      expect(await repository.isPickupLineSaved('Line one'), isFalse);
      expect(await repository.isPickupLineSaved('Line two'), isTrue);

      final saved = await repository.getSavedPickupLines();
      expect(saved.length, equals(1));
      expect(saved[0].text, equals('Line two'));
    });

    test('Old saved records with missing fields load without crashing',
        () async {
      await LocalCacheService.instance.saveCache('saved_pickup_lines_v1', [
        {'id': 'pickupline_old_1', 'text': 'Old line'},
      ]);

      final repository = SavedContentRepository();
      final saved = await repository.getSavedPickupLines();

      expect(saved.length, equals(1));
      expect(saved[0].text, equals('Old line'));
      expect(saved[0].category, equals(''));
    });
  });

  group('Love Test Result Serialization', () {
    LoveTestResult buildFullResult() {
      return LoveTestResult(
        yourName: 'Milan',
        theirName: 'Sujal',
        testType: 'all',
        category: 'Romantic',
        score: 87,
        verdictLabel: 'Strong Match',
        summary: 'You two have great energy together.',
        metrics: const [
          LoveTestMetric(label: 'Chemistry', value: 0.9),
          LoveTestMetric(label: 'Humour', value: 0.7),
        ],
        allTests: AllTestsResult(
          overallScore: 84,
          nameMatch: NameMatchResult(
            score: 82,
            verdictLabel: 'Great',
            summary: 'Names align well.',
            lengthBalance: 0.8,
            vowelHarmony: 0.6,
            initialMatch: 1.0,
            nameEnergy: 0.75,
            sharedLetters: 0.5,
            numerology: 0.9,
            destinyEnergy: 0.65,
            metrics: const [LoveTestMetric(label: 'Vowels', value: 0.6)],
          ),
          zodiacMatch: ZodiacMatchResult(
            sign1: 'Aries',
            sign2: 'Leo',
            element1: 'Fire',
            element2: 'Fire',
            score: 88,
            verdictLabel: 'Fiery',
            summary: 'Fire signs burn bright together.',
            metrics: const [LoveTestMetric(label: 'Elements', value: 1.0)],
          ),
          chatChemistry: ChatChemistryResult(
            score: 79,
            verdictLabel: 'Playful',
            summary: 'Fun banter detected.',
            messageLengthBalance: 0.85,
            sharedWords: 0.4,
            questionBalance: 0.9,
            emojiUsage: 0.7,
            positiveWordRatio: 0.95,
            conversationEnergy: 0.8,
            metrics: const [LoveTestMetric(label: 'Energy', value: 0.8)],
          ),
          personalityMatch: PersonalityMatchResult(
            score: 91,
            verdictLabel: 'Aligned',
            summary: 'Complementary traits.',
            traitScores: const {'openness': 0.9, 'humour': 0.85},
            metrics: const [LoveTestMetric(label: 'Openness', value: 0.9)],
          ),
        ),
      );
    }

    test('Round-trip preserves every field of an all-tests result',
        () async {
      final repository = SavedContentRepository();
      final original = buildFullResult();

      await repository.saveOrUpdateLoveTest(original);
      final loaded = await repository.getSavedLoveTests();

      expect(loaded.length, equals(1));
      final r = loaded[0];

      expect(r.yourName, equals('Milan'));
      expect(r.theirName, equals('Sujal'));
      expect(r.testType, equals('all'));
      expect(r.score, equals(87));
      expect(r.verdictLabel, equals('Strong Match'));
      expect(r.metrics.length, equals(2));
      expect(r.metrics[0].label, equals('Chemistry'));
      expect(r.metrics[0].value, equals(0.9));

      final all = r.allTests!;
      expect(all.overallScore, equals(84));

      expect(all.nameMatch.score, equals(82));
      expect(all.nameMatch.lengthBalance, equals(0.8));
      expect(all.nameMatch.vowelHarmony, equals(0.6));
      expect(all.nameMatch.initialMatch, equals(1.0));
      expect(all.nameMatch.nameEnergy, equals(0.75));
      expect(all.nameMatch.sharedLetters, equals(0.5));
      expect(all.nameMatch.numerology, equals(0.9));
      expect(all.nameMatch.destinyEnergy, equals(0.65));
      expect(all.nameMatch.metrics.length, equals(1));

      expect(all.zodiacMatch.sign1, equals('Aries'));
      expect(all.zodiacMatch.sign2, equals('Leo'));
      expect(all.zodiacMatch.element1, equals('Fire'));
      expect(all.zodiacMatch.element2, equals('Fire'));
      expect(all.zodiacMatch.score, equals(88));

      expect(all.chatChemistry.messageLengthBalance, equals(0.85));
      expect(all.chatChemistry.sharedWords, equals(0.4));
      expect(all.chatChemistry.questionBalance, equals(0.9));
      expect(all.chatChemistry.emojiUsage, equals(0.7));
      expect(all.chatChemistry.positiveWordRatio, equals(0.95));
      expect(all.chatChemistry.conversationEnergy, equals(0.8));

      expect(all.personalityMatch.traitScores['openness'], equals(0.9));
      expect(all.personalityMatch.traitScores['humour'], equals(0.85));
      expect(all.personalityMatch.score, equals(91));
    });

    test('Saving the same result twice does not create duplicates', () async {
      final repository = SavedContentRepository();
      final result = buildFullResult();

      final isNew1 = await repository.saveOrUpdateLoveTest(result);
      final isNew2 = await repository.saveOrUpdateLoveTest(result);

      expect(isNew1, isTrue);
      expect(isNew2, isFalse);

      final loaded = await repository.getSavedLoveTests();
      expect(loaded.length, equals(1));
    });

    test('Old records missing the new allTests fields load with defaults',
        () async {
      await LocalCacheService.instance.saveCache('saved_love_tests_v1', [
        {
          'id': 'lovetest_milan_sujal_all',
          'yourName': 'Milan',
          'theirName': 'Sujal',
          'testType': 'all',
          'category': 'Romantic',
          'score': 80,
          'verdictLabel': 'Good',
          'summary': 'Nice match.',
          'metrics': [
            {'label': 'Chemistry', 'value': 0.8}
          ],
          'allTests': {
            'overallScore': 80,
            'nameMatch': {
              'score': 78,
              'verdictLabel': 'Good',
              'summary': 'ok',
            },
            'zodiacMatch': {
              'sign1': 'Aries',
              'sign2': 'Leo',
              'score': 82,
              'verdictLabel': 'Good',
              'summary': 'ok',
            },
            'chatChemistry': {
              'score': 75,
              'verdictLabel': 'Good',
              'summary': 'ok',
            },
            'personalityMatch': {
              'score': 85,
              'verdictLabel': 'Good',
              'summary': 'ok',
            },
          },
        }
      ]);

      final repository = SavedContentRepository();
      final loaded = await repository.getSavedLoveTests();

      expect(loaded.length, equals(1));
      final r = loaded[0];
      expect(r.score, equals(80));
      expect(r.metrics.length, equals(1));
      expect(r.allTests, isNotNull);
      expect(r.allTests!.nameMatch.score, equals(78));
      expect(r.allTests!.nameMatch.lengthBalance, equals(0.0));
      expect(r.allTests!.zodiacMatch.element1, equals(''));
      expect(r.allTests!.personalityMatch.traitScores, isEmpty);
    });
  });
}
