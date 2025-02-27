import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/models/order_model.dart';
import 'package:bookreader/widgets/modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';

class PurchaseOrderProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  String? _token = '';
  final List<Order> _orders = [];
  File? _receiptImage;
  bool _isImage = false;

  bool _isUploading = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String? get token => _token;
  List<Order> get orders => _orders;
  bool get isUploading => _isUploading;
  File? get receiptImage => _receiptImage;
  bool get isImage => _isImage;

  Future<void> pickImage() async {
    try {
      // Use FilePicker to select any file type
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        // Get the first selected file
        final pickedFile = result.files.first;

        // Create a File object from the picked file path
        if (pickedFile.path != null) {
          final mimeType = lookupMimeType(pickedFile.path!);
          _isImage = mimeType != null && mimeType.startsWith('image/');

          _receiptImage = File(pickedFile.path!);
          notifyListeners();
        } else {
          _errorMessage = 'No file selected';
          notifyListeners();
        }
      } else {
        _errorMessage = 'No file selected';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick file: $e';
      notifyListeners();
    } finally {
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
            isSuccess ? context.go('/status') : context.pop();
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
    required String deviceInfo,
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
      // print("base url${Network.baseUrl}");

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
      request.fields['deviceInfo'] = deviceInfo;
      final mimeType = lookupMimeType(_receiptImage!.path);
      if (mimeType == null) {
        _errorMessage = 'Invalid file type. Please upload a valid file';
        _isUploading = false;
        notifyListeners();
        return;
      }

      final mimeSplit = mimeType.split('/');

      request.files.add(await http.MultipartFile.fromPath(
        'receiptImage',
        _receiptImage!.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ));

      // print('media type is: ${MediaType(mimeSplit[0], mimeSplit[1])}');
      // request.files.add(http.MultipartFile(
      //   'receiptImage',
      //   _receiptImage!.readAsBytes().asStream(),
      //   _receiptImage!.lengthSync(),
      //   filename: Uri.encodeComponent(path.basename(_receiptImage!.path)),
      //   contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      // ));
      final response = await request.send();
      if (response.statusCode == 201) {
        _receiptImage = null;
        final responseBody = await response.stream.bytesToString();
        final parsedResponse = json.decode(responseBody);
        _successMessage = parsedResponse['message'] ??
            'Your Order submitted successfuly, please check the order status!';
      } else {
        final responseBody = await response.stream.bytesToString();
        final parsedResponse = json.decode(responseBody);
        // print(parsedResponse);

        _errorMessage = parsedResponse['message'] ??
            'Failed to submit the order, please try again';
        // print(
        //     'Failed to submit the order, please try again ${response.statusCode} - $responseBody');
      }
    } catch (error) {
      if (error is TimeoutException) {
        _errorMessage = 'Request timed out. Please try again later.';
      } else if (error is SocketException) {
        _errorMessage = 'No internet connection. Please check your network.';
        // print('Error: $error');
      } else {
        _errorMessage = 'An error occurred. Please try again.';
        // print('Error: $error');
      }
    } finally {
      _isLoading = false;
      _isUploading = false;
      notifyListeners();
    }
  }

  // Helper method to validate image size and type
  // bool _isValidImage(File image) {
  //   // Validate image size
  //   int maxSize = 10 * 1024 * 1024; // 10 MB
  //   if (image.lengthSync() > maxSize) {
  //     return false;
  //   }

  //   // Validate image type (extension)
  //   List<String> validExtensions = ['.jpeg', '.jpg', '.png', '.gif'];
  //   String extension = path.extension(image.path).toLowerCase();
  //   if (!validExtensions.contains(extension)) {
  //     return false;
  //   }

  //   return true;
  // }
}
