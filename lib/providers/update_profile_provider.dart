import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String? _token = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get token => _token!;

  // Update User Profile
  Future<void> updateProfile({
    required String fname,
    required String lname,
    required String phone,
    required String bio,
    required String city,
    required String country,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _token = '';
    notifyListeners();

    final url =
        Uri.parse('${Network.baseUrl}/api/manage-user/update-my-account');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'fname': fname,
        'lname': lname,
        'phone': phone,
        'bio': bio,
        'city': city,
        'country': country,
      }),
    );
    print('The token of profile update is: $_token');
    print('response body is: ${response.body}');
    print('response status code is: ${response.statusCode}');
    final responseData = jsonDecode(response.body);
    print('response data is: $responseData');
    if (response.statusCode == 200) {
      // Handle success response, you can parse any success data here if needed.
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 400) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Bad Request: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 401) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Unauthorized: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 403) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Forbiden you are Unauthorized: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 404) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'User Not Found: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 500) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Internal Server Error: ${response.statusCode}';
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
  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = '';
    _token = '';
    notifyListeners();

    final url =
        Uri.parse('${Network.baseUrl}/api/manage-user/delete-my-account');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 204) {
      // Handle success response (Account deleted)
      _isLoading = false;
      prefs.remove('userToken');
      prefs.clear();
      notifyListeners();
    } else if (response.statusCode == 401) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Unauthorized: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 403) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Forbiden you are Unauthorized: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 404) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'User Not Found: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 500) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Internal Server Error: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'Failed to delete account: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
