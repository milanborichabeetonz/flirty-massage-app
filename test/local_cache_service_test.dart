import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/network/models/pickup_line_model.dart';
import 'package:flirtymessages/core/storage/local_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalCacheService Tests', () {
    test('saveCache and getCache store and retrieve data correctly', () async {
      final cacheService = LocalCacheService.instance;

      final testData = [
        {'text': 'Are you a magician?', 'category': 'Cheesy'},
        {'text': 'Do you have a map?', 'category': 'Romantic'},
      ];

      final saveResult = await cacheService.saveCache('test_key', testData);
      expect(saveResult, isTrue);

      final retrieved = await cacheService.getCache('test_key');
      expect(retrieved, isA<List>());
      final list = retrieved as List;
      expect(list.length, equals(2));
      expect(list[0]['text'], equals('Are you a magician?'));
    });

    test('hasCache and removeCache work correctly', () async {
      final cacheService = LocalCacheService.instance;

      expect(await cacheService.hasCache('non_existent'), isFalse);

      await cacheService.saveCache('temp_key', 'hello');
      expect(await cacheService.hasCache('temp_key'), isTrue);

      await cacheService.removeCache('temp_key');
      expect(await cacheService.hasCache('temp_key'), isFalse);
    });

    test('PickupLineModel serialize and deserialize', () {
      final model = PickupLineModel(
        text: 'Is your name Google?',
        category: 'Clever',
      );

      final jsonMap = model.toJson();
      expect(jsonMap['text'], equals('Is your name Google?'));
      expect(jsonMap['category'], equals('Clever'));

      final restoredModel = PickupLineModel.fromJson(jsonMap);
      expect(restoredModel.text, equals('Is your name Google?'));
      expect(restoredModel.category, equals('Clever'));
    });
  });
}
