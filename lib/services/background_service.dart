import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/providers/login_provider.dart';
import 'package:book_mobile/screens/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

const String taskName = "backgroundTask";
const String apiUrl = '${Network.baseUrl}/api/notification/my';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      final notificationsEnabled =
          prefs.getBool('notificationsEnabled') ?? true;

      if (!_isValidToken(token) || !notificationsEnabled) {
        return Future.value(false);
      }

      final unreadNotifications = await _fetchUnreadNotifications(token!);
      if (unreadNotifications.isNotEmpty) {
        for (var notification in unreadNotifications) {
          await _showLocalNotification(notification);
        }
      }
    } catch (e) {
      print('Error during background task execution: $e');
    }
    return Future.value(true);
  });
}

/// Validate token
bool _isValidToken(String? token) => token != null && token.isNotEmpty;

/// Fetch unread notifications
Future<List<dynamic>> _fetchUnreadNotifications(String token) async {
  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data']['items'] as List)
            .where((item) => !item['isRead'])
            .toList();
      }
    } else {
      print('Failed to fetch notifications: ${response.body}');
    }
  } catch (e) {
    print('Error fetching notifications: $e');
  }
  return [];
}

/// Show local notification
@pragma('vm:entry-point')
Future<void> _showLocalNotification(Map<String, dynamic> notification) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flip.show(
    notification['id'],
    notification['title'],
    notification['body'],
    notificationDetails,
    payload: jsonEncode(notification),
  );
}

@pragma('vm:entry-point')
Future<void> initializeBackgroundService(LoginProvider loginProvider) async {
  await _initializeWorkManager();
  await _initializeNotifications(loginProvider);
  await _createNotificationChannel();
}

/// Initialize WorkManager
@pragma('vm:entry-point')
Future<void> _initializeWorkManager() async {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
}

/// Initialize Notifications
@pragma('vm:entry-point')
Future<void> _initializeNotifications(LoginProvider loginProvider) async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flip.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) async {
      await _handleNotificationResponse(response, loginProvider);
    },
  );
}

/// Handle notification response
@pragma('vm:entry-point')
Future<void> _handleNotificationResponse(
  NotificationResponse response,
  LoginProvider loginProvider,
) async {
  final payload = response.payload;
  await loginProvider.initializeLoginStatus();

  if (loginProvider.isAuthenticated && payload != null) {
    final data = jsonDecode(payload);
    final notificationId = data['id'];

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) =>
            NotificationDetailScreen(notificationId: notificationId),
      ),
    );
  } else {
    navigatorKey.currentState?.pushNamed('/login');
  }
}

/// Create notification channel
@pragma('vm:entry-point')
Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flip
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

/// Schedule background tasks
@pragma('vm:entry-point')
void scheduleBackgroundTask() {
  Workmanager().registerPeriodicTask(
    taskName,
    taskName,
    initialDelay: const Duration(seconds: 5),
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
      requiresCharging: false,
      requiresStorageNotLow: true,
    ),
    backoffPolicy: BackoffPolicy.linear,
  );
}
