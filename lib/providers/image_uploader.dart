import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class ImageUploader {
  /// Validate the image size and type
  static bool validateImage(File image, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;

    // Validate file size
    if (image.lengthSync() > maxSizeBytes) {
      return false;
    }

    // Validate file type
    final mimeType = lookupMimeType(image.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      return false;
    }

    return true;
  }

  /// Upload the image to the specified URL
  static Future<http.StreamedResponse?> uploadImage({
    required File image,
    required Uri uploadUrl,
    required Map<String, String> headers,
    String fileFieldName = 'file',
  }) async {
    final mimeType = lookupMimeType(image.path);
    if (mimeType == null) {
      throw Exception('Unsupported file type.');
    }

    final mimeSplit = mimeType.split('/');

    final request = http.MultipartRequest('POST', uploadUrl)
      ..headers.addAll(headers)
      ..files.add(http.MultipartFile(
        fileFieldName,
        image.readAsBytes().asStream(),
        image.lengthSync(),
        filename: Uri.encodeComponent(path.basename(image.path)),
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ));

    return await request.send();
  }
}
