import 'dart:async';
import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityProvider extends ChangeNotifier {
  int pagesRead = 0;
  int totalTimeSpent = 0;
  bool isIdle = false;
  Timer? _timer;
  Timer? _idleTimer;

  void startTracking(int bookId) {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      totalTimeSpent += 1; // Increment by 1 minute
      notifyListeners();

      if (totalTimeSpent % 5 == 0) { // Send every 5 minutes
        _sendReadingActivity(bookId);
      }
    });

    _idleTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int lastInteractionTime = prefs.getInt('last_interaction') ?? DateTime.now().millisecondsSinceEpoch;
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - lastInteractionTime > 300000) { // 5 minutes
        isIdle = true;
      } else {
        isIdle = false;
      }

      await prefs.setInt('last_interaction', currentTime);
      notifyListeners();
    });
  }

  Future<void> _sendReadingActivity(int bookId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = '${Network.baseUrl}/api/asset-usage';

    final data = {
      "userId": userId,
      "bookId": bookId,
      "pagesRead": pagesRead,
      "totalTimeSpent": totalTimeSpent,
      "isIdle": isIdle,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // print("User activity sent successfully.");
      } else {
        // print("Failed to send user activity: ${response.statusCode}");
      }
    } catch (error) {
      // print("Error sending activity: $error");
    }
  }

  void incrementPagesRead() {
    pagesRead += 1;
    notifyListeners();
  }

  void stopTracking(int bookId) {
    if (totalTimeSpent > 0) {
      _sendReadingActivity(bookId);
    }
    _timer?.cancel();
    _idleTimer?.cancel();
    notifyListeners();
  }
}