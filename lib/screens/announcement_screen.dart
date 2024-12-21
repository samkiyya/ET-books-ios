import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/announcement_provider.dart';
import 'package:book_mobile/screens/announcement_detail_screen.dart';
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
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return SafeArea(
      child: Scaffold(
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
        body:
            Consumer<AnnouncementProvider>(builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.color3),
            ));
          }
          if (provider.announcements.isEmpty) {
            return Center(
              child: Text(
                'No announcements available',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.color3,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.05,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = provider.announcements[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: width * 0.03,
                  right: width * 0.03,
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(
                      vertical: height * 0.009, horizontal: width * 0.03),
                  color: AppColors.color5,
                  shadowColor: AppColors.color3,
                  elevation: 8,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03, vertical: height * 0.007),
                    title: Text(
                      announcement.title,
                      style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.color6, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display image if exists
                        if (announcement.imageUrl != null &&
                            announcement.imageUrl!.isNotEmpty &&
                            (announcement.videoUrl == null ||
                                announcement.videoUrl!.isEmpty))
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.01),
                            child: Container(
                              width: double.infinity,
                              height: height * 0.25,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${Network.baseUrl}/${announcement.imageUrl!}'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                        // Display video thumbnail if exists
                        if (announcement.videoUrl != null &&
                            announcement.videoUrl!.isNotEmpty)
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.01),
                            child: GestureDetector(
                              onTap: () {
                                // Open video in a new screen or video player
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerScreen(
                                      videoUrl:
                                          '${Network.baseUrl}/${announcement.videoUrl!}',
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: height * 0.25,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            '${Network.baseUrl}/${announcement.imageUrl!}'),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.play_circle_fill,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        SizedBox(height: height * 0.01),
                        Text(
                          announcement.content,
                          style: AppTextStyles.bodyText,
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          children: [
                            // Comment Button with a count
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnnouncementDetailScreen(
                                      announcement: announcement,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                iconColor: AppColors.color2,
                                minimumSize: const Size(50, 30),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: AppColors.color2,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${announcement.commentsCount}',
                                    style: AppTextStyles.bodyText
                                        .copyWith(color: AppColors.color2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: width * 0.04),

                            // Like Button with like functionality
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await Provider.of<AnnouncementProvider>(
                                    context,
                                    listen: false,
                                  ).likeAnnouncement(announcement.id);
                                } catch (e) {
                                  if (provider.error != null) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                      (_) {
                                        _showErrorSnackBar(provider.error!);
                                      },
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                iconColor: announcement.isLiked
                                    ? Colors.blue
                                    : AppColors.color2,
                                minimumSize: const Size(50, 30),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 18,
                                    color: announcement.isLiked
                                        ? Colors.blue
                                        : AppColors.color2,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${announcement.likesCount}',
                                    style: AppTextStyles.bodyText
                                        .copyWith(color: AppColors.color2),
                                  ),
                                ],
                              ),
                            ),
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
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
