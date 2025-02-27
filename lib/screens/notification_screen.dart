import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/providers/notification_provider.dart';
import 'package:bookreader/screens/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.color6,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          // Check if the list of notifications is empty
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications available.',
                style: AppTextStyles.bodyText,
              ),
            );
          }

          // Display list of notifications, latest first
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Slidable(
                key: ValueKey(notification['id']),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        // Mark as read/unread
                        provider.toggleReadStatus(notification['id']);
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: notification['isRead']
                          ? Icons.mark_as_unread
                          : Icons.mark_email_read,
                      label: notification['isRead']
                          ? 'Mark as Unread'
                          : 'Mark as Read',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        // Delete notification
                        await provider.deleteNotification(notification['id']);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(
                      vertical: height * 0.009, horizontal: width * 0.03),
                  color: AppColors.color5,
                  shadowColor: AppColors.color3,
                  elevation: 8,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: height * 0.009, horizontal: width * 0.03),
                    leading: Icon(
                      notification['isRead']
                          ? Icons.notifications_none
                          : Icons.notifications,
                      color: notification['isRead']
                          ? AppColors.color3
                          : Colors.blue,
                    ),
                    title: Text(
                      notification['title'] ?? 'No Title',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.color3,
                        fontSize: width * 0.05,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notification['body'] ?? 'No Body',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.color3,
                        fontSize: width * 0.04,
                        letterSpacing: 0.5,
                      ),
                    ),
                    tileColor: notification['isRead']
                        ? AppColors.color5
                        : AppColors.color2,
                    onTap: () {
                      // Automatically mark as read and navigate to detail screen
                      if (!notification['isRead']) {
                        provider.toggleReadStatus(notification['id']);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationDetailScreen(
                            notificationId: notification['id'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
