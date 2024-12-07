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
  ) async {
    final path = await FileService.getBookPath(bookTitle, bookId);

    // Only download if the book doesn't exist
    if (!await FileService.isBookDownloaded(bookId, bookTitle)) {
      final success = await DownloadService.downloadBook(url, path, context);
      if (!success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download failed. Please try again.')),
          );
        }
        return;
      }
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
            bookTitle: bookTitle,
            pdfPath: path,
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
