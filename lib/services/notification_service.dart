import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void fetchNotifications() async {
  const String apiUrl = "https://building.abyssiniasoftware.com/api.php";

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Map<String, dynamic>> notifications = data.map((item) {
        return {
          'id': item['id'],
          'title': item['title'],
          'body': item['body'],
          'isRead': false, // Initially all notifications are unread
        };
      }).toList();

      // Save notifications to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('notifications', jsonEncode(notifications));
    } else {
      print("Error fetching notifications: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    if (task == 'fetchNotifications') {
      fetchNotifications();
    }
    return Future.value(true);
  });
}

void setupWorkManager() {
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'fetchNotifications',
    'fetchNotifications',
    frequency: const Duration(minutes: 15),
  );
}
