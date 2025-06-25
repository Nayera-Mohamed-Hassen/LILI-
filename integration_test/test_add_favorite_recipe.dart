import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add recipe to favorites and verify', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    // Login
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    // Open main menu
    await tester.tap(find.byKey(const Key('menu_button')));
    await tester.pumpAndSettle();
    // Tap 'Suggests Recipe' menu item
    await tester.tap(find.byKey(const Key('recipe_menuitem')));
    await tester.pumpAndSettle();
    // Wait for recipes to load
    await tester.pump(const Duration(seconds: 10));
    // Tap the heart icon on the first recipe card
    final firstFavoriteIcon = find.descendant(
      of: find.byType(Card).first,
      matching: find.byIcon(Icons.favorite_border),
    );
    await tester.tap(firstFavoriteIcon);
    await tester.pumpAndSettle();
    // Verify the icon is now filled (favorite)
    final filledHeart = find.descendant(
      of: find.byType(Card).first,
      matching: find.byIcon(Icons.favorite),
    );
    expect(filledHeart, findsOneWidget);
  });
} 