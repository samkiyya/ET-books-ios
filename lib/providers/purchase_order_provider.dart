import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PurchaseOrderProvider with ChangeNotifier {
  bool _isLoading = false;
  String _responseMessage = '';

  bool get isLoading => _isLoading;
  String get responseMessage => _responseMessage;

  Future<void> purchaseBook({
    required String id,
    required String transactionNumber,
    required String bankName,
    required String receiptImage,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('${Network.baseUrl}/api/order/purchase/$id');
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final body = {
      'transactionNumber': transactionNumber,
      'bankName': bankName,
      'receiptImage': receiptImage,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        _responseMessage = 'Purchase Successful!';
      } else {
        _responseMessage =
            'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (error) {
      _responseMessage = 'Failed to purchase: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
