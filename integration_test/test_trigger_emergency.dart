import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Trigger emergency alert', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    // Login
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    // Go to SOS page via navbar
    await tester.tap(find.byKey(const Key('sos_button')));
    await tester.pumpAndSettle();
    // Tap the bell icon (notifications_active) near 'Family' contact
    final bellIcon = find.descendant(
      of: find.widgetWithText(ListTile, 'Family'),
      matching: find.byIcon(Icons.notifications_active),
    );
    await tester.tap(bellIcon);
    await tester.pumpAndSettle();
    // Optionally, verify an alert appears in the recent alerts list
    expect(find.textContaining('SOS Emergency'), findsWidgets);
  });
} 