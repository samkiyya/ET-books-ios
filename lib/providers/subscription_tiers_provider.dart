import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:book_mobile/constants/constants.dart';

class SubscriptionTiersProvider with ChangeNotifier {
  List<dynamic> tiers = []; // Keeping as dynamic if using raw JSON
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchAllTiers() async {
    isLoading = true;
    hasError = false;
    errorMessage = '';
    notifyListeners();

    try {
      // Fetch data from the endpoint
      final response = await http
          .get(Uri.parse("${Network.baseUrl}/api/subscriptions/tiers"));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Ensure the structure is valid and contains "data"
        if (responseBody.containsKey('data')) {
          tiers = responseBody['data'];
          print('tiers are: $tiers'); // Extract the list from the "data" key
        } else {
          errorMessage = "Unexpected response format: 'data' key missing.";
          print(errorMessage);
          tiers = [];
          hasError = true;
        }
      } else {
        errorMessage = "Error: Received status code ${response.statusCode}";
        tiers = [];
        hasError = true;
      }
    } catch (e) {
      errorMessage = 'Error fetching data: $e';
      print('Error fetching data: $e');
      hasError = true;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
