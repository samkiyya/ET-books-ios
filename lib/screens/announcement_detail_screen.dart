import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/announcement_model.dart';
import 'package:book_mobile/providers/announcement_provider.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() {
    Provider.of<AnnouncementProvider>(context, listen: false)
        .fetchComments(widget.announcement.id);
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await Provider.of<AnnouncementProvider>(context, listen: false)
          .addComment(
        announcementId: widget.announcement.id,
        comment: _commentController.text,
      );
      _commentController.clear();
      _fetchComments(); // Refresh comments after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.announcement.title,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.color6,
          ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.color6,
        backgroundColor: AppColors.color1,
      ),
      body: Column(
        children: [
          // Static Announcement Details
          Card(
            color: AppColors.color1,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.announcement.title,
                    style: AppTextStyles.heading2
                        .copyWith(color: AppColors.color6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.announcement.content,
                    style: AppTextStyles.bodyText,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${widget.announcement.likesCount} likes',
                        style: AppTextStyles.bodyText
                            .copyWith(color: AppColors.color6),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.announcement.commentsCount} comments',
                        style: AppTextStyles.bodyText
                            .copyWith(color: AppColors.color6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1),
          // Comments Section
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, provider, child) {
                final comments = provider.getComments(widget.announcement.id);
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                } else if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'You can be the first to comment!',
                      style: AppTextStyles.bodyText,
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Card(
                        color: AppColors.color1,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              'U${comment.userId}',
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                          title: Text(
                            comment.comment,
                            style: AppTextStyles.bodyText,
                          ),
                          subtitle: Text(
                            'Posted on ${comment.createdAt.toString().split('.')[0]}',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.color6,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Comment Input Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _commentController,
                    hintText: 'Add a comment...',
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.color3,
                    backgroundColor: AppColors.color2,
                    elevation: 10,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.00585585,
                      horizontal: width * 0.024074,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: AppColors.color3.withOpacity(0.6),
                  ),
                  child: Text(
                    'Post',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.color3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
