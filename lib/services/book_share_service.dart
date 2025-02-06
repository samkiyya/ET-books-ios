import 'package:share_plus/share_plus.dart';

class BookSharing {
  static Future<void> shareBookInfo({
    required Map<String, dynamic> book,
    required String appDownloadLink,
  }) async {
    final String bookInfo = """
📖 ${book['title']}
👨‍💼 Author: ${book['author']}
💰 Price: ${book['price']} ETB
⭐ Rating: ${book['rating'] ?? "Not Rated"}

🌟 Review: ${book['reviews'] ?? "No Reviews"}

Download our app to explore more: $appDownloadLink
""";

    try {
      await Share.share(bookInfo);
    } catch (e) {
      // debugPrint("Error sharing book info: $e");
    }
  }
}
