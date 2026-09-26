import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flirtymessages/core/constants/category/all_category_tabs.dart';
import 'package:flirtymessages/core/constants/category/category_tile.dart';
import 'package:flirtymessages/core/network/models/pickup_line_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Category cards in AllCategoryTabs do not render line counts',
      (WidgetTester tester) async {
    final testPickupLines = [
      PickupLineModel(text: 'Line 1', category: 'Cheesy'),
      PickupLineModel(text: 'Line 2', category: 'Cheesy'),
      PickupLineModel(text: 'Line 3', category: 'Romantic'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AllCategoryTabs(pickupLines: testPickupLines),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Category names are rendered
    expect(find.text('Cheesy Lines'), findsOneWidget);
    expect(find.text('Romantic Lines'), findsOneWidget);

    // Line counts MUST NOT be rendered
    expect(find.text('2 lines'), findsNothing);
    expect(find.text('1 lines'), findsNothing);
    expect(find.textContaining('lines'), findsNothing);
  });

  testWidgets('CategoryTile respects showCount parameter',
      (WidgetTester tester) async {
    const summary = CategorySummary(
      name: 'Funny',
      displayName: 'Funny Lines',
      itemCount: 5,
      backgroundColor: Colors.white,
      accentColor: Colors.blue,
      icon: Icons.sentiment_very_satisfied,
    );

    // When showCount is false
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryTile(
            category: summary,
            showCount: false,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Funny Lines'), findsOneWidget);
    expect(find.text('5 lines'), findsNothing);

    // When showCount is true
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryTile(
            category: summary,
            showCount: true,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Funny Lines'), findsOneWidget);
    expect(find.text('5 lines'), findsOneWidget);
  });
}
