import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  static final NotificationProvider _instance =
      NotificationProvider._internal();
  factory NotificationProvider() => _instance;
  NotificationProvider._internal() {
    _loadNotificationPreferences();
  }

  final String fetchUrl = '${Network.baseUrl}/api/notification/my';
  final String deleteUrl = '${Network.baseUrl}/api/notification/delete';
  final String toggleReadUrl =
      '${Network.baseUrl}/api/notification/mark-as-read';

  List<Map<String, dynamic>> _notifications = [];
  bool _notificationsEnabled = true;

  List<Map<String, dynamic>> get notifications => _notifications;

  // Getter for notifications enabled/disabled status
  bool get notificationsEnabled => _notificationsEnabled;

  // NotificationProvider() {
  //   _loadNotificationPreferences();
  // }

  // Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  // Load notification preferences from SharedPreferences
  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    if (_notificationsEnabled) {
      await loadNotifications();
    }
    notifyListeners();
  }

  // Save notification preferences to SharedPreferences
  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  // Fetch notifications from the API
  Future<void> loadNotifications() async {
    if (!_notificationsEnabled) {
      return;
    } // Skip fetching if notifications are disabled

    try {
      final token = await _getToken();
      // print('Notification Token: $token');
      if (token == null) {
        // print('No token found. Cannot fetch notifications.');
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

        // Correctly parse the API response
        if (data['status'] == 'success' &&
            data['data'] != null &&
            data['data']['items'] != null) {
          _notifications =
              List<Map<String, dynamic>>.from(data['data']['items']);
          notifyListeners();
        } else {
          // print('Unexpected API response format: ${response.body}');
        }
      } else {
        // print(
        //     'Failed to load notifications: ${response.body}, ${response.statusCode}');
      }
    } catch (e) {
      throw e;
      // print('Error loading notifications: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        // print('No token found. Cannot delete notification.');
        return;
      }

      // print('token to delete notification is: $token');
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
        // print('Failed to delete notification response: ${response.body} ${response.statusCode}');
      }
    } catch (e) {
      // print('Error deleting notification: $e');
    }
  }

  // Toggle read/unread status of a notification
  Future<void> toggleReadStatus(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        // print('No token found. Cannot toggle read status.');
        return;
      }

      final response = await http.put(
        Uri.parse('$toggleReadUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('response to mark as read: ${response.body}');
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
    _saveNotificationPreferences();
    notifyListeners();
    if (_notificationsEnabled) {
      loadNotifications();
    } else {
      _notifications.clear();
      notifyListeners();
    }
  }
}
