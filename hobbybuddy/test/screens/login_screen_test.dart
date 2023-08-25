import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/login.dart';

void main() async {
  testWidgets('LogInScreen renders correctly with button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(2),
    );
        await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is ElevatedButton),
      findsNWidgets(2),
    );
  });
}
