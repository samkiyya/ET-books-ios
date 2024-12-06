import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/announcement_provider.dart';
import 'package:book_mobile/screens/announcement_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AnnouncementProvider>(context, listen: false)
            .fetchAnnouncements());
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.color6,
          ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.color6,
        backgroundColor: AppColors.color1,
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.color3),
            ));
          }

          // if (provider.error != null) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     _showErrorSnackBar(provider.error!);
          //   });
          // }

          return ListView.builder(
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = provider.announcements[index];
              return Card(
                margin: const EdgeInsets.all(8),
                color: AppColors.color1,
                child: ListTile(
                  title: Text(announcement.title,
                      style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.color6,
                          fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.content, style: AppTextStyles.bodyText),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              size: 16, color: AppColors.color3),
                          const SizedBox(width: 4),
                          Text('${announcement.commentsCount} comments',
                              style: AppTextStyles.bodyText
                                  .copyWith(color: AppColors.color6)),
                          const SizedBox(width: 16),
                          IconButton(
                            color: !announcement.isLiked
                                ? Colors.blue
                                : Colors.grey,
                            onPressed: () async {
                              try {
                                await Provider.of<AnnouncementProvider>(context,
                                        listen: false)
                                    .likeAnnouncement(
                                  announcement.id,
                                );
                              } catch (e) {
                                if (provider.error != null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _showErrorSnackBar(provider.error!);
                                  });
                                }
                              }
                            },
                            icon: Icon(
                              Icons.thumb_up,
                              size: 16,
                              color: !announcement.isLiked
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('${announcement.likesCount} likes',
                              style: AppTextStyles.bodyText
                                  .copyWith(color: AppColors.color6)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementDetailScreen(
                          announcement: announcement,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
