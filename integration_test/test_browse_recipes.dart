import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Browse available recipes', (WidgetTester tester) async {
    // Launch the app
     app.main();
    await tester.pumpAndSettle();

    // Enter login credentials
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Open the menu (or navigate to calendar)
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Tap 'Suggests Recipe' menu item
    final recipeMenuItem = find.byKey(const Key('recipe_menuitem'));
    expect(recipeMenuItem, findsOneWidget);
    await tester.tap(recipeMenuItem);
    await tester.pumpAndSettle();

    // Wait for recipes to load (replace with real logic if needed)
    await tester.pump(const Duration(seconds: 10));

    // Verify at least one recipe card is displayed
    expect(find.byType(Card), findsWidgets);
  });
}
