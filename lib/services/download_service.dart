import 'package:book_mobile/services/file_services.dart';
import 'package:dio/dio.dart';

class DownloadService {
  static final _dio = Dio();

  static Future<void> downloadBook(
    String url,
    int bookId,
    String bookTitle,
    Function(double) onProgress,
  ) async {
    final path = await FileService.getBookPath(bookTitle, bookId);

    try {
      await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );
    } catch (e) {
      print('Error downloading episode: $e');
    }
  }
}
