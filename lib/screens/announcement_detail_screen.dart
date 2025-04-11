import 'package:bookreader/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/models/announcement_model.dart';
import 'package:bookreader/providers/announcement_provider.dart';
import 'package:bookreader/widgets/custom_text_field.dart';

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
      try {
        bool success =
            await Provider.of<AnnouncementProvider>(context, listen: false)
                .addComment(
          announcementId: widget.announcement.id,
          comment: _commentController.text,
        );

        if (success) {
          // Clear the text field
          _commentController.clear();
          // Refresh the comments list
          _fetchComments();
          // Notify user of success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment posted successfully')),
          );
        } else {
          // Notify user of failure
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post comment')),
          );
        }
      } catch (e) {
        // Handle unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
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
                    child: LoadingWidget(),
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
                        margin: EdgeInsets.symmetric(
                            vertical: height * 0.006, horizontal: width * 0.04),
                        elevation: 8,
                        shadowColor: AppColors.color3,
                        color: AppColors.color5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
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
                            timeAgo(comment.createdAt),
                            style: AppTextStyles.caption.copyWith(
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
