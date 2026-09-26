import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/controllers/favorite_controller.dart';
import 'package:flirtymessages/core/controllers/pickup_line_maker_controller.dart';
import 'package:flirtymessages/features/pickup_line/pickup_line_maker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  group('PickupLineMakerController Unit Tests', () {
    test('initializes with initial text and updates reactively', () {
      final controller = PickupLineMakerController();
      controller.initText('You must be a magician.');

      expect(controller.text.value, 'You must be a magician.');
      expect(controller.fontSize.value, 24.0);
      expect(controller.selectedFontFamily.value, 'Roboto');
      expect(controller.textAlign.value, TextAlign.center);

      controller.updateText('Updated text');
      expect(controller.text.value, 'Updated text');
    });

    test('text case cycles through UPPERCASE, lowercase, original', () {
      final controller = PickupLineMakerController();
      controller.initText('Hello World');
      final textController = TextEditingController(text: 'Hello World');

      controller.cycleTextCase(textController);
      expect(controller.text.value, 'HELLO WORLD');
      expect(textController.text, 'HELLO WORLD');

      controller.cycleTextCase(textController);
      expect(controller.text.value, 'hello world');
      expect(textController.text, 'hello world');

      controller.cycleTextCase(textController);
      expect(controller.text.value, 'Hello World');
      expect(textController.text, 'Hello World');
    });

    test('text alignment cycles center -> left -> right -> center', () {
      final controller = PickupLineMakerController();
      expect(controller.textAlign.value, TextAlign.center);

      controller.cycleTextAlign();
      expect(controller.textAlign.value, TextAlign.left);

      controller.cycleTextAlign();
      expect(controller.textAlign.value, TextAlign.right);

      controller.cycleTextAlign();
      expect(controller.textAlign.value, TextAlign.center);
    });

    test('styling toggles work as expected', () {
      final controller = PickupLineMakerController();

      controller.toggleBold();
      expect(controller.isBold.value, isTrue);

      controller.toggleItalic();
      expect(controller.isItalic.value, isTrue);

      controller.toggleUnderline();
      expect(controller.isUnderline.value, isTrue);

      controller.setFontSize(32.0);
      expect(controller.fontSize.value, 32.0);

      controller.setLineSpacing(2.0);
      expect(controller.vSpacing.value, 2.0);

      controller.setTextSpacing(4.0);
      expect(controller.textSpacing.value, 4.0);
    });

    test('background and color updates work', () {
      final controller = PickupLineMakerController();

      controller.setBackgroundColor(Colors.pink.shade100);
      expect(controller.selectedColor.value, Colors.pink.shade100);
      expect(controller.selectedGradient.value, isNull);

      const grad = LinearGradient(colors: [Colors.red, Colors.blue]);
      controller.setGradient(grad);
      expect(controller.selectedGradient.value, grad);

      controller.removeBackground();
      expect(controller.selectedColor.value, Colors.white);
      expect(controller.selectedGradient.value, isNull);

      controller.setTextColor(Colors.deepPurple);
      expect(controller.isSelectedTextColor.value, Colors.deepPurple);
    });

    test('border and shadow controls update state', () {
      final controller = PickupLineMakerController();

      controller.setBorder(enabled: true, color: Colors.red, width: 4.0);
      expect(controller.hasBorder.value, isTrue);
      expect(controller.borderColor.value, Colors.red);
      expect(controller.borderWidth.value, 4.0);

      controller.setShadow(
        enabled: true,
        color: Colors.blue,
        dx: 3.0,
        dy: 3.0,
        blur: 10.0,
      );
      expect(controller.hasShadow.value, isTrue);
      expect(controller.selectedShadowColor.value, Colors.blue);
      expect(controller.shadowOffsetX.value, 3.0);
      expect(controller.shadowBlur.value, 10.0);
    });

    test('aspect ratio / crop updates state', () {
      final controller = PickupLineMakerController();
      expect(controller.cardAspectRatio.value, 0.0);

      controller.setAspectRatio(1.0);
      expect(controller.cardAspectRatio.value, 1.0);

      controller.setAspectRatio(9 / 16);
      expect(controller.cardAspectRatio.value, 9 / 16);
    });
  });

  group('PickupLineMakerScreen Widget Tests', () {
    testWidgets('loads with initial pickup line and renders toolbar',
        (WidgetTester tester) async {
      Get.put(FavoriteController());

      await tester.pumpWidget(
        const MaterialApp(
          home: PickupLineMakerScreen(
            initialText: 'Are you French? Because Eiffel for you.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pickup Line Maker'), findsOneWidget);
      expect(find.text('Are you French? Because Eiffel for you.'), findsOneWidget);

      // Verify tool bar buttons exist
      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Font'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Border'), findsOneWidget);
      expect(find.text('Shadow'), findsOneWidget);
      expect(find.text('Gradient'), findsOneWidget);
      expect(find.text('Opacity'), findsOneWidget);
      expect(find.text('Padding'), findsOneWidget);
      expect(find.text('Crop'), findsOneWidget);

      // Download and Share buttons in AppBar
      expect(find.byTooltip('Download'), findsOneWidget);
      expect(find.byTooltip('Share'), findsOneWidget);
    });
  });
}
