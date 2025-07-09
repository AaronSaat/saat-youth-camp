import 'package:flutter/material.dart'
    show GlobalKey, NavigatorState, Navigator, MaterialPageRoute;
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

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationPlugin.initialize(initializationSettings);
    _isInitialized = true;
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  // Show Notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    return notificationPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
  }) async {
    // get current date and time in local timezone
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await notificationPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      scheduledDateTime.isBefore(now)
          ? now.add(const Duration(seconds: 1))
          : scheduledDateTime,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // repeat this everyday sama time
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // print(
    //   'Scheduled notification for $title at ${scheduledDateTime.toLocal()}',
    // );
  }

  Future<void> cancelNotification() async {
    if (!_isInitialized) {
      await initialize();
    }
    await notificationPlugin.cancelAll();
  }
}
