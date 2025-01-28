import 'package:book_mobile/models/review_model.dart';
import 'package:book_mobile/services/review_service.dart';
import 'package:flutter/material.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  // late HomeProvider _homeProvider;
        
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  bool _loading = false;
  int _reviewCount = 0;

  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get loading => _loading;
  int get reviewCount => _reviewCount;
  // Set HomeProvider reference
  // void setHomeProvider(HomeProvider homeProvider) {
  //   _homeProvider = homeProvider;
  // }

  // Fetch reviews for a book
  Future<void> fetchReviews(int bookId) async {
    _loading = true;
    notifyListeners();

    try {
      _reviews = await _reviewService.fetchReviews(bookId);
      _reviewCount = _reviews.length;
      await fetchAverageRating(bookId);
      // Update book data
      // await _homeProvider.fetchAllData();

      notifyListeners();
    } catch (e) {
      throw e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Fetch average rating for a book
  Future<void> fetchAverageRating(int bookId) async {
    try {
      final avg = await _reviewService.fetchAverageRating(bookId);
      _averageRating = avg.averageRating;

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  // Add review
  Future<void> addReview(int bookId, String comment, int reviewRating) async {
    try {
      await _reviewService.createReview(bookId, comment, reviewRating);
      await fetchReviews(bookId);
    } catch (e) {
      throw e;
    }
  }

  // Update review
  Future<void> updateReview(
      int reviewId, int bookId, String comment, int reviewRating) async {
    try {
      await _reviewService.updateReview(
          reviewId, bookId, comment, reviewRating);
      await fetchReviews(bookId);
    } catch (e) {
      throw e;
    }
  }

  // Delete review
  Future<void> deleteReview(int reviewId, int bookId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      await fetchReviews(bookId); // Refresh the reviews for the book
    } catch (e) {
      throw e;
    }
  }
}
