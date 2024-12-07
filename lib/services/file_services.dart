import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> getBookPath(String bookName, int bookId) async {
    final directory = await getApplicationDocumentsDirectory();

    return '${directory.path}/${bookName}_$bookId.pdf';
  }

  static Future<bool> isBookDownloaded(int bookId, String bookName) async {
    final path = await getBookPath(bookName, bookId);
    return File(path).existsSync();
  }

  static Future<List<Map<String, dynamic>>> getDownloadedBooks() async {
    final directory = await getApplicationDocumentsDirectory();
    final files =
        directory.listSync().where((file) => file.path.endsWith('.pdf'));
    return files.map((file) {
      final id = int.parse(file.path.split('_').last.split('.').first);
      final fileName = file.path.split('/').last;
      final cleanName = fileName.split('_').first;
      return {'id': id, 'title': cleanName, 'path': file.path};
    }).toList();
  }

  static Future<bool> deleteBook(int bookId, String bookName) async {
    try {
      final path = await getBookPath(bookName, bookId);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting book: $e');
    }
    return false;
  }
}
