import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flirtymessages/core/controllers/favorite_controller.dart';
import 'package:flirtymessages/features/dashboard/presentation/home_screen.dart';
import 'package:flirtymessages/features/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(FavoriteController());
  });

  testWidgets('SplashScreen displays clean launch logo and navigates to HomeScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashScreen(),
      ),
    );

    // Simple splash requirements
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('splash screen'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Fast-forward past 3-second timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Navigates to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
