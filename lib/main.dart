import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syc/firebase_options.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'orientation_guard.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Navigasi ke screen sesuai data notifikasi
    final tujuan = message.data['screen'];

    switch (tujuan) {
      case 'splash':
        print('Navigating to Splash Screen');
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
        break;
      // Tambahkan case lain sesuai kebutuhan
      default:
        // Default action jika screen tidak dikenali
        print('Navigating to Splash Screen');
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
        break;
    }
  });

  if (Platform.isIOS) {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted notification permissions');
    }
  } else if (Platform.isAndroid) {
    // Request notification permission for Android 13+ (API 33+)
    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        // ignore: use_build_context_synchronously
        final permission = await Permission.notification.request();
        if (permission.isGranted) {
          print('Android notification permission granted');
        } else {
          print('Android notification permission denied');
        }
      }
    } catch (e) {
      print('Error requesting Android notification permission: $e');
    }
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
      title: 'SAAT Youth Camp',
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
