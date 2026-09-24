import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flirtymessages/features/love_tester/screens/love_tester_screen.dart';

void main() {
  testWidgets('LoveTesterScreen builds properly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoveTesterScreen(),
      ),
    );

    expect(find.text('Love Tester'), findsOneWidget);
    expect(find.text('Are You a Match?'), findsOneWidget);
    expect(find.text('Calculate Love Score'), findsOneWidget);
    expect(find.text('Calculate All Tests'), findsOneWidget);
  });
}
