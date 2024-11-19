import 'dart:convert';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:book_mobile/models/login_model.dart';
import 'package:book_mobile/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginProvider with ChangeNotifier {
  final AuthProvider authProvider;

  LoginProvider({required this.authProvider});
  bool _isLoading = false;
  String _errorMessage = '';
  String? _token;
  bool _isAuthenticated = false;
  bool _is2FARequired = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get token => _token;
  bool get is2FARequired => _is2FARequired;
  bool get isAuthenticated => _isAuthenticated;
  bool _isTokenExpired = false;
  bool get isTokenExpired => _isTokenExpired;

  Future<void> initializeLoginStatus() async {
    await checkLoginStatus();
  }

  // Load 2FA status directly from SharedPreferences
  Future<void> load2FAStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _is2FARequired = prefs.getBool('is2FARequired') ?? false;
    notifyListeners();
  }

  // Check if user is logged in when the app starts
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    if (_token != null) {
      final isValid = await _isTokenValid(_token!);

      _isAuthenticated = isValid;
      _isTokenExpired = tokenExpirationCheck(token);

      if (!isValid) {
        _token = null;
        prefs.remove('userToken');
      }
    } else {
      _isAuthenticated = false;
    }
    await load2FAStatus();
    notifyListeners();
  }

  // Validate token
  Future<bool> _isTokenValid(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Network.baseUrl}/api/user/verify'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Login function
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final url = Uri.parse('${Network.baseUrl}/api/user/login');
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({"email": email, "password": password});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final loginResponse =
            LoginResponse.fromJson(json.decode(response.body));
        _token = loginResponse.userToken;
        _isAuthenticated = true;
        await _saveTokenToLocalStorage(_token!);
        final userId = loginResponse.userData.id;

        await authProvider.setUserId(userId.toString());
      } else {
        _errorMessage = 'Invalid email or password. Please try again.';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save token to local storage
  Future<void> _saveTokenToLocalStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
    await prefs.setString('userId', authProvider.userId!);
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  bool tokenExpirationCheck(String? token) {
    if (token == null) {
      return true;
    }
    final parts = token.split('.');
    if (parts.length != 3) {
      return true;
    }
    final payload = parts[1];
    final decoded = json
        .decode(utf8.decode(base64Url.decode(base64Url.normalize(payload))));
    final exp = decoded['exp'] * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now > exp;
  }
}
