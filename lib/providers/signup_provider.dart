import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SignupProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  File? _profileImage;
  bool _isUploading = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  final ImagePicker _picker = ImagePicker();
  File? get profileImage => _profileImage;
  bool get isUploading => _isUploading;

  // Method to clear messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<void> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Method to handle API submission
  Future<void> signup({
    required String email,
    required String password,
    required String fname,
    required String lname,
    String? phone,
    String? city,
    String? country,
    String? role,
    String? bio,
    String? referalCode,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    Map<String, String> payload = {
      'email': email,
      'password': password,
      'fname': fname,
      'lname': lname,
    };

    if (phone != null && phone.isNotEmpty) {
      payload['phone'] = phone;
    }
    if (city != null && city.isNotEmpty) {
      payload['city'] = city;
    }
    if (country != null && country.isNotEmpty) {
      payload['country'] = country;
    }
    if (role != null && role.isNotEmpty) {
      payload['role'] = role;
    }
    if (bio != null && bio.isNotEmpty) {
      payload['bio'] = bio;
    }
    if (referalCode != null && referalCode.isNotEmpty) {
      payload['referalCode'] = referalCode;
    }

    // Check internet connection
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == [ConnectivityResult.none]) {
      _errorMessage = 'No internet connection. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isUploading = true;
      notifyListeners();
      if (_profileImage != null && !_isValidImage(_profileImage!)) {
        _errorMessage =
            'Invalid image. Ensure the file is jpeg, jpg, png, or gif and is less than 10MB.';
        _isLoading = false;
        _isUploading = false;
        notifyListeners();
        return;
      }
      final url = Uri.parse('${Network.baseUrl}/api/user/register');
      var request = http.MultipartRequest('POST', url);

      // Add the fields to the request
      request.fields.addAll(payload);
      if (_profileImage != null) {
        // Add the image if available
        final mimeType = lookupMimeType(_profileImage!.path)!;
        if (mimeType.isEmpty) {
          _errorMessage = 'Unsupported file type.';
          _isLoading = false;
          _isUploading = false;
          notifyListeners();
          return;
        }
        final mimeSplit = mimeType.split('/');

        request.files.add(http.MultipartFile(
          'image',
          _profileImage!.readAsBytes().asStream(),
          _profileImage!.lengthSync(),
          filename: Uri.encodeComponent(path.basename(_profileImage!.path)),
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ));
      }
      // Send the request
      // var response = await request.send().timeout(const Duration(seconds: 50));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      print(responseBody);

      // Handle the response
      if (response.statusCode == 201) {
        _successMessage = responseData['message'] ??
            'You have registered successfully. Please verify your email.';
        print(responseBody);
      } else if (response.statusCode == 400) {
        _errorMessage =
            responseData['error'] ?? 'Bad request. Please check your inputs.';
        print('Server error $responseBody');
      } else {
        _errorMessage = responseData['error'] ??
            'Unexpected error occurred. please try again.';
        print(responseBody);
      }
    } catch (error) {
      _errorMessage = _mapErrorToMessage(error);

      print('Signup error: $_errorMessage');
    } finally {
      _isLoading = false;
      _isUploading = false;
      notifyListeners();
    }
  }

  String _mapErrorToMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out. Please try again later.';
    } else if (error is SocketException) {
      return 'No internet connection, please enable your internet connection.';
    } else if (error is FormatException) {
      return 'Invalid response from server. Please try again later.';
    } else if (error is ClientException) {
      return 'Failed to connect to the server.';
    } else if (error is HttpException) {
      return 'Failed to send request. Please try again later.';
    } else {
      return 'An error occurred: $error';
    }
  }

  bool _isValidImage(File image) {
    // Validate image size
    int maxSize = 10 * 1024 * 1024; // 10 MB
    if (image.lengthSync() > maxSize) {
      return false;
    }

    // Validate image type (extension)
    List<String> validExtensions = ['.jpeg', '.jpg', '.png', '.gif'];
    String extension = path.extension(image.path).toLowerCase();
    if (!validExtensions.contains(extension)) {
      return false;
    }

    return true;
  }
}
