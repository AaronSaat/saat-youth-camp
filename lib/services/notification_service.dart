import 'package:flutter/material.dart'
    show GlobalKey, MaterialPageRoute, Navigator, NavigatorState;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        AndroidInitializationSettings,
        AndroidNotificationDetails,
        AndroidScheduleMode,
        DarwinInitializationSettings,
        DarwinNotificationDetails,
        FlutterLocalNotificationsPlugin,
        Importance,
        InitializationSettings,
        NotificationDetails,
        Priority,
        DateTimeComponents,
        NotificationResponse;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:syc/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent re-initialization

    // try {1q
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // const initializationSettingsAndroid = AndroidInitializationSettings(
    //   'iconsmall.png',
    // );
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Disable notification permission request for iOS
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      // onDidReceiveBackgroundNotificationResponse requires a top-level or static
      // function; reuse the same handler so background taps are also routed.
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
    _isInitialized = true;
    // } catch (e) {
    //   final context = NotificationService.navigatorKey.currentContext;
    //   if (context != null) {
    //     showCustomSnackBar(context, 'Gagal inisialisasi notifikasi: $e');
    //   }
    // }
  }

  // Notification Details
  NotificationDetails notificationDetails() {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'syc_channel',
      'SYC Notifications',
      channelDescription: 'Channel for SYC notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    print('Notification tapped with payload: $payload');

    if (navigatorKey.currentState.toString().contains("splash")) {
      final context = navigatorKey.currentState!.context;

      // Navigate to SplashScreen dan clear semua route sebelumnya
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  }

  // Show Notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    return notificationPlugin.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails(),
      payload: payload,
    );
  }

  Future<void> scheduledNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
    int? id,
  }) async {
    // Pastikan timezone WIB (Asia/Jakarta)
    final wib = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(wib);
    // final now = tz.TZDateTime(wib, DateTime.now().year, 12, 30, 6, 0, 0);
    print('Current time (WIB): $now');

    // Konversi scheduledTime ke WIB
    var scheduledDateTime = tz.TZDateTime.from(scheduledTime, wib);
    print('Scheduled time (WIB): $scheduledDateTime');

    try {
      await notificationPlugin.zonedSchedule(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        scheduledDateTime,
        notificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Exact alarm not permitted, fallback to inexact: $e');
      await notificationPlugin.zonedSchedule(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        scheduledDateTime.isBefore(now)
            ? now.add(const Duration(seconds: 1))
            : scheduledDateTime,
        notificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    print(
      'Scheduled notification for $title at ${scheduledDateTime.toLocal()} (WIB)',
    );
  }

  Future<void> cancelNotification() async {
    if (!_isInitialized) {
      await initialize();
    }
    await notificationPlugin.cancelAll();
  }

  /// Cancel a single notification by its id.
  ///
  /// Use this when you scheduled notifications with a known `id` so you can
  /// cancel only that one instead of calling `cancelAll()`.
  Future<void> cancelNotificationById(int id) async {
    if (!_isInitialized) {
      await initialize();
    }
    await notificationPlugin.cancel(id);
  }

  // Background sync untuk pengumuman terbaru
  // static Future<void> checkLatestPengumuman() async {
  //   try {
  //     print('Background: Checking latest pengumuman...');

  //     // Ambil user_id dari SharedPreferences (asumsi sudah disimpan saat login)
  //     final prefs = await SharedPreferences.getInstance();
  //     final userId = prefs.getInt('id') ?? 80; // default 80 jika tidak ada

  //     // Hit API pengumuman
  //     final response = await http
  //         .get(
  //           Uri.parse(
  //             '${GlobalVariables.serverUrl}api-syc2025/pengumuman?user_id=$userId',
  //           ),
  //           headers: {'Content-Type': 'application/json'},
  //         )
  //         .timeout(Duration(seconds: 30));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       if (data['success'] == true && data['data_pengumuman'] != null) {
  //         final pengumumanList = data['data_pengumuman'] as List;

  //         if (pengumumanList.isNotEmpty) {
  //           // Ambil pengumuman terbaru (index 0 karena sudah diurutkan dari API)
  //           final latestPengumuman = pengumumanList[0];
  //           final latestId = latestPengumuman['id'];
  //           final latestCreatedAt = latestPengumuman['created_at'];

  //           // Cek last check time dari SharedPreferences
  //           final lastCheckTime = prefs.getInt('last_pengumuman_check') ?? 0;

  //           // Jika ada pengumuman baru (created_at lebih besar dari last check)
  //           if (latestCreatedAt > lastCheckTime) {
  //             print(
  //               'Background: New pengumuman found - ID: $latestId, Created At: $latestCreatedAt, Last Check: $lastCheckTime',
  //             );
  //             // Parse HTML content untuk body notification
  //             final htmlContent = latestPengumuman['detail'] ?? '';
  //             final document = html_parser.parse(htmlContent);
  //             final plainText = document.body?.text ?? htmlContent;

  //             // Buat notification
  //             final notificationService = NotificationService();
  //             await notificationService.showNotification(
  //               // tambahkan 📣
  //               title: latestPengumuman['judul'] ?? 'Pengumuman Baru',
  //               body:
  //                   plainText.length > 20
  //                       ? '${plainText.substring(0, 20)}...'
  //                       : plainText,
  //               payload: 'splash',
  //             );

  //             // Update last check time dengan created_at pengumuman terbaru
  //             await prefs.setInt('last_pengumuman_check', latestCreatedAt);

  //             print(
  //               'Background: Notification sent for pengumuman ID $latestId',
  //             );
  //           } else {
  //             print('Background: No new pengumuman found');
  //           }
  //         }
  //       }
  //     } else {
  //       print('Background: API error - Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Background: Error checking pengumuman - $e');
  //   }
  // }

  // // Fungsi untuk trigger pertama kali dari dashboard
  // static Future<void> initializePengumumanSync() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     // Set last check time ke waktu sekarang jika belum ada
  //     if (!prefs.containsKey('last_pengumuman_check')) {
  //       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //       await prefs.setInt('last_pengumuman_check', now);
  //       print('Initialized pengumuman sync with current time: $now');
  //     }

  //     // Langsung check pengumuman terbaru
  //     await checkLatestPengumuman();
  //   } catch (e) {
  //     print('Error initializing pengumuman sync: $e');
  //   }
  // }
}
