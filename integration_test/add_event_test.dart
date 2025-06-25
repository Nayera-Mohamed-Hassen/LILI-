import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can add a new event after logging in', (WidgetTester tester) async {
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

    // Tap the Family Calendar menu item
    await tester.tap(find.byKey(const Key('family_calendar_menuitem')));
    await tester.pumpAndSettle();

    // Tap FAB to add a new event
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill in the event form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Integration Test Event');
    await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'This is a test event.');
    await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'Test Location');

    // Tap the 'Add' button to submit the event
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Confirm the event appears in the list
    expect(find.text('Integration Test Event'), findsOneWidget);
  });
}
