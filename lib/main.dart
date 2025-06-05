import 'package:flutter/material.dart';
import 'package:syc/screens/check_secret_screen.dart';
import 'package:syc/screens/dashboard_screen.dart';
import 'package:syc/screens/detail_acara_screen.dart';
import 'package:syc/screens/evaluasi_komitmen_list_screen.dart';
import 'package:syc/screens/evaluasi_komitmen_success_screen.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/screens/gereja_kelompok_anggota_screen.dart';
import 'package:syc/screens/review_evaluasi_screen.dart';
import 'package:syc/screens/read_more_screen.dart';
import 'package:syc/screens/test_screen.dart';
import 'package:syc/utils/app_colors.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/direct_to_gmail_screen.dart';
import 'screens/test_screen2.dart';

void main() {
  runApp(const MyApp());
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
      // home: const SplashScreen(),

      // ganti desain
      home: LoginScreen(),
      // home: TestScreen2(), //ini untuk gereja kelompok anggota
      // home: ReadMoreScreen(userId: "80"),
      // home: EvaluasiKomitmenSuccessScreen(
      //   userId: "80",
      //   type: "Komitmen",
      //   isSuccess: true,
      // ),
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
