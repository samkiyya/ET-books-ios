import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Update User Profile
  Future<void> updateProfile({
    required String token,
    required String fname,
    required String lname,
    required String phone,
    required String bio,
    required String city,
    required String country,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('${Network.baseUrl}/api/manage-user/update-my-account');
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: json.encode({
        'fname': fname,
        'lname': lname,
        'phone': phone,
        'bio': bio,
        'city': city,
        'country': country,
      }),
    );

    if (response.statusCode == 200) {
      // Handle success response, you can parse any success data here if needed.
      _isLoading = false;
      notifyListeners();
    } else {
      // Handle error response
      _errorMessage = 'Failed to update profile: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete User Account
  Future<void> deleteAccount({required String token}) async {
    _isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('${Network.baseUrl}/api/manage-user/delete-my-account');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      // Handle success response (Account deleted)
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'Failed to delete account: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
