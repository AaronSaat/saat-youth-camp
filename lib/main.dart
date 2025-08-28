import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/screens/hapus_akun_detail_success_screen.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/screens/profile_edit_screen.dart';
import 'package:syc/screens/review_komitmen_screen.dart';
import 'package:syc/screens/scan_qr_screen.dart';
import 'package:syc/services/notification_service.dart'
    show NotificationService;
import 'package:syc/services/background_task_service.dart';
import 'package:syc/utils/app_colors.dart';

import 'orientation_guard.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

// Background fetch callback
// @pragma('vm:entry-point')
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;

//   if (isTimeout) {
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }

//   print('[BackgroundFetch] Headless event received: $taskId');

//   // Check for latest pengumuman
//   await NotificationService.checkLatestPengumuman();

//   BackgroundFetch.finish(taskId);
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize notification service
  // await NotificationService().initialize();

  // Initialize background task service
  // await BackgroundTaskService.initialize();

  // // Register background fetch headless task
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

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
      // home: ReviewKomitmenScreen(userId: '80', acaraHariId: 1),

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
