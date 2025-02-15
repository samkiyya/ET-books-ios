import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/review_provider.dart';
// import 'package:book_mobile/screens/update_rating_dialog_screen.dart';
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

  void _confirmDelete(BuildContext context, int reviewId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete your review?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ReviewProvider>(context, listen: false)
                  .deleteReview(reviewId, widget.bookId);
              Navigator.of(ctx).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
          Column(
            children: [
              Container(
                width: double.infinity,
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
                          'Average Rating: ${reviewProvider.averageRating.toStringAsFixed(1)}',
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
              Expanded(
                child: Consumer<ReviewProvider>(
                  builder: (context, reviewProvider, _) {
                    if (reviewProvider.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (reviewProvider.reviews.isEmpty) {
                      return const Center(
                        child: Text(
                          "No reviews for this book yet",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color3),
                          textAlign: TextAlign.center,
                        ),
                      );
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
                                    '${review.user.fname} ${review.user.lname}',
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  reviewProvider.userId == review.user.id
                                      ? Row(
                                          children: [
                                            // IconButton(
                                            //   icon: const Icon(Icons.edit,
                                            //       color: AppColors.color3,
                                            //       size: 30),
                                            //   onPressed: () {
                                            //     showModalBottomSheet(
                                            //       context: context,
                                            //       isScrollControlled: true,
                                            //       builder: (context) => Padding(
                                            //         padding: EdgeInsets.only(
                                            //           bottom:
                                            //               MediaQuery.of(context)
                                            //                   .viewInsets
                                            //                   .bottom,
                                            //         ),
                                            //         child: UpdateRatingDialog(
                                            //           bookId: widget.bookId,
                                            //           initialRating: review
                                            //               .reviewRating
                                            //               .toDouble(),
                                            //           initialComment:
                                            //               review.comment,
                                            //           reviewId: review.id,
                                            //           isEditing: true,
                                            //         ),
                                            //       ),
                                            //     );
                                            //   },
                                            // ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 30),
                                              onPressed: () => _confirmDelete(
                                                  context, review.id),
                                            ),
                                          ],
                                        )
                                      : SizedBox.shrink(),
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
