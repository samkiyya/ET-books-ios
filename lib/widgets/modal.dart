import 'package:bookreader/constants/size.dart';
import 'package:flutter/material.dart';

class CustomMessageModal extends StatelessWidget {
  final String message;
  final String buttonText;
  final String type; // 'success' or 'error'
  final VoidCallback onClose; // Callback for closing the modal
  final VoidCallback? onSuccess; // Optional Callback for success

  const CustomMessageModal({
    super.key,
    required this.message,
    required this.buttonText,
    required this.type,
    required this.onClose,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    // Determine colors based on the type
    Color backgroundColor = type == 'success' ? Colors.green : Colors.red;
    Color buttonColor = Colors.white;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == 'success' ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: width * 0.09,
          ),
          SizedBox(height: height * 0.03),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: width * 0.045),
          ),
          SizedBox(height: height * 0.03),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: backgroundColor,
              backgroundColor: buttonColor, // Text color based on type
            ),
            onPressed: type == 'success'
                ? (onSuccess ??
                    onClose) // Use onSuccess if provided, else fallback to onClose
                : onClose,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
