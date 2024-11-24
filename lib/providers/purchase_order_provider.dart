import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/models/order_model.dart';
import 'package:book_mobile/widgets/modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PurchaseOrderProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  String? _token = '';
  List<Order> _orders = [];
  File? _receiptImage;

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String? get token => _token;
  List<Order> get orders => _orders;
  bool get isUploading => _isUploading;
  File? get receiptImage => _receiptImage;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _receiptImage = File(pickedFile.path);
      notifyListeners();
    }
  }

// Show success or error dialog
  void showResponseDialog(
      BuildContext context, String message, String buttonText, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomMessageModal(
          message: message,
          buttonText: buttonText,
          type: isSuccess
              ? 'success'
              : 'error', // Set type based on success or error
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> purchaseBook({
    required String id,
    required String transactionNumber,
    required String bankName,
    required String bookType,
    required BuildContext context,
  }) async {
    _errorMessage = '';
    _successMessage = '';
    _isLoading = true;
    notifyListeners();
    if (_receiptImage == null) {
      _errorMessage = 'Please select a receipt image';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isUploading = true;
      notifyListeners();
      // Check for image validation
      if (!_isValidImage(_receiptImage!)) {
        _errorMessage =
            'Invalid image format or size. Only JPEG, JPG, PNG, and GIF images under 10MB are allowed.';
        _isLoading = false;
        _isUploading = false;
        notifyListeners();
        return;
      }

      // final filePath = path.join(path.tempDirectory.path, fileName);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      if (_token == null || _token!.isEmpty) {
        _errorMessage = 'Authentication error. Please log in and try again.';
        _token = null;
        _isLoading = false;
        _isUploading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('${Network.baseUrl}/api/order/purchase');
      final headers = {
        'Authorization': 'Bearer $_token',
      };
      final request = http.MultipartRequest(
        'POST',
        url,
      );

      // Add form fields
      request.headers.addAll(headers);
      request.fields['bankName'] = bankName;

      request.fields['transactionNumber'] = transactionNumber;
      request.fields['book_id'] = id;
      request.fields['type'] = bookType;

// Add receipt image
      final mimeType = lookupMimeType(_receiptImage!.path)!;
      if (mimeType.isEmpty) {
        _errorMessage = 'Unsupported file type. Please upload a valid image.';
        _isLoading = false;
        _isUploading = false;
        notifyListeners();
        return;
      }
      final mimeSplit = mimeType.split('/');
      request.files.add(http.MultipartFile(
        'receiptImage',
        _receiptImage!.readAsBytes().asStream(),
        _receiptImage!.lengthSync(),
        filename: Uri.encodeComponent(path.basename(_receiptImage!.path)),
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ));
      final response = await request.send();
      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final parsedResponse = json.decode(responseBody);
        _successMessage = parsedResponse['message'] ??
            'Your Order submitted successfuly, please check the order status!';
      } else {
        final responseBody = await response.stream.bytesToString();
        _errorMessage = 'Failed to submit the order, please try again';
        print(
            'Failed to submit the order, please try again ${response.statusCode} - $responseBody');
      }
    } catch (error) {
      if (error is TimeoutException) {
        _errorMessage = 'Request timed out. Please try again later.';
      } else if (error is SocketException) {
        _errorMessage = 'No internet connection. Please check your network.';
        print('Error: $error');
      } else {
        _errorMessage = 'An error occurred. Please try again.';
        print('Error: $error');
      }
    } finally {
      _isLoading = false;
      _isUploading = false;
      notifyListeners();
    }
  }

  // Helper method to validate image size and type
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
