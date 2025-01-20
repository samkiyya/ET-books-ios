import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';


class ImageUploadHelper {
  static bool isValidImage(File image) {
    // Validate image size
    int maxSize = 10 * 1024 * 1024; // 10 MB
    if (image.lengthSync() > maxSize) {
      return false;
    }
    

    // Validate image type (extension)
    List<String> validExtensions = ['.jpeg', '.jpg', '.png', '.gif'];
    String extension = path.extension(image.path).toLowerCase();
    return validExtensions.contains(extension);
  }

  static Future<void> attachImage(File image, http.MultipartRequest request) async {
    final mimeType = lookupMimeType(image.path)!;
    if (mimeType.isEmpty) {
      throw Exception('Unsupported file type.');
    }
    final mimeSplit = mimeType.split('/');

    request.files.add(http.MultipartFile(
      'image',
      image.readAsBytes().asStream(),
      image.lengthSync(),
      filename: Uri.encodeComponent(path.basename(image.path)),
      contentType: MediaType(mimeSplit[0], mimeSplit[1]),
    ));
  }
}