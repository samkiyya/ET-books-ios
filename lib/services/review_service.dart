import 'dart:convert';
import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/models/review_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _baseUrl = Network.baseUrl;
  String? _token;

  // Create review
  Future<void> createReview(
      int bookId, String comment, int reviewRating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    // print('Token from review: $_token');
    if (_token == null) {
      // print('user have no token');
      return;
    }
    // print('comment from user: $comment');
    final response = await http.post(
      Uri.parse("$_baseUrl/api/user-review"),
      headers: {
        "Authorization": "Bearer $_token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "bookId": bookId,
        "comment": comment,
        "reviewRating": reviewRating,
      }),
    );
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // print('review response: $responseData');

    if (response.statusCode != 201) {
      throw Exception(
          "${responseData['message'] ?? 'Failed to create review'}");
    }
  }

  // Update review
  Future<void> updateReview(
      int reviewId, int bookId, String comment, int reviewRating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    // print('Token: $_token');
    if (_token == null) {
      // print('user have no token');
      return;
    }
    final response = await http.put(
      Uri.parse("$_baseUrl/api/user-review/$reviewId"),
      headers: {
        "Authorization": "Bearer $_token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "bookId": bookId,
        "comment": comment,
        "reviewRating": reviewRating,
      }),
    );

    // print(
    //     'book detail sending: book id: $bookId reviewId: $reviewId comment: $comment rating: $reviewRating');
    // print('review response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception("Failed to update review");
    }
  }

  // Fetch reviews for a book
  Future<List<Review>> fetchReviews(int bookId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    // print('Token: $_token');
    if (_token == null) {
      // print('user have no token');
      return [];
    }
    final response = await http.get(
      Uri.parse("$_baseUrl/api/user-review/$bookId"),
      headers: {
        "Authorization": "Bearer $_token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load reviews");
    }
  }

  // Fetch average rating for a book
  Future<AverageRating> fetchAverageRating(int bookId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    // print('Token: $_token');
    if (_token == null) {
      // print('user have no token');
      throw 'error to fetch rating';
    }
    final response = await http.get(
      Uri.parse("$_baseUrl/api/user-review/average/$bookId"),
      headers: {
        "Authorization": "Bearer $_token",
      },
    );

    if (response.statusCode == 200) {
      return AverageRating.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load average rating");
    }
  }

  // Delete review
  Future<void> deleteReview(int reviewId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    // print('Token: $_token');
    if (_token == null) {
      // print('User has no token');
      return;
    }
    final response = await http.delete(
      Uri.parse("$_baseUrl/api/user-review/$reviewId"),
      headers: {
        "Authorization": "Bearer $_token",
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete review: ${response.statusCode}");
    }
  }
}
