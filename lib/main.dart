import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/screens/test_screen3.dart';
import 'package:syc/screens/test_screen4.dart';
import 'package:syc/utils/app_colors.dart';

import 'orientation_guard.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

// void main() {
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
  // runApp(OrientationGuard(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SYC 2025 APP',
      theme: ThemeData(
        fontFamily: 'Geist',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
      // home: TestScreen4(),

      // ganti desain
      // home: LoginScreen(),
      // home: EvaluasiKomitmenSuccessScreen(
      //   userId: '80',
      //   type: 'Komitmen',
      //   isSuccess: true,
      // ),
      // home: ReadMoreSuccessScreen(),
      // home: TestScreen2(), //ini untuk gereja kelompok anggota
      // home: ReadMoreScreen(userId: "80"),
      // home: FormKomitmenScreen(userId: "80", acaraHariId: 2),
      // home: EvaluasiKomitmenListScreen(type: 'Komitmen', userId: '80'),

      // home: KomitmenScreen(userId: 2, day: 1),
      // home: EvaluasiKomitmenFormScreen(
      //   type: 'Evaluasi',
      //   userId: '1',
      //   acaraHariId: 1,
      // ),
    );
  }
}
