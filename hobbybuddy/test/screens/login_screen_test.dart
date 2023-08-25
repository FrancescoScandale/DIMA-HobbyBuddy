import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/login.dart';

//class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  //setUp(() {
  // Mock SharedPreferences initialization
  // SharedPreferences.setMockInitialValues({});
  //});
  testWidgets('LogInScreen renders correctly with button', (tester) async {
    //await Preferences.init();
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
        //navigatorObservers: [MockNavigatorObserver()],
      ),
    );

    final userField = find.byKey(const Key("u_field"));
    expect(userField, findsOneWidget);

    final passwordField = find.byKey(const Key("p_field"));
    expect(passwordField, findsOneWidget);

    final button = find.byKey(const Key("go_login"));
    expect(button, findsOneWidget);

    // Fill in the username and password fields
    await tester.enterText(userField, 'testusername');
    await tester.enterText(passwordField, 'testpassword');

    // Tap the login button
    await tester.tap(button);
    await tester.pumpAndSettle();

    // Add more assertions if needed based on your app's behavior
  });
}
