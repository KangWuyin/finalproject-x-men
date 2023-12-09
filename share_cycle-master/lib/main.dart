import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_cycle/firebase_options.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/launch_page.dart';
import 'package:share_cycle/pages/login_page.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await Firebase.initializeApp(
  //     name: "Borrowin202311",
  //     options: FirebaseOptions(
  //       apiKey: '',
  //       appId: '1:192330804157:android:8f4d700cb57080697140d4',
  //       messagingSenderId: '',
  //       projectId: 'Borrowin202311',
  //     ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(460, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return OKToast(
          textPadding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
          // backgroundColor: Colors.grey,
          // textStyle: TextStyle(color: Colors.black),
          child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ShareCycle',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: LaunchPage(),
          localizationsDelegates: const [
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: const [
            Locale("en"),
            Locale("zh"),
          ],
          routes: {
            "/login":(BuildContext context)=>LoginPage(),
          },
        ),);
      },
    );
  }
}