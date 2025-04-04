import 'package:bookreader/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isUploading = false;
  String _errorMessage = '';
  String _successMessage = '';
  File? _receiptFile; // Changed from receiptImage to receiptFile
  DateTime? _startDate;
  DateTime? _endDate;
  String _subscriptionType = 'monthly';
  bool _isImage = false;

  bool get isUploading => _isUploading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  File? get receiptFile => _receiptFile; // Updated getter

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get subscriptionType => _subscriptionType;
  bool get isImage => _isImage;

  set errorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  set subscriptionType(String type) {
    if (type != 'monthly' && type != 'yearly') {
      _errorMessage = 'Invalid subscription type';
      notifyListeners();
      return;
    }
    _subscriptionType = type;
    _calculateEndDate();
    notifyListeners();
  }

  set startDate(DateTime? date) {
    if (date == null) {
      _errorMessage = 'Start date cannot be null';
      notifyListeners();
      return;
    }
    if (date.isBefore(DateTime.now())) {
      _errorMessage = 'Start date cannot be in the past';
      notifyListeners();
      return;
    }
    _startDate = date;
    _errorMessage = '';
    _calculateEndDate();
    notifyListeners();
  }

  void _calculateEndDate() {
    if (_startDate == null) return;

    if (_subscriptionType == 'monthly') {
      _endDate = _startDate!.add(const Duration(days: 30)); // Add 1 month
    } else if (_subscriptionType == 'yearly') {
      _endDate = _startDate!.add(const Duration(days: 365)); // Add 1 year
    }
    notifyListeners();
  }

  Future<void> pickReceiptFile() async {
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
          _receiptFile = File(pickedFile.path!);
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
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) return text; // Handle empty string
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> createSubscriptionOrder({
    required String tierId,
    required String bankName,
    required String transactionNumber,
    required int benefitLimitRemain,
    required String subscriptionType,
    required BuildContext context,
  }) async {
    if (_receiptFile == null) {
      errorMessage = 'Please select a receipt file';
      return;
    }
    if (_startDate == null || _endDate == null) {
      errorMessage = 'Please select valid start and end dates';
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    if (token == null || token.isEmpty) {
      errorMessage = 'Authentication error. Please log in.';
      return;
    }

    _isUploading = true;
    notifyListeners();

    final mimeType = lookupMimeType(_receiptFile!.path);
    if (mimeType == null) {
      errorMessage = 'Invalid file type. Please upload a valid file';
      _isUploading = false;
      notifyListeners();
      return;
    }
    // Check if the MIME type is allowed
    final allowedMimeTypes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/gif',
      'application/pdf',
    ];
    if (!allowedMimeTypes.contains(mimeType)) {
      errorMessage = 'Only jpeg, jpg, png, gif, and pdf files are allowed';
      _isUploading = false;
      notifyListeners();
      return;
    }
    // print('MIME type of the file: $mimeType');
    // print('File path: ${_receiptFile!.path}');
    final mimeSplit = mimeType.split('/');
    final url = Uri.parse('${Network.baseUrl}/api/subscription-order/purchase');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['tier_id'] = tierId
      ..fields['bankName'] = bankName
      ..fields['transactionNumber'] = transactionNumber
      ..fields['subscriptionType'] = capitalize(subscriptionType)
      ..fields['start_date'] = _startDate!.toIso8601String()
      ..fields['end_date'] = _endDate!.toIso8601String();

    request.files.add(await http.MultipartFile.fromPath(
      'receiptImagePath',
      _receiptFile!.path,
      contentType: MediaType(mimeSplit[0], mimeSplit[1]),
    ));
    // print('Headers: ${request.headers}');

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      // print('response: ${responseBody}');

      if (response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        _successMessage =
            responseData['message'] ?? 'Subscription created successfully';
        _errorMessage = '';
      } else {
        final errorResponse = json.decode(responseBody);
        _errorMessage = errorResponse['message'] ??
            errorResponse['error'] ??
            'Failed to create subscription';
        // print(errorResponse);
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
