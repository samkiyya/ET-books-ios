import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/models/login_model.dart';
import 'package:bookreader/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthProvider with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? get context => navigatorKey.currentContext;
  final StorageService storageService;
  bool _is2FAEnabled = false;

  static const String _baseUrl = Network.baseUrl;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isLoggingOut = false;
  bool get is2FAEnabled => _is2FAEnabled;

  String? _token;
  UserData? _userData;
  String? _error;
  final AppLinks _appLinks = AppLinks();

  /// Public getters

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  UserData? get userData => _userData;
  String? get error => _error;
  late StreamSubscription<Uri?> _appLinkSubscription;

  AuthProvider({required this.storageService}) {
    _initAppLinks();
    load2FAPreferences();
  }

  Future<void> load2FAPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _is2FAEnabled = prefs.getBool('2faEnabled') ?? false;
    notifyListeners();
  }

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
    try {
      _token = data['userToken'] ?? "";
      if (_token!.isEmpty) throw Exception("Invalid token");

      if (data['userData'] == null) throw Exception("User data is missing");
      _userData = UserData.fromJson(data['userData']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userToken', _token ?? "");
      await prefs.setString('userData', jsonEncode(_userData?.toJson()));

      // print('User ID: ${_userData?.id}');
      // print('User Data 🤣🤣: ${_userData?.toJson()}');

      _updateAuthState(
        isAuthenticated: true,
        token: _token,
        userData: _userData,
      );
    } catch (e) {
      // print("Error in _handleSuccessfulLogin: $e");
      throw e;
    }
  }

  /// Remove token and user data from storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userData');
    _updateAuthState(isAuthenticated: false, token: null, userData: null);
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
      _updateAuthState(isLoading: false);
    }
  }

  void _initAppLinks() {
    _appLinkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        final token = uri.queryParameters['token'];
        final userDataString = uri.queryParameters['userData'];

        if (token != null && userDataString != null) {
          try {
            final userData = jsonDecode(userDataString);
            // print('Received token: $token');
            // print('Received user data: ${jsonEncode(userData)}');

            await _handleSuccessfulLogin({
              'userToken': token,
              'userData': userData,
            });

            if (isAuthenticated) {
              if (context != null && context!.mounted) {
                context!.go('/home');
              }
            } else {
              if (context != null && context!.mounted) {
                context!.go('/welcome');
              }
            }

            // Important: After successful login, cancel the listener. You only need the one callback.
            _appLinkSubscription.cancel();
          } catch (e) {
            throw e;
            // print("Error decoding or handling user data: $e");
          }
        } else {
          // print('Required parameters not found in callback URL');
          // Handle missing parameters (e.g., show an error message)
        }
      }
    });
  }

  @override
  void dispose() {
    _appLinkSubscription.cancel();
    super.dispose();
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    try {
      final Uri loginUrl = Uri.parse("$_baseUrl/api/auth/google");
      if (await canLaunchUrl(loginUrl)) {
        await launchUrl(loginUrl, mode: LaunchMode.externalApplication);
        // await _handleGoogleCallback();
      } else {
        throw Exception("Could not launch Google login");
      }
    } catch (e) {
      throw Exception("Google login error: $e");
    } finally {
      _updateAuthState(isLoading: false);
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
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/user/forgot-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to reset password");
      }
    } catch (e) {
      throw Exception("Forgot password error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    // print("reset token from the deeplink: $resetToken");
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/user/reset-password/$resetToken"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"password": newPassword}),
      );

      // print('Response of password reset: ${response.body}');
      if (response.statusCode != 200) {
        _error = json.decode(response.body)['message'] ??
            'Unknown error during reset password';
        throw Exception("Failed to reset password ${response.body}");
      }
    } catch (e) {
      throw Exception("Reset password error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify account using a token
  Future<void> verifyAccount(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      var url = Uri.parse('$_baseUrl/api/user/verify/account/$token');
      var response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Verification failed');
      }
    } catch (e) {
      throw Exception("Verification failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    if (_token == null) {
      throw Exception("No token found");
    }

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
      _is2FAEnabled = !_is2FAEnabled;
      prefs.setBool('2faEnabled', _is2FAEnabled);
    } catch (e) {
      throw Exception("Failed to toggle 2FA: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
