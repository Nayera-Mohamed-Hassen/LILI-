import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login with valid credentials', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('username')), 'validuser');
    await tester.enterText(find.byKey(const Key('password')), 'validpass');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    // Add expect for successful login (e.g., homepage or success message)
  });

  testWidgets('Login with invalid credentials', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('username')), 'invaliduser');
    await tester.enterText(find.byKey(const Key('password')), 'wrongpass');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    // Add expect for error message
  });
} 