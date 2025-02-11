import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../constants/constants.dart';

class AudioPlayerHeader extends StatelessWidget {
  final String title;
  final String imagePath;

  const AudioPlayerHeader({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        AppBar(
          title: Text(
            title,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                "${Network.baseUrl}/$imagePath",
                width: width * 0.8,
                height: height * 0.3,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    size: width * 0.2,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
