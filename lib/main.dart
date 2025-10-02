import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syc/firebase_options.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'orientation_guard.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isIOS) {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Listen for token refresh (APNS token ready)
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        print('FCM Token (onTokenRefresh): $token');
      });
      // Optionally, try getToken() (will return null if APNS belum siap)
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print('FCM Token (getAPNSToken): $apnsToken');
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token (getToken): $token');
    } else {
      print('User declined or has not accepted notification permissions');
    }
  } else if (Platform.isAndroid) {
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token (Android): $token');
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print('FCM Token (Android onTokenRefresh): $token');
    });
  }

  FirebaseMessaging.instance.subscribeToTopic('syc');
  print('Subscribed to topic "syc"');

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
      // home: HapusAkunDetailSuccessScreen(name: 'John Doe', isSuccess: true),
      // home: CheckSecretSuccessScreen(),

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
    );
  }
}
