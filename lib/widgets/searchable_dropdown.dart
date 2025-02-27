import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:animated_dropdown_search_codespark/animated_dropdown_search_codespark.dart';

class CoustomSearchableDropdown extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final List<String> data;
  final String? hintText;

  const CoustomSearchableDropdown(
      {super.key, required this.onChanged, required this.data, this.hintText});

  @override
  State<CoustomSearchableDropdown> createState() =>
      _CoustomSearchableDropdownState();
}

class _CoustomSearchableDropdownState extends State<CoustomSearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    // double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return AnimatedDropdownSearch(
      data: widget.data, // Use the imported country list
      onSelected: (value) => widget.onChanged(value),
      hint: widget.hintText ?? 'Select Country',
      enableSearch: true,

      enableAdaptivePositioning: true,
      shouldHighlightMatchedText: true,
      matchedTextHighlightColor: AppColors.color1,
      selectedHighlightColor: AppColors.color2,
      maxHeightForOptions: height / 3,
      scrollPercentageColorIndicator: Colors.green,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.color1),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
