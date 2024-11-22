import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';

class AnimatedSearchTextField extends StatefulWidget {
  final Function(String) onChanged;
  const AnimatedSearchTextField({super.key, required this.onChanged});

  @override
  State<AnimatedSearchTextField> createState() =>
      _AnimatedSearchTextFieldState();
}

class _AnimatedSearchTextFieldState extends State<AnimatedSearchTextField> {
  bool opened = false;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
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
        width: opened ? MediaQuery.of(context).size.width * .9 : 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: AppColors.color6,
          boxShadow: kElevationToShadow[2],
        ),
        child: Row(
          children: [
            if (opened) // Only render Expanded when opened is true
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
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
                    decoration: const InputDecoration(
                      hintText: 'Search',
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
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    opened ? Icons.close : Icons.search,
                    color: AppColors.color1,
                    size: 20,
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
