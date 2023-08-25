import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:hobbybuddy/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('widgets folder test', () {
    testWidgets('ContainerShadow has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ContainerShadow(
                child: Text("Hello", textDirection: TextDirection.ltr),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                width: 200,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('MyAppBar has a title', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: MyAppBar(
                title: "AppBar title",
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AppBar title'), findsOneWidget);
    });

    testWidgets('MyButton has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyButton(
                  text: "MyButton text",
                  onPressed: () async {},
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('MyButton text'), findsOneWidget);
      await tester.tap(find.byWidgetPredicate((widget) => widget is MyButton));
      await tester.pumpAndSettle();
    });

    testWidgets('MyIconButton has an icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyIconButton(
                  icon: Icon(Icons.abc),
                  onTap: () async {},
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc),
          findsOneWidget);
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyIconButton));
    });

    testWidgets('showSnackBar renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyButton(
                  text: "Show the snackbar",
                  onPressed: () async {
                    showSnackBar(context, "This is a snackbar");
                  },
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate((widget) => widget is MyButton));
      await tester.pump(Duration(seconds: 1));
      expect(find.text('This is a snackbar'), findsOneWidget);
    });

    testWidgets('ResponsiveWrapper has a text', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveWrapper(
                child: Text("Hello"),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
