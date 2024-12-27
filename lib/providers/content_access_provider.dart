import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccessProvider with ChangeNotifier {
  final String apiUrl = "${Network.baseUrl}/api/asset-usage/user-usage";

  // State variables
  bool? _hasReachedLimitAndApproved;
  String? _errorMessage;

  bool? get hasReachedLimitAndApproved => _hasReachedLimitAndApproved;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSubscriptionStatus(String userId) async {
    final url = Uri.parse("$apiUrl/$userId");
    try {
      final response = await http.get(url);
      print("content access Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("AccessProvider data: $data");

        if (data["success"] == true) {
          // Process the subscriptions
          final subscriptions = data["subscriptions"] as List<dynamic>;
          _hasReachedLimitAndApproved = subscriptions.any((sub) =>
              sub["hasReachedLimit"] == false &&
              sub["approvalStatus"].toString().toUpperCase() == "APPROVED");
          print(
              "AccessProvider hasReachedLimitAndApproved: $_hasReachedLimitAndApproved");
        } else {
          _errorMessage = "API responded with success = false";
          _hasReachedLimitAndApproved = false;
        }
      } else {
        _errorMessage = "Failed to fetch data: ${response.statusCode}";
        _hasReachedLimitAndApproved = false;
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
      _hasReachedLimitAndApproved = false;
    }

    // Notify listeners
    notifyListeners();
  }
}
