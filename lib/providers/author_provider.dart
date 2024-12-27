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
      errorMessage = 'Error fetching author: $e';
      print(errorMessage);
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

    final url = Uri.parse('${Network.baseUrl}/api/manage-user/filter-authors');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authors = (data['users'] as List)
            .map((author) => Author.fromJson(author))
            .toList();
      }
    } catch (error) {
      print('Error fetching authors: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
