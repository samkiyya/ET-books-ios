import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userProfile;
  final baseUrl = Network.baseUrl;

  Map<String, dynamic>? get userProfile => _userProfile;

  // Set token for authorization
  void setToken(String token) {
    _token = token;
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
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
    }
  }
}
