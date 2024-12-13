import 'package:book_mobile/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/constants/constants.dart';

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
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final String bookInfo = """
📖 ${widget.book['title']}
👨‍💼 Author: ${widget.book['author']}
💰 Price: ${widget.book['price']} ETB
⭐ Rating: ${widget.book['rating'] ?? "Not Rated"}

🌟 Review: ${widget.book['reviews'] ?? "No Reviews"}

Download our app to explore more: ${widget.appDownloadLink}
""";

    return Container(
      color: AppColors.color3,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share Book Info with Friends via:',
            style: AppTextStyles.heading2
                .copyWith(color: AppColors.color1, fontSize: width * 0.05),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareButton(
                FontAwesomeIcons.telegram,
                Colors.blue,
                () => _shareToTelegram(bookInfo),
              ),
              _buildShareButton(
                FontAwesomeIcons.facebook,
                Colors.blue,
                () => _shareToFacebook(bookInfo),
              ),
              _buildShareButton(
                FontAwesomeIcons.whatsapp,
                Colors.green,
                () => _shareToWhatsApp(bookInfo),
              ),
              _buildShareButton(
                Icons.sms,
                Colors.orange,
                () => _shareToSMS(bookInfo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: FaIcon(icon, color: color, size: 40),
      onPressed: onTap,
    );
  }

  Future<void> _shareToTelegram(String text) async {
    final Uri telegramUri =
        Uri.parse("https://t.me/share/url?url=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(telegramUri)) {
      await launchUrl(telegramUri);
    } else {
      _showError("Telegram is not installed or cannot be opened.");
    }
  }

  Future<void> _shareToFacebook(String text) async {
    final Uri facebookUri = Uri.parse(
        "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(facebookUri)) {
      await launchUrl(facebookUri);
    } else {
      _showError("Facebook cannot be opened.");
    }
  }

  Future<void> _shareToWhatsApp(String text) async {
    final Uri whatsappUri =
        Uri.parse("whatsapp://send?text=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showError("WhatsApp is not installed or cannot be opened.");
    }
  }

  Future<void> _shareToSMS(String text) async {
    final Uri smsUri = Uri.parse("sms:?body=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      _showError("SMS cannot be opened.");
    }
  }

  void _showError(String message) {
    debugPrint(message);
  }
}
