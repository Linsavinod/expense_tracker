import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:etra/main.dart'; // Update with your actual app path

void main() {
  testWidgets('Expense Tracker loads and shows input fields', (WidgetTester tester) async {
    await tester.pumpWidget(ExpenseTrackerApp());

    // Verify title input exists
    expect(find.byType(TextField), findsNWidgets(2)); // Title + Amount fields
    expect(find.text('Expense Title'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);

    // Verify Add Expense button exists
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
