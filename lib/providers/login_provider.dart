// providers/login_provider.dart
import 'dart:convert';
import 'package:book/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool isLoggedIn = false;
  String _errorMessage = '';
  String? _token;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get token => _token;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    const url = 'https://bookbackend3.bruktiethiotour.com/api/user/login';
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({"email": email, "password": password});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);
        isLoggedIn = true;
        print("Response body: $loginResponse");
        _token = loginResponse.userToken;
        _saveTokenToLocalStorage(_token!);
        print(_token);
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Invalid credentials. Please try again.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTokenToLocalStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
  }
}
