import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/controllers/favorite_controller.dart';
import 'package:flirtymessages/features/dating_tips/models/dating_tip_model.dart';
import 'package:flirtymessages/features/dating_tips/screens/dating_tips_screen.dart';
import 'package:flirtymessages/features/dating_tips/services/dating_tips_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    // rootBundle caches loadString futures for the whole isolate. A future
    // completed inside one test's zone never resolves under another test's
    // FakeAsync clocks, so clear the cache before every test.
    rootBundle.clear();
  });

  group('Dating Tips JSON & Service validation', () {
    test('JSON contains exactly 200 unique tips with valid schema', () async {
      final jsonString =
          await rootBundle.loadString('assets/data/dating_tips.json');
      final dynamic decoded = jsonDecode(jsonString);

      expect(decoded, isA<List>());
      final list = decoded as List;
      expect(list.length, equals(200),
          reason: 'Must contain exactly 200 dating tips');

      final ids = <String>{};
      final texts = <String>{};
      final categories = <String>{};

      for (int i = 0; i < list.length; i++) {
        final item = list[i] as Map<String, dynamic>;
        final tip = DatingTipModel.fromJson(item);

        expect(tip.id.isNotEmpty, isTrue);
        expect(ids.contains(tip.id), isFalse,
            reason: 'Duplicate ID found: ${tip.id}');
        ids.add(tip.id);

        expect(tip.text.trim().isNotEmpty, isTrue,
            reason: 'Empty text found at index $i');
        expect(texts.contains(tip.text), isFalse,
            reason: 'Duplicate tip text found: "${tip.text}"');
        texts.add(tip.text);

        expect(tip.colorIndex, greaterThanOrEqualTo(0));
        expect(tip.colorIndex, lessThanOrEqualTo(5));

        categories.add(tip.category);
      }

      expect(categories.length, greaterThanOrEqualTo(10),
          reason: 'Diverse categories must be covered');
    });

    test('DatingTipsService caches loaded tips in memory', () async {
      final service = DatingTipsService();
      final tips1 = await service.getDatingTips();
      final tips2 = await service.getDatingTips();

      expect(tips1.length, equals(200));
      expect(identical(tips1, tips2), isTrue,
          reason: 'Service should return cached instance on subsequent calls');
    });
  });

  group('FavoriteController Dating Tips Integration', () {
    test('Toggle dating tip favorite increases and decreases count', () async {
      final controller = Get.put(FavoriteController());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.datingTipFavoriteCount, equals(0));
      expect(controller.isDatingTipFavorite('dating_tip_001'), isFalse);

      // Add favorite
      await controller.toggleDatingTipFavorite(
        id: 'dating_tip_001',
        text: 'Choose a low-pressure setting for a first date.',
        category: 'First Date',
        colorIndex: 0,
      );

      expect(controller.datingTipFavoriteCount, equals(1));
      expect(controller.isDatingTipFavorite('dating_tip_001'), isTrue);

      // Add another favorite
      await controller.toggleDatingTipFavorite(
        id: 'dating_tip_002',
        text: 'Define what exclusive means together.',
        category: 'Relationships',
        colorIndex: 1,
      );

      expect(controller.datingTipFavoriteCount, equals(2));
      expect(controller.datingTipFavorites.length, equals(2));

      // Remove favorite
      await controller.toggleDatingTipFavorite(
        id: 'dating_tip_001',
        text: 'Choose a low-pressure setting for a first date.',
        category: 'First Date',
        colorIndex: 0,
      );

      expect(controller.datingTipFavoriteCount, equals(1));
      expect(controller.isDatingTipFavorite('dating_tip_001'), isFalse);
      expect(controller.isDatingTipFavorite('dating_tip_002'), isTrue);
    });

    test('Pickup Line favorites and Dating Tip favorites remain distinct',
        () async {
      final controller = Get.put(FavoriteController());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Add pickup line favorite
      await controller.toggleFavorite('Are you a magician?',
          category: 'Cheesy');
      expect(controller.isFavorite('Are you a magician?'), isTrue);
      expect(controller.datingTipFavoriteCount, equals(0));

      // Add dating tip favorite
      await controller.toggleDatingTipFavorite(
        id: 'dating_tip_005',
        text: 'Tell a friend your plans before a first meeting.',
        category: 'Dating Safety',
        colorIndex: 4,
      );

      expect(controller.datingTipFavoriteCount, equals(1));
      expect(controller.isFavorite('Are you a magician?'), isTrue);
      // Dating tip text is not a pickup line
      expect(
          controller.favorites
              .where((f) => f.type != 'dating_tip')
              .map((f) => f.text),
          contains('Are you a magician?'));
      expect(
          controller.favorites
              .where((f) => f.type != 'dating_tip')
              .map((f) => f.text),
          isNot(contains('Tell a friend your plans before a first meeting.')));
    });
  });

  group('DatingTipsScreen Widget Tests', () {
    testWidgets('Renders tabs and tips list correctly',
        (WidgetTester tester) async {
      Get.put(FavoriteController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: DatingTipsScreen(),
        ),
      );

      // Loading indicator first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify AppBar and Tabs
      expect(find.text('Dating Tips'), findsOneWidget);
      expect(find.text('All Tips'), findsOneWidget);
      expect(find.text('Favourites (0)'), findsOneWidget);

      // Verify tip cards rendered
      expect(
          find.text(
              'Choose a low-pressure setting for a first date, like a casual cafe.'),
          findsOneWidget);

      // Tap favorite icon on the first tip
      final heartIcons = find.byIcon(Icons.favorite_outline_rounded);
      expect(heartIcons, findsWidgets);

      await tester.tap(heartIcons.first);
      await tester.pumpAndSettle();

      // Favorite count updated to 1
      expect(find.text('Favourites (1)'), findsOneWidget);

      // Switch to Favourites tab
      await tester.tap(find.text('Favourites (1)'));
      await tester.pumpAndSettle();

      // Only the favourited tip is present
      expect(
          find.text(
              'Choose a low-pressure setting for a first date, like a casual cafe.'),
          findsOneWidget);

      // Untap favorite
      final filledHeart = find.byIcon(Icons.favorite);
      expect(filledHeart, findsWidgets);
      await tester.tap(filledHeart.last);
      await tester.pumpAndSettle();

      // Empty state appears
      expect(find.text('No favourites yet'), findsOneWidget);
      expect(find.text('Favourites (0)'), findsOneWidget);
    });
  });
}
