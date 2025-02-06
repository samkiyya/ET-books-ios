import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:http/http.dart' as http;

class UserActivityTracker {
  final String apiUrl =
      '${Network.baseUrl}/api/user-activity'; // Replace with your API URL

  Future<void> trackUserActivity({
    required int userId,
    required String actionType,
    required Map<String, dynamic> actionDetails,
  }) async {
    final Map<String, dynamic> data = {
      "userId": userId,
      "actionType": actionType,
      "actionDetails": actionDetails,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization headers if needed
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // print("User activity sent successfully.");
      } else {
        // print("Failed to send user activity: ${response.statusCode}");
      }
    } catch (e) {
      // print("Error sending user activity: $e");
    }
  }
}
