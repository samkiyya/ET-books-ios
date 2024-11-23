import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const String _baseUrl = Network.baseUrl;
  String? _token;
  final bool _is2FARequired = false;
  UserData? _userData;
  String? _userId;
  bool _isLoggingOut = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get is2FARequired => _is2FARequired;
  UserData? get userData => _userData;
  String? get userId => _userId;

  Future<void> setUserId(String userId) async {
    _userId = userId;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final googleSignInAccount = googleUser as GoogleSignInAccount;
        final googleAuth = await googleUser.authentication;

        final response = await http.post(
          Uri.parse('$_baseUrl/api/auth/google/callback'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'id_token': googleAuth.idToken!,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await _storeToken(data['userToken']);
          await loadUserData();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!;
        final response = await http.post(
          Uri.parse('$_baseUrl/api/auth/facebook/callback'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'access_token': accessToken.token!,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await _storeToken(data['userToken']);
          await loadUserData();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _storeToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
    notifyListeners();
  }

  Future<String> _handleCallback(String callbackUrl) async {
    final response = await http.get(Uri.parse(callbackUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['userToken'];
    } else {
      throw Exception('Callback failed');
    }
  }

  Future<void> loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    notifyListeners();
  }

  /// Load token and user data from shared preferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');

    if (isAuthenticated) {
      String? userDataJson = prefs.getString('userId');
      if (userDataJson != null) {
        _userData = UserData.fromJson(jsonDecode(userDataJson));
      }
    }

    notifyListeners();
  }

  /// Remove token and user data from shared preferences
  Future<void> _removeUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userId');

    _token = null;
    _userData = null;
    notifyListeners();
  }

  /// Log out the user
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    _token = null;
    try {
      // Logout the user from the server
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      var url = Uri.parse('$_baseUrl/api/user/logout');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        await _removeUserData();
      } else {
        var errorMessage =
            json.decode(response.body)['message'] ?? 'Logout failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception("Logout failed: $e");
    } finally {
      _isLoggingOut = false;
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
  Future<void> sendVerificationEmail(String email) async {
    try {
      var url = Uri.parse('$_baseUrl/api/user/sendme-verification-email');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message'] ??
            'Failed to send verification email');
      }
    } catch (e) {
      throw Exception("Failed to send verification email: $e");
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

  Future<void> verify2FA(String verificationCode, int userId) async {
    try {
      var url = Uri.parse('$_baseUrl/api/user/verify/2fa');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "verificationCode": verificationCode,
          "userId": userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            json.decode(response.body)['message'] ?? '2FA verification failed');
      }
    } catch (e) {
      throw Exception("2FA verification failed: $e");
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
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

  Future<void> reserPassword(String email) async {
    try {
      var url = Uri.parse('$_baseUrl/api/user/reset-password');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message'] ??
            'Failed to reset password');
      }
    } catch (e) {
      throw Exception("Failed to reset password: $e");
    }
  }
}

extension on AccessToken {
  get token => null;
}
