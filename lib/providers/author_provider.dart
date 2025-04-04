import 'dart:convert';
import 'package:bookreader/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookreader/models/author_model.dart';

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
      // print('Token: $_token');
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
        // print('author data: $data');

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
            // print("error from json author $errorMessage");
          } catch (e) {
            errorMessage = 'Error fetching author';
            // print("Error: $errorMessage");
          }
        }
      } else {
        errorMessage = 'Error fetching author';
        // print("Error: $errorMessage");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Toggle follow/unfollow an author
  Future<void> toggleFollow(String userId) async {
    _setLoading(true);
    try {
      await _loadToken();
      if (_token == null || _token!.isEmpty) {
        _setError('Authentication required. Please log in First.');
        return;
      }

      final url = Uri.parse('${Network.baseUrl}/api/following/follow');
      final response = await http.post(
        url,
        body: {'user_id': userId},
        headers: {'Authorization': 'Bearer $_token'},
      );

      // print('Toggle follow response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // print('Toggle follow request for user: $userId');

        await fetchAuthorById(userId); // Refresh the author data
      } else {
        _setError('Error toggling follow status. ${response.body}');
      }
    } catch (e) {
      _handleError(e, 'Error toggling follow status');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all authors
  Future<void> fetchAuthors() async {
    _setLoading(true);

    try {
      await _loadToken();
      if (_token == null || _token!.isEmpty) {
        _setError('Authentication required. Please log in First.');
        return;
      }

      final url =
          Uri.parse('${Network.baseUrl}/api/manage-user/filter-authors');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['users'] != null) {
          _authors = (data['users'] as List)
              .map((author) => Author.fromJson(author))
              .toList();
          // print('Authors fetched: $_authors');
        } else {
          _setError('No authors found in the response.');
        }
      } else {
        _setError(
            'Failed to load authors. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e, 'Error fetching authors');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    errorMessage = message;
    isLoading = false;
    notifyListeners();
    // print('Error: $message');
  }

  void _handleError(dynamic error, String defaultMessage) {
    try {
      if (error is Exception) {
        String errorString = error.toString();
        if (errorString.contains('Exception:')) {
          final errorJson = json.decode(errorString.split('Exception:')[1]);
          _setError(errorJson['message'] ?? defaultMessage);
        } else {
          _setError(defaultMessage);
        }
      } else {
        _setError(defaultMessage);
      }
    } catch (_) {
      _setError(defaultMessage);
    }
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    // print('Loaded token: $_token');
  }

  Future<void> toggleFollowAuthors(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      if (_token == null || _token!.isEmpty) {
        errorMessage = 'Authentication required. Please log in first.';
        notifyListeners();
        return;
      }

      final url = Uri.parse('${Network.baseUrl}/api/following/follow');
      final response = await http.post(
        url,
        body: {'user_id': userId},
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index =
            _authors.indexWhere((author) => author.id == (int.parse(userId)));
        if (index != -1) {
          _authors[index].isFollowing = !_authors[index].isFollowing;
          // Update follow count accordingly
          _authors[index].followers += _authors[index].isFollowing ? 1 : -1;
          notifyListeners();
        }
      } else {
        errorMessage = 'Error: ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error following/unfollowing: $e';
    }
  }
}
