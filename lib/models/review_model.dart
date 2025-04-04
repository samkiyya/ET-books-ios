class Review {
  final int id;
  final String comment;
  final int reviewRating;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final int bookId;
  final User user;

  Review({
    required this.id,
    required this.comment,
    required this.reviewRating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.bookId,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      comment: json['comment'],
      reviewRating: json['reviewRating'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userId: json['userId'],
      bookId: json['bookId'],
      user: User.fromJson(json['User']),
    );
  }
}

class User {
  final int id;
  final String fname;
  final String lname;

  User({required this.id, required this.fname, required this.lname});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
    );
  }
}

class AverageRating {
  final bool success;
  final double averageRating;

  AverageRating({
    required this.success,
    required this.averageRating,
  });

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      success: json['success'],
      averageRating: json['averageRating'].toDouble(),
    );
  }
}
