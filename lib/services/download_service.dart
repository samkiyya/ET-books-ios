import 'package:book_mobile/widgets/download_progress_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DownloadService {
  static final _dio = Dio();

  static Future<bool> downloadBook(
    String url,
    String path,
    BuildContext context,
  ) async {
    bool downloadCompleted = false;
    double progress = 0.0;
    CancelToken cancelToken = CancelToken();

    // Create a dialog controller to manage the dialog state
    final dialogController = ValueNotifier<double>(0.0);

    // Show the progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<double>(
          valueListenable: dialogController,
          builder: (context, value, child) {
            return DownloadProgressDialog(
              progress: value,
              onCancel: () {
                cancelToken.cancel();
                Navigator.of(dialogContext).pop();
              },
            );
          },
        );
      },
    );

    try {
      await _dio.download(
        url,
        path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progress = received / total;
            dialogController.value = progress;
          }
        },
      );
      downloadCompleted = true;
    } catch (e) {
      debugPrint('Download error: $e');
      downloadCompleted = false;
    } finally {
      // Close the dialog if it's still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      dialogController.dispose();
    }

    return downloadCompleted;
  }
}
