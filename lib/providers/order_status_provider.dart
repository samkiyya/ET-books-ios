import 'dart:convert';
import 'dart:io';

import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/models/order_model.dart';
import 'package:book_mobile/widgets/modal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderStatusProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';
  String? _token = '';
  List<Order> _orders = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String? get token => _token;
  List<Order> get orders => _orders;

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

  // Fetch orders for the logged-in user
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    _orders = [];

    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      if (_token == null || _token!.isEmpty) {
        _errorMessage = 'Authentication required. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('${Network.baseUrl}/api/order/logged-user');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print('Response Body: $responseBody');

        final List<dynamic> ordersData = responseBody['orders'];
        print('Orders Data: $ordersData');
        _orders = ordersData.map((json) => Order.fromJson(json)).toList();
        print('Orders: $_orders');
        _successMessage =
            responseBody['message'] ?? 'Orders fetched successfully.';
      } else {
        _errorMessage = 'Failed to fetch orders: ${response.statusCode}';
      }
    } catch (error) {
      if (error is SocketException) {
        _errorMessage = 'No internet connection. Please check your network.';
      } else {
        _errorMessage = 'Failed to fetch orders: $error';
      }
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}
