import 'dart:convert';
import 'package:bookreader/services/book_service.dart';
import 'package:bookreader/services/file_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bookreader/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider with ChangeNotifier {
  List<dynamic> trendingBooks = [];
  List<dynamic> allBooks = [];
  List<dynamic> audioBooks = [];
  List<dynamic> searchResults = [];
  List<dynamic> recommendedBooks = [];

  String? _token;
  bool isSearching = false;
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
          await http.get(Uri.parse("${Network.baseUrl}/api/book/user/audio"));

      // Parse responses and handle errors individually
      if (trendingResponse.statusCode == 200) {
        trendingBooks = jsonDecode(trendingResponse.body)['books'];
        // print('Trending Books: ${trendingResponse.body}');
      } else {
        // print(
        //     "Trending books endpoint returned: ${trendingResponse.statusCode}");
        trendingBooks = []; // Default to empty list
      }

      if (allBooksResponse.statusCode == 200) {
        allBooks = jsonDecode(allBooksResponse.body);
        // print('All Books Fetched Successfully');
        await syncDownloadedBooksWithBackend(allBooks);
      } else {
        // print("All books endpoint returned: ${allBooksResponse.statusCode}");
        allBooks = []; // Default to empty list
      }

      if (audioResponse.statusCode == 200) {
        audioBooks = jsonDecode(audioResponse.body);
        // print('Audio Books: Fetched Successfully');
      } else {
        // print("Audio books endpoint returned: ${audioResponse.statusCode}");
        audioBooks = []; // Default to empty list
      }

      // If everything succeeds, set loading to false
      isLoading = false;
    } catch (e) {
      // print('Error fetching data: $e');
      hasError = true; // Indicate an error occurred
    } finally {
      notifyListeners(); // Notify listeners to update UI
    }
  }

  Future<void> fetchSearchAndRecommendations(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      recommendedBooks = [];
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken') ?? '';
      // print('Query: $query');
      final url = Uri.parse(
          "${Network.baseUrl}/api/book/search-recommendations?query=$query");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      // print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        searchResults = data['matchingBooks'] ?? [];
        // print('Search Results: $searchResults');
        recommendedBooks = data['recommendedBooks'] ?? [];
        // print('recommended Results: $recommendedBooks');
      } else {
        searchResults = [];
        recommendedBooks = [];
      }
    } catch (e) {
      searchResults = [];
      recommendedBooks = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    searchResults = [];
    recommendedBooks = [];
    notifyListeners();
  }

  static Future<void> syncDownloadedBooksWithBackend(
      List<dynamic> allBooks) async {
    // Get downloaded books from local storage
    final downloadedBooks = await BookService.getDownloadedBooks();

    for (var book in downloadedBooks) {
      // Check if the book exists in the backend's allBooks list
      bool bookExists =
          allBooks.any((backendBook) => backendBook['id'] == book['id']);

      // If the book doesn't exist in backend, delete it
      if (!bookExists) {
        await FileService.deleteBook(book['id'], book['title']);
      }
    }
  }
}
