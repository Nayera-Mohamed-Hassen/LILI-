import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tap notification navigates to correct screen', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    // Add steps to tap notification
    // Add expect for navigation
  });
} 