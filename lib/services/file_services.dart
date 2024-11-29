import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> getBookPath(int bookId) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/book_$bookId.pdf';
  }

  static Future<bool> isBookDownloaded(int bookId) async {
    final path = await getBookPath(bookId);
    return File(path).existsSync();
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
}
