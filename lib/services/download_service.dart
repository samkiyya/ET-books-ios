import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'file_services.dart';

class DownloadService {
  static final _dio = Dio();

  static Future<void> downloadBook(
    String url,
    int bookId,
    String bookTitle,
    Function(double) onProgress,
  ) async {
    String fileExtension = '.docx'; // Default extension
    try {
      // Send HEAD request to determine file type
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null) {
          if (contentType.contains('pdf')) {
            fileExtension = '.pdf';
          } else if (contentType.contains('epub')) {
            fileExtension = '.epub';
          } else if (contentType.contains('msword') ||
              contentType.contains('docx')) {
            fileExtension = '.docx';
          }
        } else {
          // print('Failed to determine file type, using default extension.');
        }
      } else {
        throw HttpException(
          'Failed to fetch file type. Status code: ${response.statusCode}',
        );
      }

      // Get the appropriate file path based on file type
      final path = await FileService.getBookPath(bookTitle, bookId,
          fileExtension: fileExtension);

      // Download the file
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
      // print('File downloaded successfully to $path');
    } on DioError catch (dioError) {
      if (dioError.response?.statusCode == 404) {
        // print(
        //     'Error: The requested URL is not found (404). Please check the URL: $url');
      } else {
        // print('Dio error occurred: ${dioError.message}');
      }
    } on HttpException {
      rethrow;
      // print('HTTP error: ${httpError.message}');
    } catch (e) {
      // print('An unexpected error occurred: $e');
    }
  }
}
