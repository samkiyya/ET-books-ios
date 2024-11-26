import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationProvider with ChangeNotifier {
  final String apiUrl = 'https://building.abyssiniasoftware.com/api.php';
  List<Map<String, dynamic>> _notifications = [];
  bool _notificationsEnabled = true; // Default to notifications enabled

  // Getter for notifications list
  List<Map<String, dynamic>> get notifications => _notifications;

  // Getter for notifications enabled/disabled status
  bool get notificationsEnabled => _notificationsEnabled;

  // Fetch notifications from the API
  Future<void> loadNotifications() async {
    if (!_notificationsEnabled)
      return; // Skip fetching if notifications are disabled

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['notifications'] != null) {
          _notifications =
              List<Map<String, dynamic>>.from(data['notifications']);
          notifyListeners();
        }
      } else {
        print('Failed to load notifications: ${response.body}');
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    try {
      _notifications.removeWhere((notification) => notification['id'] == id);
      notifyListeners();
      // Implement API call to delete notification on the server if required
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Toggle read/unread status
  void toggleReadStatus(int index) {
    try {
      _notifications[index]['isRead'] = !_notifications[index]['isRead'];
      notifyListeners();
      // Optionally sync this update with the server
    } catch (e) {
      print('Error toggling read status: $e');
    }
  }

  // Toggle notifications on/off
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    if (_notificationsEnabled) {
      loadNotifications(); // Reload notifications when re-enabled
    } else {
      _notifications.clear(); // Clear notifications when disabled
      notifyListeners();
    }
  }
}
