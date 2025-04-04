import 'package:bookreader/providers/review_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateRatingDialog extends StatefulWidget {
  final int bookId;
  final double initialRating;
  final String? initialComment;
  final int? reviewId;
  final bool isEditing;

  const UpdateRatingDialog({
    super.key,
    required this.bookId,
    required this.initialRating,
    this.initialComment,
    this.reviewId,
    this.isEditing = false,
  });

  @override
  State<UpdateRatingDialog> createState() => _UpdateRatingDialogState();
}

class _UpdateRatingDialogState extends State<UpdateRatingDialog> {
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
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
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
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: "Comment"),
          ),
          isSubmitting
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSubmitting = true;
                        });
                        try {
                          final reviewProvider = Provider.of<ReviewProvider>(
                              context,
                              listen: false);
                          await reviewProvider.updateReview(
                              widget.reviewId!,
                              widget.bookId,
                              _commentController.text,
                              _rating.toInt());

                          Navigator.pop(context);
                          Provider.of<ReviewProvider>(context, listen: false)
                              .fetchReviews(widget.bookId)
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Successuflly reviewed')));
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        } finally {
                          setState(() {
                            isSubmitting = false;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
