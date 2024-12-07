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
  AccessToken? _accessToken;
  bool _isLoading = false;
  UserData? _userData;
  String? _userId;
  String? _error;
  bool _isLoggingOut = false;
  Map<String, dynamic>? _fbUserData;

  UserData? get userData => _userData;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get is2FARequired => _is2FARequired;
  String? get userId => _userId;
  bool get isAuthenticated => _token != null;

  Map<String, dynamic>? get fbUserData => _fbUserData;

  Future<void> setUserId(String userId) async {
    _userId = userId;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        //client id is required for web
        // clientId:
        //     '7696739887-377654pcvnpco15a1cv9etv4a6l8og13.apps.googleusercontent.com',
        scopes: <String>[
          'email',
          'profile',
        ],
      );

      // Sign out first to make sure we don't have any cached credentials
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('Google User: ${googleUser.toString()}');
      if (googleUser == null) {
        print('Google Sign-In was canceled.');
        return;
      }
// Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token');
      }

      if (googleAuth.idToken != null) {
        print('google Access Token: ${googleAuth.accessToken}');
        print('Google ID Token: ${googleAuth.idToken}');
// Make the server call
        final response = await http.post(
          Uri.parse('$_baseUrl/api/auth/google/callback'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'id_token': googleAuth.idToken!.toString(),
            'email': googleUser.email,
            'displayName': googleUser.displayName,
          }),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('the Data response is: $data');
          print('User Token: ${data['userToken']}');
          print('Data from callback is: $data');
          await _storeToken(data['userToken']);
          await loadUserData();
        } else {
          print('Failed to authenticate with server: ${response.body}');
        }
      } else {
        throw Exception('Google ID Token is null');
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  String prettyPrint(Map json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  void _printCredentials() {
    print(
      prettyPrint(_accessToken!.toJson()),
    );
  }

  Future<void> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        _accessToken = result.accessToken!;
        _printCredentials();

        final userData = await FacebookAuth.instance.getUserData();
        _fbUserData = userData;
        notifyListeners();

        if (_accessToken != null) {
          final response = await http.post(
            Uri.parse('$_baseUrl/api/auth/facebook/callback'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'access_token': _accessToken,
            }),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            await _storeToken(data['userToken']);
            await loadUserData();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fbLogOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _fbUserData = null;
    notifyListeners();
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
      _token = null;
      _userData = null;
      // _is2FARequired = false;
      _userId = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _isLoggingOut = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userDataString = prefs.getString('userData');

    if (token != null && userDataString != null) {
      _token = token;
      _userData = UserData.fromJson(jsonDecode(userDataString));
      notifyListeners();
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
          "userId": _userId,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _handleSuccessfulLogin(data);
        // _is2FARequired = false;
        _userId = null;
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

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> data) async {
    _token = data['userToken'];
    _userData = UserData.fromJson(data['userData']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userData', jsonEncode(data['userData']));
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

  Future<void> forgotPassword(String email) async {
    try {
      var url = Uri.parse('$_baseUrl/api/user/forgot-password');
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
