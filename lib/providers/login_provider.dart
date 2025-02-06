import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:book_mobile/models/login_model.dart';
import 'package:book_mobile/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginProvider with ChangeNotifier {
  final AuthProvider authProvider;
  LoginProvider({required this.authProvider});

  // States for login process
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _is2FARequired = false;
  bool _isEmailVerificationRequired = false;
  bool _isAccountDeactivated = false;
  bool _isTokenExpired = false;

  String _errorMessage = '';
  String _successMessage = '';
  String? _token;
  int? _userId;
  String? _email;

  // Getter methods
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get is2FARequired => _is2FARequired;
  bool get isEmailVerificationRequired => _isEmailVerificationRequired;
  bool get isAccountDeactivated => _isAccountDeactivated;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String? get token => _token;
  bool get isTokenExpired => _isTokenExpired;
  int? get userId => _userId;
  String? get email => _email;

  // Initialize login status
  Future<void> initializeLoginStatus() async {
    await checkLoginStatus();
  }

  // Load 2FA status from SharedPreferences
  Future<void> load2FAStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _is2FARequired = prefs.getBool('is2FARequired') ?? false;
    notifyListeners();
  }

  // Check login status from SharedPreferences
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');

    if (_token != null) {
      final isValid = await _isTokenValid(_token!);
      _isAuthenticated = isValid;
      _isTokenExpired = tokenExpirationCheck(_token);

      if (_isAuthenticated) {
        _successMessage = 'You have logged in successfully!';
      } else {
        _token = null;
        prefs.remove('userToken');
      }
    } else {
      _isAuthenticated = false;
    }
    await load2FAStatus();
    notifyListeners();
  }

  // Validate the token
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

  // Handle login process
  Future<void> login(String email, String password, String? deviceInfo) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final url = Uri.parse('${Network.baseUrl}/api/user/login');
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({
        "email": email,
        "password": password,
        "deviceInfo": deviceInfo,
      });

      final response = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(response.body);
      _email = email;
      if (response.statusCode == 200) {
        // Handling various response cases
        if (data['showTwoFactor'] == true) {
          _is2FARequired = true;
          _userId = data['user_id'];
          _errorMessage = 'two factor is enabled';
        } else if (data['isVerified'] == false) {
          _isEmailVerificationRequired = true;
          _userId = data['user_id'];
          _email = data['email'];
          _errorMessage = 'email is not verified';
          // print('user verfication status: $_isEmailVerificationRequired');
        } else if (data['isActive'] == false) {
          _isAccountDeactivated = true;
          _userId = data['user_id'];
          _errorMessage = 'account is deactivated';
          // print('user activation status: $_isAccountDeactivated');
        } else if (data.containsKey('userToken')) {
          final loginResponse = LoginResponse.fromJson(data);
          _token = loginResponse.userToken;
          _isAuthenticated = true;

          await _saveTokenToLocalStorage(_token!);
          await _saveUserIdToLocalStorage(loginResponse.userData.id.toString());

          _successMessage = 'You have logged in successfully!';
          // print('user logged in successfully!');
        }
      } else {
        _handleError(response, data);
        // print('error ${response.statusCode}, data: $data ');
      }
    } catch (error) {
      _handleError(null, null, error);
      // print('error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle different error scenarios
  void _handleError(http.Response? response, Map<String, dynamic>? data,
      [dynamic error]) {
    if (response != null && response.statusCode == 401) {
      _errorMessage = data?['message']??'Authorization failed. Please try again.';
    } else if (response != null && response.statusCode == 403) {
      if (data?['message']?.contains('isVerified') == true) {
        _errorMessage = 'Please verify your email before logging in';
      } else {
        _errorMessage = data?['message']??'Invalid credentials. Please try again.';
      }
    } else {
      _errorMessage = _mapErrorToMessage(error??data?['message']);
    }
    _isAuthenticated = false;
    notifyListeners();
  }

  // Map general errors to user-friendly messages
  String _mapErrorToMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out. Please try again later.';
    } else if (error is SocketException) {
      return 'No internet connection, please enable your internet connection.';
    } else if (error is FormatException) {
      return 'Invalid response from server. Please try again later.';
    } else if (error is http.ClientException) {
      return 'Failed to connect to the server.';
    } else if (error is HttpException) {
      return 'Failed to send request. Please try again later.';
    } else {
      return 'An error occurred: $error';
    }
  }

  // Save token to local storage
  Future<void> _saveTokenToLocalStorage(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
  }

  // Save user ID to local storage
  Future<void> _saveUserIdToLocalStorage(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  /// Verifies the 2FA code
  Future<void> verify2FA({
    required String verificationCode,
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Network.baseUrl}/api/user/verify/2fa'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "verificationCode": verificationCode,
          "user_id": userId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(data);
        _token = loginResponse.userToken;
        _isAuthenticated = true;
        // print('Token: $_token');

        await _saveTokenToLocalStorage(_token!);
        await _saveUserIdToLocalStorage(loginResponse.userData.id.toString());

        _successMessage = 'You have logged in successfully!';
        // print('user logged in successfully!');
      }
    } catch (e) {
      // print('Error: $e');
      _errorMessage = 'An error occurred while verifying 2FA code: $e';
      _isAuthenticated = false;
    } finally {
      notifyListeners();
    }
  }

  /// Resends the 2FA OTP code
  Future<Map<String, dynamic>> resend2FA(String email) async {
    if (_email == null || _email!.isEmpty) {
      _errorMessage = 'Email is required to resend 2FA code';
      return {
        "success": false,
        "message": _errorMessage,
      };
    }
    try {
      final response = await http.post(
        Uri.parse('${Network.baseUrl}/api/user/send2fa'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": _email ?? email,
        }),
      );

      if (response.statusCode == 200) {
        // print(response.body);
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Failed to resend 2FA code: ${response.body}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // Check token expiration
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

  // Clear messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}
