import 'package:bookreader/screens/book_reader_screen.dart';
import 'package:bookreader/services/download_service.dart';
import 'package:bookreader/services/file_services.dart';
import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class BookService {
  // static final _dio = Dio();

  static Future<void> downloadAndOpenBook(
    int bookId,
    String url,
    String bookTitle,
    BuildContext context,
    Function(double) onProgress,
  ) async {
    // Determine file extension dynamically before download
    String fileExtension = await getFileExtension(url);

    // Get the file path based on the determined file extension
    await FileService.getBookPath(
      bookTitle,
      bookId,
    );

    // Only download if the book doesn't exist
    if (!await FileService.isBookDownloaded(bookId, bookTitle)) {
      await DownloadService.downloadBook(
        url,
        bookId,
        bookTitle,
        onProgress,
      );
    }

    // Open the book after downloading
    if (context.mounted) {
      await openBook(context, bookId, bookTitle, fileExtension);
    }
  }

  static Future<void> openBook(
    BuildContext context,
    int bookId,
    String bookTitle,
    String fileExtension,
  ) async {
    final path = await FileService.getBookPath(bookTitle, bookId,
        fileExtension: fileExtension);
    // print('file extension to open: $fileExtension');

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookReaderScreen(
            bookId: bookId,
            bookTitle: bookTitle,
            filePath: path,
          ),
        ),
      );
    }
  }

  static Future<bool> isBookDownloaded(int bookId, String bookName) async {
    return FileService.isBookDownloaded(bookId, bookName);
  }

  static Future<List<Map<String, dynamic>>> getDownloadedBooks() async {
    // print('full name  from downloaded: ${FileService.getDownloadedBooks()}');
    return FileService.getDownloadedBooks();
  }

  // Helper method to determine file extension
  static Future<String> getFileExtension(String url) async {
    String fileExtension = '.docx'; // Default fallback
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        final guessedExtension = uri.pathSegments.last.split('.').last;
        if (['pdf', 'epub', 'docx'].contains(guessedExtension)) {
          return '.$guessedExtension';
        }
      }

      // Fallback to HTTP HEAD check
      final response = await http.head(uri);
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null) {
          if (contentType.contains('pdf')) {
            return '.pdf';
          } else if (contentType.contains('epub')) {
            return '.epub';
          } else if (contentType.contains('msword') ||
              contentType.contains('docx')) {
            return '.docx';
          }
        }
      }
    } catch (e) {
      // print('Error determining file type: $e');
    }
    return fileExtension;
  }
}
