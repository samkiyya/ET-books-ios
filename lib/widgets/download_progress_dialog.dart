import 'package:book_mobile/constants/size.dart';
import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatelessWidget {
  final double progress;
  final VoidCallback onCancel;

  const DownloadProgressDialog({
    super.key,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return AlertDialog(
      title: const Text('Downloading...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          SizedBox(height: height * 0.0072072),
          Text('${(progress * 100).toStringAsFixed(0)}%'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
