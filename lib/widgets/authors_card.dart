import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/author_model.dart';
import 'package:flutter/material.dart';

class AuthorCard extends StatelessWidget {
  final Author author;

  const AuthorCard({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.color5,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  '${Network.baseUrl}/${author.imageFilePath}',
                ),
              ),
              SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${author.fname} ${author.lname}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    author.bio,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color3.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${author.booksCount} Books',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color3.withOpacity(0.7),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow.shade800, size: 20),
                  SizedBox(width: 5),
                  Text(
                    author.rating.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.color3.withOpacity(0.7)),
                  ),
                ],
              ),
              Text(
                'Follower ${author.followers}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color3.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
            ),
            onPressed: () {},
            child: Center(
              child: Text(
                'Follow',
                style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.color3, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
