import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isUploading = false;
  String _errorMessage = '';
  String _successMessage = '';
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;
  String _subscriptionType = 'monthly'; // Default to monthly

  bool get isUploading => _isUploading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  File? get receiptImage => _receiptImage;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get subscriptionType => _subscriptionType;

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

  Future<void> pickReceiptImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _receiptImage = File(pickedFile.path);
        notifyListeners();
      } else {
        _errorMessage = 'No image selected';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  Future<void> createSubscriptionOrder({
    required String tierId,
    required String bankName,
    required BuildContext context,
  }) async {
    if (_receiptImage == null) {
      errorMessage = 'Please select a receipt image';
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

    final mimeType = lookupMimeType(_receiptImage!.path);
    if (mimeType == null) {
      errorMessage = 'Invalid image type. Please upload a valid image';
      _isUploading = false;
      notifyListeners();
      return;
    }

    final mimeSplit = mimeType.split('/');
    final url = Uri.parse('${Network.baseUrl}/api/subscriptions');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['tier_id'] = tierId
      ..fields['bankName'] = bankName
      ..fields['start_date'] = _startDate!.toIso8601String()
      ..fields['end_date'] = _endDate!.toIso8601String();

    request.files.add(await http.MultipartFile.fromPath(
      'receiptImage',
      _receiptImage!.path,
      contentType: MediaType(mimeSplit[0], mimeSplit[1]),
    ));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        _successMessage =
            responseData['message'] ?? 'Subscription created successfully';
        _errorMessage = '';
      } else {
        final errorResponse = json.decode(responseBody);
        _errorMessage =
            errorResponse['error'] ?? 'Failed to create subscription';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
