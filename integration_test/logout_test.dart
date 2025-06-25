import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can logout and is redirected to login', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Log in (replace with valid credentials for your test user)
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Navigate to profile/settings page
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Scroll to make the logout button visible
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();

    // Tap the logout tile/button
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Confirm logout in dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Check if redirected to login screen
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
