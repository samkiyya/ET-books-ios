import 'package:flutter/material.dart';
import 'package:book/screens/login_screen.dart';

class CustomMessageModal extends StatelessWidget {
  final String message;
  final String buttonText;
  final String type; // 'success' or 'error'
  final VoidCallback onClose; // Callback for closing the modal

  const CustomMessageModal({
    Key? key,
    required this.message,
    required this.buttonText,
    required this.type,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 24),
          type=='success'?

            ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: buttonColor, // Button background color
              onPrimary: backgroundColor, // Text color based on type
            ),
           onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(buttonText),
          ):
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: buttonColor, // Button background color
              onPrimary: backgroundColor, // Text color based on type
            ),
            onPressed: onClose,
            child: Text(buttonText),
          )



        ],
      ),
    );
  }
}
