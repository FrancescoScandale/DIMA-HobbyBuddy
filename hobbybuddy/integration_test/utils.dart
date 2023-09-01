import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future tapOnWidgetByKey({
  required String key,
  required WidgetTester tester,
}) async {
  final widget = await find.byKey(Key(key));
  expect(widget, findsOneWidget);
  await tester.tap(widget);
  await tester.pumpAndSettle();
}

Future logoutTest({required WidgetTester tester}) async {
  // Logout
  final settingsIcon = find.byIcon(Icons.account_circle, skipOffstage: false);
  await tester.pumpAndSettle();
  if (settingsIcon.evaluate().isEmpty) {
    tester.printToConsole("Already logged out");
    return;
  }
  expect(settingsIcon, findsOneWidget);
  await tester.tap(settingsIcon);
  await tester.pumpAndSettle();
  final logoutIcon = find.byIcon(Icons.logout).first;
  expect(logoutIcon, findsOneWidget);
  await tester.tap(logoutIcon);
  await tester.pumpAndSettle();
  await tapOnWidgetByKey(key: "alert_confirm", tester: tester);
  expect(find.byKey(const Key("log_in_to_sign_up_screen")), findsOneWidget);
}
