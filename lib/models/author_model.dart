class Author {
  final int id;
  final String fname;
  final String lname;
  final String bio;
  final String imageFilePath;
  final int booksCount;
  final double rating;
  final int followers;

  Author({
    required this.id,
    required this.fname,
    required this.lname,
    required this.bio,
    required this.imageFilePath,
    required this.booksCount,
    required this.rating,
    required this.followers,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      bio: json['bio'],
      imageFilePath: json['imageFilePath'],
      booksCount: json['booksCount'] ?? 0,
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      followers: json['followers'] ?? 0,
    );
  }
}
