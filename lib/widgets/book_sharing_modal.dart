// import 'package:bookreader/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:bookreader/constants/styles.dart';

class BookSharingModal extends StatefulWidget {
  final Map<String, dynamic> book;
  final String appDownloadLink;

  const BookSharingModal({
    super.key,
    required this.book,
    required this.appDownloadLink,
  });

  @override
  State<BookSharingModal> createState() => _BookSharingModalState();
}

class _BookSharingModalState extends State<BookSharingModal> {
  @override
  void initState() {
    super.initState();
    _shareBookInfo(); // Automatically trigger sharing on modal load
  }

  Future<void> _shareBookInfo() async {
    final String bookInfo = """
📖 ${widget.book['title']}
👨‍💼 Author: ${widget.book['author']}
💰 Price: ${widget.book['price']} ETB
⭐ Rating: ${widget.book['rating'] ?? "Not Rated"}

🌟 Review: ${widget.book['reviews'] ?? "No Reviews"}

Download our app to explore more: ${widget.appDownloadLink}
""";

    try {
      await Share.share(bookInfo);
    } catch (e) {
      // debugPrint("Error sharing book info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // double width = AppSizes.screenWidth(context);
    return const SizedBox.shrink();

//     return Container(
//       color: AppColors.color3,
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Book Info:',
//             style: AppTextStyles.heading2
//                 .copyWith(color: AppColors.color1, fontSize: width * 0.05),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             """
// 📖 ${widget.book['title']}
// 👨‍💼 Author: ${widget.book['author']}
// 💰 Price: ${widget.book['price']} ETB
// ⭐ Rating: ${widget.book['rating'] ?? "Not Rated"}

// 🌟 Review: ${widget.book['reviews'] ?? "No Reviews"}
// """,
//             style: AppTextStyles.bodyText,
//           ),
//         ],
//       ),
//     );
  }
}
