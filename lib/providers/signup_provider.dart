import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class SignupProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // Method to clear messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners(); // Notify listeners to update the UI
  }

  // Method to handle API submission
  Future<void> signup({
    required String email,
    required String password,
    required String fname,
    required String lname,
    required String phone,
    required String city,
    required String country,
    required String role,
    required String bio,
    required File? image,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    // Prepare the payload
    Map<String, String> payload = {
      'email': email,
      'password': password,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'city': city,
      'country': country,
      'role': role,
      'bio': bio,
    };

    try {
      final url = Uri.parse('${Network.baseUrl}/api/user/register');
      var request = http.MultipartRequest('POST', url);

      // Add the fields to the request
      request.fields.addAll(payload);

      // Add the image if available
      if (image != null) {
        print('Attaching image to request: ${image.path}');
        final mimeType = lookupMimeType(image.path);
        if (mimeType == null) {
          _errorMessage = 'Unsupported file type.';
          _isLoading = false;
          notifyListeners();
          return;
        }
        final mimeSplit = mimeType.split('/');
        request.files.add(http.MultipartFile(
          'image',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: path.basename(image.path),
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ));
      } else {
        print('No image provided for the request.');
      }

      // Send the request
      var response = await request.send().timeout(const Duration(seconds: 50));
      var responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      // Handle the response
      if (response.statusCode == 201) {
        _successMessage = responseData['message'] ??
            'You have registered successfully. Please verify your email.';
        print(responseBody);
      } else if (response.statusCode == 400) {
        _errorMessage =
            responseData['message'] ?? 'Bad request. Please try again.';
        print(responseBody);
      } else {
        _errorMessage = responseData['error'] ?? 'An unknown error occurred.';
        print(responseBody);
      }
    } catch (error) {
      if (error is TimeoutException) {
        _errorMessage = 'Request timed out. Please try again later.';
      } else {
        _errorMessage = 'An error occurred: $error';
      }
      print('Signup error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
