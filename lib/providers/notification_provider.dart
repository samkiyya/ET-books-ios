import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  final String fetchUrl = '${Network.baseUrl}/api/notification/my';
  final String deleteUrl = '${Network.baseUrl}/api/notification/delete';
  final String toggleReadUrl =
      '${Network.baseUrl}/api/notification/toggle-read';

  List<Map<String, dynamic>> _notifications = [];
  bool _notificationsEnabled = true; // Default to notifications enabled

  // Getter for notifications list
  List<Map<String, dynamic>> get notifications => _notifications;

  // Getter for notifications enabled/disabled status
  bool get notificationsEnabled => _notificationsEnabled;

  // Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fetch notifications from the API
  Future<void> loadNotifications() async {
    if (!_notificationsEnabled)
      return; // Skip fetching if notifications are disabled

    try {
      final token = await _getToken();
      if (token == null) {
        print('No token found. Cannot fetch notifications.');
        return;
      }

      final response = await http.get(
        Uri.parse(fetchUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

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
      final token = await _getToken();
      if (token == null) {
        print('No token found. Cannot delete notification.');
        return;
      }

      final response = await http.delete(
        Uri.parse('$deleteUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _notifications.removeWhere((notification) => notification['id'] == id);
        notifyListeners();
      } else {
        print('Failed to delete notification: ${response.body}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Toggle read/unread status of a notification
  Future<void> toggleReadStatus(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No token found. Cannot toggle read status.');
        return;
      }

      final response = await http.put(
        Uri.parse('$toggleReadUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final index = _notifications
            .indexWhere((notification) => notification['id'] == id);
        if (index != -1) {
          _notifications[index]['isRead'] = !_notifications[index]['isRead'];
          notifyListeners();
        }
      } else {
        print('Failed to toggle read status: ${response.body}');
      }
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
