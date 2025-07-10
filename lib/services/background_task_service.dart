// import 'package:workmanager/workmanager.dart';
// import 'package:syc/services/notification_service.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     print("Background task started: $task");

//     try {
//       switch (task) {
//         case 'pengumumanSyncTask':
//           await NotificationService.checkLatestPengumuman();
//           print("Background task completed: pengumuman sync");
//           break;
//         default:
//           print("Unknown background task: $task");
//       }

//       return Future.value(true);
//     } catch (e) {
//       print("Background task error: $e");
//       return Future.value(false);
//     }
//   });
// }

// class BackgroundTaskService {
//   static const String taskName = 'pengumumanSyncTask';
//   static const String uniqueName = 'pengumumanSync';

//   static Future<void> initialize() async {
//     await Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: true, // Set false untuk production
//     );
//   }

//   static Future<void> registerPeriodicTask() async {
//     await Workmanager().registerPeriodicTask(
//       uniqueName,
//       taskName,
//       frequency: Duration(
//         minutes: 15,
//       ), // Minimum yang diizinkan adalah 15 menit
//       constraints: Constraints(
//         networkType: NetworkType.connected,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresDeviceIdle: false,
//         requiresStorageNotLow: false,
//       ),
//     );
//     print("Periodic background task registered");
//   }

//   static Future<void> cancelAllTasks() async {
//     await Workmanager().cancelAll();
//     print("All background tasks cancelled");
//   }
// }
