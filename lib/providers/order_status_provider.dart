import 'dart:convert';
import 'dart:io';

import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/models/order_model.dart';
import 'package:bookreader/widgets/modal.dart';
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

  // Fetch orders for the logged-in user with an online-first approach
  Future<void> fetchOrders(String? deviceInfo) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    _orders = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      // print('Token: $_token');
      if (_token == null || _token!.isEmpty) {
        _errorMessage = 'Authentication required. Please log in First.';
        _isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }

      final url = Uri.parse(
          '${Network.baseUrl}/api/order/logged-user?deviceInfo=$deviceInfo');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      // print('order status response: ${response.body}');
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // print('Response Body: $responseBody');

        final List<dynamic> ordersData = responseBody['orders'];
        // print('Orders status Data: $ordersData');
        _orders = ordersData.map((json) => Order.fromJson(json)).toList();
        // print('Orders: $_orders');
        _successMessage =
            responseBody['message'] ?? 'Orders fetched successfully.';

        // Cache orders locally
        await prefs.setString('cachedOrders', json.encode(ordersData));
      } else {
        _errorMessage =
            responseBody['messsage'] ?? 'Failed to fetch your order status.';
        // print(
        //     'Failed to fetch orders status: ${response.body} Status code: ${response.statusCode}');
      }
    } catch (error) {
      if (error is SocketException) {
        _errorMessage =
            'No internet connection. Displaying cached orders if available.';
        // print('No internet connection: $error');

        // Attempt to load cached orders
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final cachedOrders = prefs.getString('cachedOrders');
        if (cachedOrders != null) {
          final Map<String, dynamic> ordersData = json.decode(cachedOrders);
          _orders = [Order.fromJson(ordersData)];

          _successMessage = 'Displaying cached orders.';
        } else {
          _errorMessage =
              'No internet connection and no cached data available.';
        }
      } else {
        _errorMessage = 'Failed to fetch orders. Please try again later.';
        // print('Failed to fetch orders: $error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
