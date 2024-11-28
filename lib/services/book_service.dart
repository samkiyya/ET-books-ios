import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:book_mobile/screens/book_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class BookService {
  static const secureStorage = FlutterSecureStorage();

  static Future<String> getOrCreateEncryptionKey() async {
    const key = 'AbyssiniaSoftwareSolutionsEncryptionKey';
    var encryptionKey = await secureStorage.read(key: key);

    if (encryptionKey == null) {
      encryptionKey = generateSecureKey(length: 32); // Generate a 32-byte key
      await secureStorage.write(key: key, value: encryptionKey);
    }

    return encryptionKey;
  }

  static String generateSecureKey({int length = 32}) {
    final random = Random.secure();
    final keyBytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(keyBytes);
  }

  static Future<String> getBookPath(int bookId) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/book_$bookId.pdf';
  }

  static Future<bool> isBookDownloaded(int bookId) async {
    final path = await getBookPath(bookId);
    return File(path).existsSync();
  }

  static Future<void> downloadBook(
      int bookId, String url, BuildContext context) async {
    final path = await getBookPath(bookId);
    final dio = Dio();

    double progress = 0.0; // Track download progress

    // Show a dialog with a progress indicator
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  onPressed: () {
                    Navigator.of(context).pop(); // Allow cancellation
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    // Perform the download
    await dio.download(url, path, onReceiveProgress: (received, total) {
      if (total != 0) {
        progress = received / total;
        // Update the progress in the dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Ensure UI updates are applied
          (context as Element).markNeedsBuild();
        });
      }
    });

    // Close the dialog when download completes
    Navigator.of(context).pop();
  }

  static Future<List<Map<String, dynamic>>> getDownloadedBooks() async {
    final directory = await getApplicationDocumentsDirectory();
    final files =
        directory.listSync().where((file) => file.path.endsWith('.pdf'));
    return files.map((file) {
      final id = int.parse(file.path.split('_').last.split('.').first);
      return {'id': id, 'title': 'Book $id', 'path': file.path};
    }).toList();
  }

  static Future<void> openBook(
      BuildContext context, int bookId, String bookTitle) async {
    final path = await getBookPath(bookId);

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
