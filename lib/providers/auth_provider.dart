import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/models/login_model.dart';
import 'package:book_mobile/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthProvider with ChangeNotifier {
  final StorageService storageService;

  static const String _baseUrl = Network.baseUrl;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isLoggingOut = false;

  String? _token;
  UserData? _userData;
  String? _error;

  /// Public getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  UserData? get userData => _userData;
  String? get error => _error;

  AuthProvider({required this.storageService});

  /// Helper to update authentication state
  void _updateAuthState({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    UserData? userData,
    String? error,
  }) {
    if (isAuthenticated != null) _isAuthenticated = isAuthenticated;
    if (isLoading != null) _isLoading = isLoading;
    if (token != null) _token = token;
    if (userData != null) _userData = userData;
    if (error != null) _error = error;
    notifyListeners();
  }

  /// Load token and user data from storage
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      _userData = UserData.fromJson(jsonDecode(userDataString));
    }
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  /// Save token and user data to storage
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> data) async {
    _token = data['userToken'];
    _userData = UserData.fromJson(data['userData']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', _token!);
    await prefs.setString('userData', jsonEncode(data['userData']));
    _updateAuthState(isAuthenticated: true);
  }

  /// Remove token and user data from storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userData');
    _updateAuthState(isAuthenticated: false, token: null, userData: null);
  }

  /// Login with email and password
  Future<void> loginWithEmail(String email, String password) async {
    _updateAuthState(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/user/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleSuccessfulLogin(data);
      } else {
        throw Exception(
          jsonDecode(response.body)['message'] ?? "Login failed",
        );
      }
    } catch (e) {
      _updateAuthState(error: "Login failed: $e");
    } finally {
      _updateAuthState(isLoading: false);
    }
  }

  /// Logout the user
  Future<void> logout() async {
    _updateAuthState(
      isLoading: true,
    );
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      if (_token == null) {
        throw Exception("No token found");
      }
      final response = await http.post(
        Uri.parse("$_baseUrl/api/user/logout"),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        await _clearUserData();
      } else {
        throw Exception("Logout failed");
      }
    } catch (e) {
      throw Exception("Logout error: $e");
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    try {
      final Uri loginUrl = Uri.parse("$_baseUrl/api/auth/google");
      if (await canLaunchUrl(loginUrl)) {
        await launchUrl(loginUrl, mode: LaunchMode.externalApplication);
        await _fetchGoogleCallbackResponse();
      } else {
        throw Exception("Could not launch Google login");
      }
    } catch (e) {
      throw Exception("Google login error: $e");
    }
  }

  Future<void> _fetchGoogleCallbackResponse() async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/api/auth/google/callback"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleSuccessfulLogin(data);
      } else {
        throw Exception("Google callback failed");
      }
    } catch (e) {
      throw Exception("Fetching Google callback response failed: $e");
    }
  }

  /// Login with Facebook
  Future<void> loginWithFacebook() async {
    try {
      final Uri loginUrl = Uri.parse("$_baseUrl/api/auth/facebook");
      if (await canLaunchUrl(loginUrl)) {
        await launchUrl(loginUrl, mode: LaunchMode.externalApplication);
        await _fetchFacebookCallbackResponse();
      } else {
        throw Exception("Could not launch Facebook login");
      }
    } catch (e) {
      throw Exception("Facebook login error: $e");
    }
  }

  Future<void> _fetchFacebookCallbackResponse() async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/api/auth/facebook/callback"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleSuccessfulLogin(data);
      } else {
        throw Exception("Facebook callback failed");
      }
    } catch (e) {
      throw Exception("Fetching Facebook callback response failed: $e");
    }
  }

  /// Handle password reset
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/auth/forgot-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to reset password");
      }
    } catch (e) {
      throw Exception("Forgot password error: $e");
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/auth/reset-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to reset password");
      }
    } catch (e) {
      throw Exception("Reset password error: $e");
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    try {
      var url = Uri.parse('$_baseUrl/api/user/change-password');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message'] ??
            'Failed to change password');
      }
    } catch (e) {
      throw Exception("Failed to change password: $e");
    }
  }

  /// Verify account using a token
  Future<void> verifyAccount(String token) async {
    try {
      var url = Uri.parse('$_baseUrl/api/user/verify/account/$token');
      var response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Verification failed');
      }
    } catch (e) {
      throw Exception("Verification failed: $e");
    }
  }

  /// Send a verification email
  Future<bool> sendVerificationEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      var url = Uri.parse('$_baseUrl/api/user/sendme-verification-email');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _error = null;
        return true;
      } else if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message'] ??
            'Failed to send verification email');
      } else {
        _error = data['message'] ?? 'Failed to resend verification email';
        return false;
      }
    } catch (e) {
      _error = 'Network error occurred';
      return false;
      // throw Exception("Failed to send verification email: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle2FA() async {
    try {
      var url = Uri.parse('$_baseUrl/api/user/toggle/2fa');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Failed to toggle 2FA');
      }
    } catch (e) {
      throw Exception("Failed to toggle 2FA: $e");
    }
  }

  Future<bool> verify2FA(String verificationCode) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      var url = Uri.parse('$_baseUrl/api/user/verify/2fa');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "verificationCode": verificationCode,
          "userId": _userData?.id,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _handleSuccessfulLogin(data);
        // _is2FARequired = false;
        return true;
      }
      if (response.statusCode != 200) {
        throw Exception(
            json.decode(response.body)['message'] ?? '2FA verification failed');
      } else {
        _error = data['message'] ?? 'Two-factor verification failed';
        return false;
      }
    } catch (e) {
      throw Exception("2FA verification failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
