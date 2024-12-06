import 'dart:convert';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/models/announcement_model.dart';
import 'package:book_mobile/models/comment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementProvider with ChangeNotifier {
  static const String baseUrl = '${Network.baseUrl}/api';

  List<Announcement> _announcements = [];
  final Map<dynamic, List<Comment>> _comments = {};
  bool _isLoading = false;
  String? _error;

  List<Announcement> get announcements => _announcements;
  List<Comment> getComments(int announcementId) =>
      _comments[announcementId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/announcement/approved'));

      if (response.statusCode == 200) {
        Map<String, dynamic>? data = json.decode(response.body);
        if (data == null || data['data'] == null) {
          throw Exception('Invalid response structure');
        }
        List<dynamic> announcements = data['data'];
        _announcements =
            announcements.map((json) => Announcement.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        _error = 'Bad request';
      } else if (response.statusCode == 404) {
        _error = 'Data not found';
      } else if (response.statusCode == 500) {
        _error = 'Server error';
      } else {
        throw Exception('Failed to load announcements ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComments(int announcementId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcement/comments/$announcementId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> commentsData = data['data'] ?? [];
        final List<Comment> comments =
            commentsData.map((json) => Comment.fromJson(json)).toList();

        _comments[announcementId] = comments;

        notifyListeners();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addComment({
    required int announcementId,
    required String comment,
  }) async {
    final userId = await getUserId();
    print('userId: $userId');

    if (userId == null) {
      _error = 'You must be logged in to post a comment';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/announcement/comment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'announcementId': announcementId,
          'userId': userId,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        // Refresh comments and announcements to update counts
        await fetchComments(announcementId);
        await fetchAnnouncements();
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> likeAnnouncement(int announcementId) async {
    final url = Uri.parse('$baseUrl/announcement/like');
    final userId = await getUserId();

    if (userId == null) {
      _error = 'You must be logged in to like an announcement';
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'announcementId': announcementId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 201) {
        // Update local announcement data
        final announcement =
            _announcements.firstWhere((a) => a.id == announcementId);
        announcement.likesCount += 1;
        announcement.isLiked = true;

        notifyListeners();
      } else if (response.body
          .contains('User already liked this announcement')) {
        _error = 'You have already liked this announcement';
        notifyListeners();
      } else {
        throw Exception('Failed to like the announcement');
      }
    } catch (e) {
      _error = 'Something went wrong';
      notifyListeners();
    }
  }
}
