import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bookreader/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('userToken');
      if (token == null || token.isEmpty) {
        errorMessage = 'Authentication error. Please log in.';
        return;
      }
      // Fetch data from the endpoint
      final response = await http.get(
          Uri.parse(
              "${Network.baseUrl}/api/subscriptions/tiers/user/tier-list"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          });

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Ensure the structure is valid and contains "data"
        if (responseBody.containsKey('data')) {
          tiers = responseBody['data'];
          // print('tiers are: $tiers'); // Extract the list from the "data" key
        } else {
          errorMessage = "Unexpected response format: 'data' key missing.";
          // print(errorMessage);
          tiers = [];
          hasError = true;
        }
      } else {
        errorMessage = "Error: Received status code ${response.statusCode}";
        tiers = [];
        hasError = true;
      }
    } catch (e) {
      if (e is http.ClientException) {
        errorMessage =
            'Error fetching data: please check your internet connection';
      } else {
        errorMessage = 'Error fetching data: ';
      }
      // print('Error fetching data: $e');
      hasError = true;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
