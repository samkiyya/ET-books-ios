import 'dart:convert';
import 'dart:io';
import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/services/image_upload_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class UpdateProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String? _token = '';
  double uploadProgress = 0.0;
  File? _profileImage;
  bool _isUploading = false;

  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get token => _token!;
  final ImagePicker _picker = ImagePicker();
  File? get profileImage => _profileImage;

  Future<void> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      notifyListeners();
    } else {
      _errorMessage = 'No image selected.';
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String filePath) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _errorMessage = 'No internet connection. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isUploading = true;
    uploadProgress = 0.0;
    _errorMessage = '';
    notifyListeners();

    try {
      // Validate image before proceeding
      final imageFile = File(filePath);
      if (!ImageUploadHelper.isValidImage(imageFile)) {
        _errorMessage =
            'Invalid image. Ensure the file is jpeg, jpg, png, or gif and is less than 10MB.';
        _isLoading = false;
        _isUploading = false;
        notifyListeners();
        return;
      }

      final token = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('userToken'));
      if (token == null) {
        _errorMessage = 'Authentication token is missing.';
        _isLoading = false;
        _isUploading = false;
        notifyListeners();
        return;
      }

      final dio = Dio();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
          contentType:
              MediaType.parse(lookupMimeType(imageFile.path) ?? 'image/jpeg'),
        ),
      });

      final response = await dio.put(
        '${Network.baseUrl}/api/user/update-image',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        onSendProgress: (int sent, int total) {
          uploadProgress = sent / total;
          notifyListeners();
        },
      );

      if (response.statusCode == 200) {
        // print('Image uploaded successfully');
        // print('Response data: ${response.data}');
      } else {
        _errorMessage =
            'Failed to upload image. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error uploading image: $e';
      // print(_errorMessage);
    } finally {
      _isLoading = false;
      _isUploading = false;
      notifyListeners();
    }
  }

  // Update User Profile
  Future<void> updateProfile({
    String? fname,
    String? lname,
    String? phone,
    String? bio,
    String? city,
    String? country,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _token = '';
    notifyListeners();

    final url =
        Uri.parse('${Network.baseUrl}/api/manage-user/update-my-account');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');

    // Create a Map and add only non-null fields
    final Map<String, dynamic> requestBody = {};
    if (fname != null) requestBody['fname'] = fname;
    if (lname != null) requestBody['lname'] = lname;
    if (phone != null) requestBody['phone'] = phone;
    if (bio != null) requestBody['bio'] = bio;
    if (city != null) requestBody['city'] = city;
    if (country != null) requestBody['country'] = country;

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // print('The token of profile update is: $_token');
      // print('response body is: ${response.body}');
      // print('response status code is: ${response.statusCode}');
      // final responseData = jsonDecode(response.body);
      // print('response data is: $responseData');

      if (response.statusCode == 200) {
        // Handle success response, you can parse any success data here if needed.
        _isLoading = false;
        notifyListeners();
      } else {
        // Handle error responses
        switch (response.statusCode) {
          case 400:
            _errorMessage = 'Bad Request: ${response.statusCode}';
            break;
          case 401:
            _errorMessage = 'Unauthorized: ${response.statusCode}';
            break;
          case 403:
            _errorMessage = 'Forbidden: ${response.statusCode}';
            break;
          case 404:
            _errorMessage = 'User Not Found: ${response.statusCode}';
            break;
          case 500:
            _errorMessage = 'Internal Server Error: ${response.statusCode}';
            break;
          default:
            _errorMessage = 'Failed to update profile: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete User Account
  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = '';
    _token = '';
    notifyListeners();

    final url =
        Uri.parse('${Network.baseUrl}/api/manage-user/delete-my-account');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 204) {
      // Handle success response (Account deleted)
      _isLoading = false;
      prefs.remove('userToken');
      prefs.clear();
      notifyListeners();
    } else if (response.statusCode == 401) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Unauthorized: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 403) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Forbiden you are Unauthorized: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 404) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'User Not Found: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else if (response.statusCode == 500) {
      // Handle unauthorized response (Token expired)
      _errorMessage = 'Internal Server Error: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    } else {
      _errorMessage = 'Failed to delete account: ${response.statusCode}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
