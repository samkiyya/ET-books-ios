import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userProfile;
  final baseUrl = Network.baseUrl;

  Map<String, dynamic>? get userProfile => _userProfile;

  // Set token for authorization
  void setToken(String token) {
    _token = token;
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token != null) {
      setToken(token); // Set in the provider
      print('Token loaded: $token'); // Debugging
    } else {
      print('No token found');
    }
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    if (_token == null) {
      print('No token available.');
      return;
    }
    final url = Uri.parse('$baseUrl/api/user/my-profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        _userProfile = data['user'];
        notifyListeners();
      }
    } else {
      // Handle error (you can use Snackbar, Dialog, etc.)
      print('Error fetching profile: ${response.statusCode}');
    }
  }
}
