import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/constants/pickup_line/pickup_line_card.dart';
import 'package:flirtymessages/core/controllers/favorite_controller.dart';
import 'package:flirtymessages/core/network/models/pickup_line_model.dart';

RenderRepaintBoundary? nearestBoundaryAncestor(RenderObject start) {
  RenderObject? node = start.parent;
  while (node != null) {
    if (node is RenderRepaintBoundary) return node;
    node = node.parent;
  }
  return null;
}

bool isAncestorOf(RenderObject ancestor, RenderObject node) {
  RenderObject? current = node;
  while (current != null) {
    if (identical(current, ancestor)) return true;
    current = current.parent;
  }
  return false;
}

RenderObject renderObjectOf(Finder finder) =>
    finder.evaluate().first.renderObject!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  group('List card capture boundary', () {
    Future<void> pumpListCard(WidgetTester tester, String text) async {
      if (!Get.isRegistered<FavoriteController>()) {
        Get.put(FavoriteController());
      }
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PickupLineCard(
              pickupLines: [
                PickupLineModel(text: text, category: 'cheesy'),
              ],
              mode: PickupLineCardMode.list,
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('action chips are outside the capture boundary',
        (WidgetTester tester) async {
      await pumpListCard(
          tester, 'Are you a parking ticket? Because you have fine written all over you.');

      final cardBoundary =
          nearestBoundaryAncestor(renderObjectOf(find.textContaining('parking ticket')))!;
      expect(cardBoundary, isA<RenderRepaintBoundary>());
      expect(cardBoundary.size.height, 245,
          reason: 'Boundary must cover the full gradient visual card');

      for (final label in ['Copy', 'Edit', 'Save', 'Share']) {
        expect(
          isAncestorOf(cardBoundary, renderObjectOf(find.text(label))),
          isFalse,
          reason: '$label chip must not be inside the card capture boundary',
        );
      }

      // Favorite and quote icons are part of the card visual and stay inside.
      expect(
        isAncestorOf(cardBoundary,
            renderObjectOf(find.byIcon(Icons.favorite_border))),
        isTrue,
      );
      expect(
        isAncestorOf(cardBoundary,
            renderObjectOf(find.byIcon(Icons.format_quote_rounded).first)),
        isTrue,
      );
    });

    testWidgets('boundary keeps full card size for short and long text',
        (WidgetTester tester) async {
      await pumpListCard(tester, 'Hi.');
      expect(
        nearestBoundaryAncestor(
            renderObjectOf(find.text('Hi.')))!.size.height,
        245,
      );

      await pumpListCard(
          tester, 'Do you have a map? Because I keep getting lost in your eyes every single time I look at you.');
      expect(
        nearestBoundaryAncestor(
            renderObjectOf(find.textContaining('getting lost')))!.size.height,
        245,
      );
    });
  });

  group('Carousel card capture boundary', () {
    Future<void> pumpCarouselCard(WidgetTester tester, String text) async {
      if (!Get.isRegistered<FavoriteController>()) {
        Get.put(FavoriteController());
      }
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PickupLineCard(
                pickupLines: [
                  PickupLineModel(text: text, category: 'flirty'),
                ],
                mode: PickupLineCardMode.carousel,
              ),
            ),
          ),
        ),
      );
      // Plain pumps only: autoPlay schedules endless frames, so
      // pumpAndSettle would never settle.
      await tester.pump();
      await tester.pump();
    }

    testWidgets('action row buttons are outside the capture boundary',
        (WidgetTester tester) async {
      await pumpCarouselCard(tester, 'Do you believe in love at first sight?');

      final cardBoundary =
          nearestBoundaryAncestor(renderObjectOf(find.textContaining('first sight')))!;
      expect(cardBoundary, isA<RenderRepaintBoundary>());
      expect(cardBoundary.size.height, 200,
          reason: 'Boundary must cover the full carousel card');

      for (final icon in [
        Icons.favorite_border,
        Icons.bookmark_border_rounded,
        Icons.mode_edit_outlined,
        Icons.share_outlined,
      ]) {
        expect(
          isAncestorOf(cardBoundary, renderObjectOf(find.byIcon(icon))),
          isFalse,
          reason: 'Action button $icon must not be inside the capture boundary',
        );
      }

      // Card visuals stay inside the boundary.
      expect(
        isAncestorOf(cardBoundary,
            renderObjectOf(find.byIcon(Icons.format_quote_rounded))),
        isTrue,
      );
      // Pickup Line of the Day label must NOT be inside the card capture boundary
      expect(
        isAncestorOf(cardBoundary, renderObjectOf(find.text('Pickup Line of the Day'))),
        isFalse,
        reason: 'Pickup Line of the Day label must be outside capture boundary',
      );
    });

    testWidgets('boundary keeps full card size for short and long text',
        (WidgetTester tester) async {
      await pumpCarouselCard(tester, 'Hi.');
      expect(
        nearestBoundaryAncestor(renderObjectOf(find.text('Hi.')))!.size.height,
        200,
      );

      await pumpCarouselCard(
          tester, 'Do you have a map? Because I keep getting lost in your eyes.');
      expect(
        nearestBoundaryAncestor(
            renderObjectOf(find.textContaining('getting lost')))!.size.height,
        200,
      );
    });
  });
}
