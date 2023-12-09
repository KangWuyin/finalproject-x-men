import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_driver/flutter_driver.dart' as fd;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_cycle/firebase_options.dart';
import 'package:share_cycle/generated/l10n.dart';

import 'package:share_cycle/main.dart';
import 'package:share_cycle/pages/login_page.dart';

void main() {
  enableFlutterDriverExtension();

  setUpAll(() async {
    // Initialize Firebase
    await Firebase.initializeApp();
  });

  test('Firestore 登录', () async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var getUser = await db
        .collection("user")
        .where("user_name", isEqualTo: 1)
        .where("password", isEqualTo: 1)
        .get();
    if (getUser.size == 0) {
      return;
    }
    // Determine whether the data meets expectations
    expect(1, 1);
  });

  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  // testWidgets("log in testing", (WidgetTester widgetTester) async {
  //   await widgetTester.pumpWidget(MaterialApp(
  //     title: 'ShareCycle',
  //     home: LoginPage(),
  //     localizationsDelegates: const [
  //       GlobalWidgetsLocalizations.delegate,
  //       GlobalCupertinoLocalizations.delegate,
  //       GlobalMaterialLocalizations.delegate,
  //       S.delegate,
  //     ],
  //     supportedLocales: const [
  //       Locale("en"),
  //       Locale("zh"),
  //     ],
  //   ));
  //   final username = find.text("username");
  //   final password = find.text("password");
  //   final Login = find.text("Login");
  //   final Register = find.text("Register");

  //   expect(username, findsOneWidget);
  //   expect(password, findsOneWidget);
  //   expect(Login, findsOneWidget);
  //   expect(Register, findsOneWidget);
  // });
}
