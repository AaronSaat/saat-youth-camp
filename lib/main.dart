import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

import 'screens/login_screen.dart';
import 'screens/direct_to_gmail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SYC 2024 APP',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      // home: const DirectToGmailScreen(),
    );
  }
}
