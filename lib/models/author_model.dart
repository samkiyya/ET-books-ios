class Author {
  final int id;
  final String name; // Full name field
  final String bio;
  final String imageFilePath;
  final int booksCount;
  final double rating;
  final int followers;
  final bool isFollowing;
  final List<Book> books;

  Author({
    required this.id,
    required this.name, // Full name passed directly
    required this.bio,
    required this.imageFilePath,
    required this.booksCount,
    required this.rating,
    required this.followers,
    required this.books,
    required this.isFollowing,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'], // Directly map the full name
      bio: json['bio'],
      imageFilePath: json['image'],
      booksCount: json['books'].length ?? 0, // Count of books
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      followers: json['followerCount'] ?? 0,
      isFollowing: json['isFollowing']??false, 
      books:
          (json['books'] as List).map((book) => Book.fromJson(book)).toList(),
    );
  }
}

class Book {
  final int id;
  final String title;
  final String description;
  final int publicationYear;
  final String language;
  final String price;
  final String audioPrice;
  final double rating;
  final int rateCount;
  final int pages;
  final int sold;
  final String status;

  Book({
    required this.id,
    required this.title,
    required this.description,
    required this.publicationYear,
    required this.language,
    required this.price,
    required this.audioPrice,
    required this.rating,
    required this.rateCount,
    required this.pages,
    required this.sold,
    required this.status,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      publicationYear: json['publicationYear'],
      language: json['language'],
      price: json['price'],
      audioPrice: json['audio_price'],
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      rateCount: json['rateCount'],
      pages: json['pages'],
      sold: json['sold'],
      status: json['status'],
    );
  }
}
