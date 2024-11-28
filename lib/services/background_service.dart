import 'dart:convert';
import 'package:book_mobile/providers/login_provider.dart';
import 'package:book_mobile/screens/demo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

const String taskName = "backgroundTask";
const String apiUrl = 'https://building.abyssiniasoftware.com/api.php';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true) {
          // Show notification
          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          );

          const DarwinNotificationDetails iosDetails =
              DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true, // sound: 'default',
          );

          const NotificationDetails androidNotificationDetails =
              NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );
          final payload = jsonEncode(data);
          if (payload.length > 4000) {
            print('Payload too large, truncating...');
            // Handle payload size limitation
          }
          flip.show(
            0, // Notification ID
            'New Notification', // Title
            'You have a new notification.', // Body
            androidNotificationDetails,
            payload: payload, // Pass API data as payload
          );
        }
        print('Fetched API data: $data');
      }
    } catch (e) {
      print('Error fetching API data: $e');
    }
    return Future.value(true);
  });
}

Future<void> initializeBackgroundService(LoginProvider loginProvider) async {
  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // Initialize Flutter Local Notifications
  const AndroidInitializationSettings androids =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosDetails = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
  );

  const InitializationSettings initializeNotificationSetting =
      InitializationSettings(
    android: androids,
    iOS: iosDetails,
  );

  await flip.initialize(
    initializeNotificationSetting,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      await loginProvider.checkLoginStatus();

      if (loginProvider.isAuthenticated && payload != null) {
        // Parse payload data
        final Map<String, dynamic> data = jsonDecode(payload);
        print('Notification Payload: $data');
        // Handle notification data as needed
        // Perform actions based on notification data
        // Example: Show a snackbar or navigate to a specific screen
        // Use named routing to navigate to a specific screen
        if (data['status'] == true) {
          final tenant = Tenant.fromJson(data);
          // Use navigatorKey to navigate when the app is in the background
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (context) => TenantDetailScreen(
                      tenant: tenant,
                    ) // Navigate to tenant detail screen
                ),
          );
          // Navigate to notification details
          print('Navigate to Notification Details Screen');
        } else {
          // Check login status and navigate accordingly
          // Example: Show a login prompt or navigate to a login screen
          // Example: Show a snackbar or navigate to a login screen
          navigatorKey.currentState?.pushNamed('/login');
          // Navigate to login
          print('Navigate to Login Screen');
        }
      }
    },
  );
  await createNotificationChannel();
}

Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  await flip
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void scheduleBackgroundTask() {
  Workmanager().registerPeriodicTask(
    taskName,
    taskName,
    inputData: <String, dynamic>{},
    initialDelay: const Duration(seconds: 5),
    frequency: const Duration(
      minutes: 15,
    ),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
      requiresCharging: false,
      requiresStorageNotLow: true,
    ),
    backoffPolicy: BackoffPolicy.linear,
  );
}
