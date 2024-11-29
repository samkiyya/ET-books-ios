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
    return AlertDialog(
      title: const Text('Downloading...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
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
