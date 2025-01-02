import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/review_provider.dart';
import 'package:book_mobile/screens/rating_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookReviewsScreen extends StatefulWidget {
  final int bookId;
  final Map<String, dynamic> book;

  const BookReviewsScreen(
      {super.key, required this.bookId, required this.book});

  @override
  State<BookReviewsScreen> createState() => _BookReviewsScreenState();
}

class _BookReviewsScreenState extends State<BookReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ReviewProvider>(context, listen: false)
        .fetchReviews(widget.bookId);
    Provider.of<ReviewProvider>(context, listen: false)
        .fetchAverageRating(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Stack(
        children: [
          // Animated Icon Background
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: Align(
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(
                    Icons.star,
                    size: 100,
                    color: Colors.yellow.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Content Section
          Column(
            children: [
              Container(
                width: double.infinity, // Ensure it spans the full width
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.color2,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book['title'] ?? 'unknown',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'BY: ${widget.book['author'] ?? "SomeOne"}',
                      style: AppTextStyles.bodyText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.book['publicationYear'].toString(),
                      style: AppTextStyles.bodyText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Consumer<ReviewProvider>(
                      builder: (context, reviewProvider, _) {
                        return Text(
                          'Average Rating: ${reviewProvider.averageRating.toStringAsFixed(1)}', // Real average rating
                          style: AppTextStyles.bodyText.copyWith(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Reviews list below the top card
              Expanded(
                child: Consumer<ReviewProvider>(
                  builder: (context, reviewProvider, _) {
                    if (reviewProvider.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: reviewProvider.reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviewProvider.reviews[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.color5,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.user.fname,
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: AppColors.color3, size: 30),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          child: RatingDialog(
                                            // Use RatingDialog here
                                            bookId: widget.bookId,
                                            initialRating:
                                                review.reviewRating.toDouble(),
                                            initialComment: review.comment,
                                            reviewId: review.id,
                                            isEditing: true,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              review.comment.isNotEmpty
                                  ? Text(
                                      review.comment,
                                      style: AppTextStyles.bodyText,
                                    )
                                  : SizedBox.shrink(),
                              const SizedBox(height: 8.0),
                              Text(
                                "Rating: ${review.reviewRating}",
                                style: AppTextStyles.bodyText.copyWith(
                                    color: AppColors.color3.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
