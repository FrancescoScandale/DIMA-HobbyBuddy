import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/sign_up.dart';
import 'package:hobbybuddy/widgets/button.dart';

void main() {
  testWidgets('SignUpScreen displays form and handles sign-up', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(6),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is MyButton),
      findsOneWidget,
    );
  });
}
