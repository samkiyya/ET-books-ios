import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';

class AnimatedSearchTextField extends StatefulWidget {
  final Function(String) onChanged;
  final String? customHint; // Ensure this is marked as final

  const AnimatedSearchTextField({
    super.key,
    required this.onChanged,
    this.customHint,
  });

  @override
  State<AnimatedSearchTextField> createState() =>
      _AnimatedSearchTextFieldState();
}

class _AnimatedSearchTextFieldState extends State<AnimatedSearchTextField> {
  bool opened = false;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return GestureDetector(
      onTap: () {
        if (!opened) {
          setState(() {
            opened = true; // Open when tapping anywhere on the container
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: opened ? width * .9 : width * 0.3,
        height: height * .07,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: AppColors.color6,
          boxShadow: kElevationToShadow[2],
        ),
        child: Row(
          children: [
            if (opened)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: width * 0.03),
                  child: TextField(
                    onChanged: (value) {
                      widget.onChanged(value);
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        opened = false;
                      });
                    },
                    style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.color1, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: widget.customHint ?? 'Search...',
                      hintStyle: TextStyle(color: AppColors.color1),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: opened
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(32),
                      )
                    : const BorderRadius.all(Radius.circular(32)),
                onTap: () {
                  setState(() {
                    opened = !opened; // Toggle open state when tapping the icon
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.06, vertical: height * 0.01),
                  child: Icon(
                    opened ? Icons.close : Icons.search,
                    color: AppColors.color1,
                    size: width * 0.06,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
