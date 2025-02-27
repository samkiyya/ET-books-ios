import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/models/author_model.dart';
import 'package:flutter/material.dart';

class AuthorCard extends StatelessWidget {
  final Author author;

  const AuthorCard({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.color5,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Author Profile
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.2),
                child: Image.network(
                  author.imageFilePath.isNotEmpty
                      ? '${Network.baseUrl}/${author.imageFilePath}'
                      : 'https://xsgames.co/randomusers/avatar.php?g=pixel',
                  width: width * 0.4,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Icon(
                      Icons.broken_image, // Alternative icon
                      size: width * 0.4,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    author.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    author.bio,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color3.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),

          // Author Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${author.booksCount} Books',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color3.withOpacity(0.7),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow.shade800, size: 20),
                  SizedBox(width: 5),
                  Text(
                    author.rating.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.color3.withOpacity(0.7)),
                  ),
                ],
              ),
              Text(
                'Follower ${author.followers}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color3.withOpacity(0.7),
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          // Horizontal Scrollable List of Books
          author.books.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    backgroundBlendMode: BlendMode.overlay,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Some of My Books',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.color3,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.05,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: height *
                            0.25, // You can adjust this based on your design
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: author.books.length,
                          itemBuilder: (context, index) {
                            var book = author.books[index];
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: 1.0,
                              child: GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //                                                   context,
                                  //                                                   MaterialPageRoute(
                                  //                                                     builder: (context) =>
                                  //                                                         BookDetailScreen(
                                  //                                                             book: book),
                                  //                                                   ),
                                  //                                                 ),
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: SizedBox(
                                    width: width * 0.4,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Image.network(
                                          //   '${Network.baseUrl}/${book.imageFilePath}',
                                          //   height: 120, // Adjust based on your design
                                          //   width: 100,
                                          //   fit: BoxFit.contain,
                                          // ),
                                          const Icon(
                                            Icons.book,
                                            size: 100,
                                            color: AppColors.color1,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            book.title,
                                            style: AppTextStyles.bodyText
                                                .copyWith(
                                                    color: AppColors.color4,
                                                    fontWeight:
                                                        FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ETB ${book.price}',
                                            style: const TextStyle(
                                              color: AppColors.color4,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Published: ${book.publicationYear}',
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              color: AppColors.color4,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'No books available.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color3.withOpacity(0.7),
                    ),
                  ),
                ),

          SizedBox(height: 15),

          // Follow Button
        ],
      ),
    );
  }
}
