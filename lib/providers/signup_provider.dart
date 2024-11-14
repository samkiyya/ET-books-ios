import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

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

    // Create a multipart request for uploading image
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('https://bookbackend3.bruktiethiotour.com/api/user/register')
    );

    // Add the fields to the request
    payload.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add the image if available
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    try {
      // Send the request
      var response = await request.send();
      
      // Parse the response
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _successMessage = 'Signup successful!';
        print("Response body: $responseBody");
      } else {
        _errorMessage = 'Failed to submit data: ${response.statusCode}';
        print("Response body: $responseBody");
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print("Exception: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
