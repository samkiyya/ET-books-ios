import 'package:book_mobile/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:book_mobile/constants/styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final IconData? prefixIcon;
  final IconButton? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.labelText,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.color3,
            ),
          ),
        SizedBox(height: height * 0.01),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.color1)
                : null,
            labelStyle: const TextStyle(color: AppColors.color3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: AppColors.color5,
            suffixIcon:
                icon != null ? Icon(icon, color: AppColors.color1) : suffixIcon,
            labelText: labelText,
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.color1),
          ),
          validator: validator,
        ),
        SizedBox(height: height * 0.02),
      ],
    );
  }
}
