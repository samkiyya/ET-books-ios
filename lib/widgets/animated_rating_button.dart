import 'package:flutter/material.dart';
import 'package:bookreader/screens/rating_dialog_screen.dart';

class AnimatedRatingButton extends StatefulWidget {
  final int bookId;
  final int initialRating;

  const AnimatedRatingButton({
    super.key,
    required this.bookId,
    required this.initialRating,
  });

  @override
  State<AnimatedRatingButton> createState() => _AnimatedRatingButtonState();
}

class _AnimatedRatingButtonState extends State<AnimatedRatingButton> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    // Initialize _rating based on the initialRating passed to the widget
    _rating = widget.initialRating.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          iconSize: 40,
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
            // Show the rating dialog with the updated rating
            showDialog(
              context: context,
              builder: (context) => RatingDialog(
                bookId: widget.bookId,
                initialRating: _rating,
              ),
            );
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
    );
  }
}
