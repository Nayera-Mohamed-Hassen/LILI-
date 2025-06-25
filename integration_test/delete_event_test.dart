import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can delete an event after adding it', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // Log in
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Navigate to Family Calendar
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('family_calendar_menuitem')));
    await tester.pumpAndSettle();

    // Add a new event
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Delete Test Event');
    await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Event to be deleted.');
    await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'Test Location');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Confirm the event appears
    expect(find.text('Delete Test Event'), findsOneWidget);

    // Delete the event by swiping (Dismissible)
    final eventFinder = find.text('Delete Test Event');
    final dismissibleFinder = find.ancestor(of: eventFinder, matching: find.byType(Dismissible));

    expect(dismissibleFinder, findsOneWidget); // Ensure the dismissible exists

    await tester.drag(dismissibleFinder, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // (Optional) Tap delete button in a dialog if shown
    // await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    // await tester.pumpAndSettle();

    // Confirm the event is gone
    expect(find.text('Delete Test Event'), findsNothing);
  });
}
