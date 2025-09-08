import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/services/api_service.dart';
import 'package:syc/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:syc/screens/check_secret_success_screen.dart.dart';
import 'package:syc/screens/evaluasi_komitmen_success_screen.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/screens/hapus_akun_detail_success_screen.dart';
import 'package:syc/screens/konfirmasi_registrasi_ulang_success_screen.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/screens/profile_edit_screen.dart';
import 'package:syc/screens/review_komitmen_screen.dart';
import 'package:syc/screens/scan_qr_screen.dart';
import 'package:syc/services/notification_service.dart'
    show NotificationService;
import 'package:syc/services/background_task_service.dart';
import 'package:syc/utils/api_helper.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syc/utils/global_variables.dart';
import 'package:syc/widgets/custom_snackbar.dart' show showCustomSnackBar;
import 'package:workmanager/workmanager.dart';

// import 'orientation_guard.dart';
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

// Inisialisasi plugin notifikasi
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void setupFCM() async {
  // Permission (iOS)`
  await FirebaseMessaging.instance.requestPermission();

  // Init local notification
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Listener pesan foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'channel_description',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}

// Fungsi background task
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // print('[NOTIF] Background task "$task" started');
    // ...existing notification code (commented)...

    // Panggil API dan print response ke debug console
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        print('[WORKMANAGER] Token not found in SharedPreferences');
        return Future.value(false);
      }

      final url = Uri.parse(
        '${GlobalVariables.serverUrl}pengumuman?user_id=98',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[WORKMANAGER] url $url');
      print('[WORKMANAGER] response ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List pengumuman = decoded['data_pengumuman'] ?? [];
        print('[WORKMANAGER] pengumuman: $pengumuman');
        return Future.value(true);
      } else {
        print(
          '[WORKMANAGER] ❌ Error: ${response.statusCode} - ${response.body}',
        );
        return Future.value(false);
      }
    } catch (e) {
      print('[WORKMANAGER] Exception: $e');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize notification service
  // await NotificationService().initialize();

  // Initialize background task service
  // await BackgroundTaskService.initialize();

  // // Register background fetch headless task
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  // firebase initialize
  // await Firebase.initializeApp();
  // setupFCM();
  // FirebaseMessaging.instance.getAPNSToken().then((apnsToken) {
  //   print('APNS Token: $apnsToken');
  // });
  // FirebaseMessaging.instance.getToken().then((token) {
  //   print('FCM Token: $token');
  // });

  // workmanager initialize
  // await Workmanager().initialize(callbackDispatcher);
  // await Workmanager().registerPeriodicTask(
  //   "uniqueTaskName",
  //   "simplePeriodicTask",
  //   frequency: const Duration(
  //     seconds: 30,
  //   ), // minimal 15 menit di Android, iOS tidak support interval pendek
  // );

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
