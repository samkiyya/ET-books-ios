import 'package:book_mobile/screens/book_reader_screen.dart';
import 'package:book_mobile/services/download_service.dart';
import 'package:book_mobile/services/file_services.dart';
import 'package:flutter/material.dart';

class BookService {
  static Future<void> downloadAndOpenBook(
    int bookId,
    String url,
    String bookTitle,
    BuildContext context,
    Function(double) onProgress,
  ) async {
    final path = await FileService.getBookPath(bookTitle, bookId);

    // Only download if the book doesn't exist
    if (!await FileService.isBookDownloaded(bookId, bookTitle)) {
      await DownloadService.downloadBook(url, bookId, bookTitle, onProgress);
    }

    if (context.mounted) {
      await openBook(context, bookId, bookTitle);
    }
  }

  static Future<void> openBook(
    BuildContext context,
    int bookId,
    String bookTitle,
  ) async {
    final path = await FileService.getBookPath(bookTitle, bookId);

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
    return FileService.getDownloadedBooks();
  }
}
