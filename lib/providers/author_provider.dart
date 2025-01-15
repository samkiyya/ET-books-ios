import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_mobile/models/author_model.dart';

class AuthorProvider extends ChangeNotifier {
  Map<String, dynamic>? author;
  bool isLoading = false;
  bool isFollowing = false;
  String errorMessage = '';
  String? _token;
  List<Author> _authors = [];

  List<Author> get authors => _authors;

  Future<void> fetchAuthorById(String id) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      print('Token: $_token');
      if (_token == null || _token!.isEmpty) {
        errorMessage = 'Authentication required. Please log in First.';
        isLoading = false;
        notifyListeners();
        return;
      }
      final url = Uri.parse(
        '${Network.baseUrl}/api/manage-user/get-author/$id',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('author data: $data');

        author = data['author'];
        isFollowing = data['author']['isFollowing'] ?? false;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (e is Exception) {
        // Check if e contains a specific structure
        String errorString = e.toString();

        // Attempt to extract the JSON part
        if (errorString.contains('Exception:')) {
          try {
            final error = json.decode(errorString.split('Exception:')[1]);
            errorMessage = error['message'];
            print("error from json author $errorMessage");
          } catch (e) {
            errorMessage = 'Error fetching author';
            print("Error: $errorMessage");
          }
        }
      } else {
        errorMessage = 'Error fetching author';
        print("Error: $errorMessage");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow(String userId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      print('Token: $_token');
      if (_token == null || _token!.isEmpty) {
        errorMessage = 'Authentication required. Please log in First.';
        isLoading = false;
        notifyListeners();
        return;
      }
      final url = Uri.parse(
        '${Network.baseUrl}/api/following/follow',
      );
      final response = await http.post(
        url,
        body: {'user_id': userId},
        headers: {'Authorization': 'Bearer $_token'},
      );
      print('response of authors: ${response.body}');

      if (response.statusCode == 200) {
        await fetchAuthorById(userId);
      } else if (response.statusCode == 201) {
        await fetchAuthorById(userId);
      } else {
        errorMessage = 'Error: ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error following/unfollowing: $e';
      print(errorMessage);
    } finally {
      print('isFollowing: $isFollowing');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAuthors() async {
    isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    print('Token: $_token');
    if (_token == null || _token!.isEmpty) {
      errorMessage = 'Authentication required. Please log in First.';
      isLoading = false;
      notifyListeners();
      return;
    }
    final url = Uri.parse('${Network.baseUrl}/api/manage-user/filter-authors');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['users'] != null) {
          // Map the authors from the API response
          _authors = (data['users'] as List).map((author) {
            // Create Author instance using the updated model
            print('author: $author');
            // isFollowing = _authors['author']['isFollowing'] ?? false;
            return Author.fromJson(author);
          }).toList();
          print('authors fetched: $_authors');
        } else {
          errorMessage = 'No authors found in the response.';
          print('Error: $errorMessage');
        }
      } else {
        errorMessage =
            'Failed to load authors. Status Code: ${response.statusCode}';
        print('Errors: $errorMessage');
      }
    } catch (error) {
      errorMessage = 'Error fetching authors: $error';

      print('catched error: $errorMessage');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
