import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:book_mobile/constants/constants.dart';

class HomeProvider with ChangeNotifier {
  List<dynamic> trendingBooks = [];
  List<dynamic> allBooks = [];
  List<dynamic> audioBooks = [];
  bool isLoading = true;
  bool hasError = false;

  Future<void> fetchAllData() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      // Fetch data from all three endpoints
      final trendingResponse =
          await http.get(Uri.parse("${Network.baseUrl}/api/book/last7days"));
      final allBooksResponse =
          await http.get(Uri.parse("${Network.baseUrl}/api/book/get-all"));
      final audioResponse =
          await http.get(Uri.parse("${Network.baseUrl}/api/book/audio"));

      // Parse responses and handle errors individually
      if (trendingResponse.statusCode == 200) {
        trendingBooks = jsonDecode(trendingResponse.body)['books'];
        print('Trending Books: ${trendingResponse.body}');
      } else {
        print(
            "Trending books endpoint returned: ${trendingResponse.statusCode}");
        trendingBooks = []; // Default to empty list
      }

      if (allBooksResponse.statusCode == 200) {
        allBooks = jsonDecode(allBooksResponse.body);
        print('All Books Fetched Successfully');
      } else {
        print("All books endpoint returned: ${allBooksResponse.statusCode}");
        allBooks = []; // Default to empty list
      }

      if (audioResponse.statusCode == 200) {
        audioBooks = jsonDecode(audioResponse.body);
        print('Audio Books: ${audioResponse.body}');
      } else {
        print("Audio books endpoint returned: ${audioResponse.statusCode}");
        audioBooks = []; // Default to empty list
      }

      // If everything succeeds, set loading to false
      isLoading = false;
    } catch (e) {
      print('Error fetching data: $e');
      hasError = true; // Indicate an error occurred
    } finally {
      notifyListeners(); // Notify listeners to update UI
    }
  }
}
