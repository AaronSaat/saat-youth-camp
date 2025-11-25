import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syc/screens/splash_screen.dart';

/// Top-level background handler required by `firebase_messaging`.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Minimal background handling: log and return. Avoid UI work here.
  print('FCM background handler: received ${message.messageId}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize listeners and local notification plugin.
  /// Pass the app's [navigatorKey] to perform navigation from background/terminated.
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    // Initialize flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(payload);
            _handlePayloadNavigation(data, navigatorKey);
          } catch (e) {
            print('Error decoding notification payload: $e');
          }
        }
      },
    );

    // Ensure Android notification channel exists (required on Android 8+)
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'fcm_channel', // id
        'FCM Notifications', // name
        description: 'This channel is used for FCM notifications',
        importance: Importance.max,
      );
      final androidImpl =
          _localPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImpl?.createNotificationChannel(channel);
    } catch (e) {
      print('Error creating notification channel: $e');
    }

    // For iOS, request that notifications are shown when app is in foreground
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      print('Error setting iOS foreground presentation options: $e');
    }

    // Request permission (iOS and Android 13+). Good to log the result.
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        provisional: false,
        sound: true,
      );
      print('FCM permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error requesting notification permission: $e');
    }

    // Foreground messages -> show local notification when appropriate.
    // On Android we show local notifications for all messages. On iOS,
    // if the message contains a `notification` section the system will
    // present it when `setForegroundNotificationPresentationOptions`
    // is enabled; to avoid duplicate notifications we only show a
    // local notification on iOS when the message is data-only.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Log incoming message to terminal for debugging
      print(
        'FCM onMessage received: title=${message.notification?.title}, body=${message.notification?.body}, data=${message.data}',
      );

      if (Platform.isAndroid) {
        showLocalNotification(message);
        return;
      }

      if (Platform.isIOS) {
        // If iOS message contains `notification`, the system will present it
        // (because we set presentation options). Only show local notif for
        // data-only messages to avoid duplicates.
        if (message.notification == null) {
          showLocalNotification(message);
        } else {
          print(
            'iOS: skipping manual local notification (system will present)',
          );
        }
        return;
      }

      // Fallback for other platforms
      showLocalNotification(message);
    });

    // Handle taps when app is backgrounded / terminated and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, navigatorKey);
    });

    // Handle cold-start from notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      Future.microtask(() => _handleMessage(initial, navigatorKey));
    }
  }

  static void _handleMessage(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    try {
      final tujuan = message.data['tujuan']?.toString() ?? '';
      final id = int.tryParse(message.data['id']?.toString() ?? '0') ?? 0;
      final userId = message.data['user_id']?.toString() ?? '';

      print(
        'FCM NotificationService: handleMessage tujuan=$tujuan id=$id userId=$userId',
      );

      switch (tujuan) {
        case 'pengumuman_list':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        case 'acara_list':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        case 'evaluasi_list':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        case 'dashboard':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        // Tambahkan case lain sesuai kebutuhan
        default:
          // Default action jika screen tidak dikenali
          print('Navigating to Splash Screen');
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
          break;
      }
    } catch (e) {
      print('NotificationService._handleMessage error: $e');
    }
  }

  /// Public helper to show a local notification from anywhere in the app.
  static Future<void> showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notifikasi';
    final body = message.notification?.body ?? '';

    // Log that we're about to show a local notification
    print(
      'Showing local notification: title=$title, body=$body, data=${message.data}',
    );

    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'This channel is used for FCM notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Encode data as JSON so we can decode it when the user taps the notification
    final payload = jsonEncode(message.data);

    await _localPlugin.show(
      message.hashCode,
      title,
      body,
      notifDetails,
      payload: payload,
    );
  }

  static void _handlePayloadNavigation(
    Map<String, dynamic> data,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    try {
      final tujuan = data['tujuan']?.toString() ?? '';
      final id = int.tryParse(data['id']?.toString() ?? '0') ?? 0;
      final userId = data['user_id']?.toString() ?? '';

      print(
        'NotificationService: payload navigation tujuan=$tujuan id=$id userId=$userId',
      );

      switch (tujuan) {
        case 'pengumuman_list':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        case 'acara_list':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        case 'evaluasi_list':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        case 'dashboard':
          print('Navigating to Splash Screen First');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => SplashScreen(
                    fromNotification: true,
                    tujuan: tujuan,
                    id: id,
                  ),
            ),
          );
          break;
        // Tambahkan case lain sesuai kebutuhan
        default:
          // Default action jika screen tidak dikenali
          print('Navigating to Splash Screen');
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
          break;
      }
    } catch (e) {
      print('NotificationService._handlePayloadNavigation error: $e');
    }
  }
}
