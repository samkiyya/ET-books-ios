import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> getBookPath(String bookName, int bookId,
      {String? fileExtension}) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${bookName}_$bookId${fileExtension ?? ''}';
  }

  static Future<bool> isBookDownloaded(int bookId, String bookName) async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((file) => file.path.contains('${bookName}_$bookId.'));
    return files.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getDownloadedBooks() async {
    final directory = await getApplicationDocumentsDirectory();

    final files = directory
        .listSync()
        .where((file) => file.path.endsWith('.pdf') ||
            file.path.endsWith('.docx') ||
            file.path.endsWith('.epub'));

    return files.map((file) {
      final parts = file.path.split('_');
      final id = int.parse(parts.last.split('.').first);
      final fileName = file.path.split('/').last;
      final cleanName = fileName.split('_').first;
      final extension = file.path.split('.').last;
      return {
        'id': id,
        'title': cleanName,
        'path': file.path,
        'extension': '.$extension',
      };
    }).toList();
  }

  static Future<bool> deleteBook(
      int bookId, String bookName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((file) => file.path.contains('${bookName}_$bookId.'));
      for (var file in files) {
        await file.delete();
      }
      return true;
    } catch (e) {
      // print('Error deleting book: $e');
    }
    return false;
  }

  static String fileSizeAsString(File file) {
    final fileSize = file.lengthSync();
    String size = (fileSize / 1024).toStringAsFixed(2);
    if (fileSize > 1024 * 1024) {
      size = '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      size = '$size KB';
    }
    return size;
  }
}
