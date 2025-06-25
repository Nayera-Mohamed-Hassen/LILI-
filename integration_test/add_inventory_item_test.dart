import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:LILI/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can add a new inventory item', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // Enter login credentials
    await tester.enterText(find.byKey(const Key('username')), 'ganna');
    await tester.enterText(find.byKey(const Key('password')), '1234');

    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 3));

    // Open the menu (or navigate to calendar)
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Tap the inventory menu item
    final inventoryMenuItem = find.byKey(const Key('inventory_menuitem'));
    expect(inventoryMenuItem, findsOneWidget);
    await tester.tap(inventoryMenuItem);
    await tester.pumpAndSettle();

    // Tap the FloatingActionButton to open the add menu
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap the 'Add New Item' popup menu entry
    await tester.tap(
      find.widgetWithText(PopupMenuItem<String>, 'Add New Item'),
    );
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 3));

    // Fill in the form fields
    await tester.enterText(
      find.widgetWithText(TextField, 'Item Name'),
      'Integration Test Item',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '5');
    await tester.enterText(
      find.widgetWithText(TextField, 'Amount (optional)'),
      '2',
    );

    // Select a category (dropdown)
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Category'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    // Tap the add button
    final addButton = find.byKey(const Key('add_inventory_item_button'));
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Dismiss success dialog if shown
    final okButton = find.widgetWithText(TextButton, 'OK');
    if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton);
      await tester.pumpAndSettle();
    }

    // Verify the item appears in the inventory list
    expect(find.text('Integration Test Item'), findsWidgets);
  });
}
