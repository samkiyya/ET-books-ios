import 'dart:convert';
import 'package:bookreader/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccessProvider with ChangeNotifier {
  final String apiUrl = "${Network.baseUrl}/api/asset-usage/user-usage";

  // State variables
  bool _hasReachedLimitAndApproved = true;
  String? _errorMessage;

  bool get hasReachedLimitAndApproved => _hasReachedLimitAndApproved;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSubscriptionStatus(
      String userId, String contentType,int bookId) async {
    print(
        'fetchSubscriptionStatus called with userId: $userId and contentType: $contentType');
    final url = Uri.parse("$apiUrl/$userId?contentType=$contentType&bookId=$bookId");
    try {
      final response = await http.get(url);
      // print("content access Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // print("AccessProvider data: $data");
        print("AccessProvider data: $data");
        if (data["success"] == true) {
          print("AccessProvider data: $data");
          // Directly access hasReachedLimit from the API response
          _hasReachedLimitAndApproved =
              data["hasReachedLimit"] == false;
          print('hasReachedLimitAndApproved: $_hasReachedLimitAndApproved');
          // print("AccessProvider hasReachedLimitAndApproved: $_hasReachedLimitAndApproved");
        } else {
          _errorMessage = "API responded with success = false";
          _hasReachedLimitAndApproved = false;
        }
      } else {
        _errorMessage = "Failed to fetch data: ${response.statusCode}";
        _hasReachedLimitAndApproved = false;
      }
    } catch (error) {
      _errorMessage = "An error occurred: $error";
      _hasReachedLimitAndApproved = false;
    }
    finally {
      // Notify listeners
      notifyListeners();
    }
  }
}



// import 'dart:convert';
// import 'package:bookreader/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AccessProvider with ChangeNotifier {
//   final String apiUrl = "${Network.baseUrl}/api/asset-usage/user-usage";


//   // State variables
//   bool? _hasReachedLimitAndApproved;
//   String? _errorMessage;

//   bool? get hasReachedLimitAndApproved => _hasReachedLimitAndApproved;
//   String? get errorMessage => _errorMessage;

//   Future<void> fetchSubscriptionStatus(String userId,String contentType) async {
//     final url = Uri.parse("$apiUrl/$userId?contentType=$contentType");
//     try {
//       final response = await http.get(url);
//       // print("content access Response: ${response.body}");

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         // print("AccessProvider data: $data");

//         if (data["success"] == true) {
//           // Process the subscriptions
//           final subscriptions = data["subscriptions"] as List<dynamic>;
//           _hasReachedLimitAndApproved = subscriptions.any((sub) =>
//               sub["hasReachedLimit"] == false &&
//               sub["approvalStatus"].toString().toUpperCase() == "APPROVED");
//           // print(
//           //     "AccessProvider hasReachedLimitAndApproved: $_hasReachedLimitAndApproved");
//         } else {
//           _errorMessage = "API responded with success = false";
//           _hasReachedLimitAndApproved = false;
//         }
//       } else {
//         _errorMessage = "Failed to fetch data: ${response.statusCode}";
//         _hasReachedLimitAndApproved = false;
//       }
//     } catch (error) {
//       _errorMessage = "An error occurred: $error";
//       _hasReachedLimitAndApproved = false;
//     }

//     // Notify listeners
//     notifyListeners();
//   }
// }
