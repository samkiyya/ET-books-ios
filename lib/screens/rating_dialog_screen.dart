import 'package:book_mobile/providers/review_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RatingDialog extends StatefulWidget {
  final int bookId;
  final double initialRating;
  final String? initialComment;
  final int? reviewId;
  final bool isEditing;

  const RatingDialog({
    super.key,
    required this.bookId,
    required this.initialRating,
    this.initialComment,
    this.reviewId,
    this.isEditing = false,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating;
  final _commentController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController.text = widget.initialComment ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return IconButton(
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    key: ValueKey<bool>(_rating > index),
                    color: Colors.amber,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: "Comment"),
              maxLines: null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSubmitting
              ? null
              : () async {
                  if (isSubmitting) return;
                  setState(() {
                    isSubmitting = true;
                  });

                  try {
                    final reviewProvider =
                        Provider.of<ReviewProvider>(context, listen: false);
                    await reviewProvider.addReview(
                      widget.bookId,
                      _commentController.text,
                      _rating.toInt(),
                    );

                    await reviewProvider.fetchReviews(widget.bookId);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Successfully reviewed, your review will display after moderation')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      final errorMessage =
                          e.toString().replaceFirst('Exception: ', '');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        )),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        isSubmitting = false;
                      });
                    }
                  }
                },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
