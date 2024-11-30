// import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/notification_provider.dart';
import 'package:flutter/material.dart';
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
    Provider.of<NotificationProvider>(context, listen: false)
        .loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // double width = AppSizes.screenWidth(context);
    // double height = AppSizes.screenHeight(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.color6,
            )),
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

              return ListTile(
                leading: Icon(
                  notification['isRead']
                      ? Icons.notifications_none
                      : Icons.notifications,
                  color:
                      notification['isRead'] ? AppColors.color3 : Colors.blue,
                ),
                title: Text(notification['title']),
                subtitle: Text(notification['body']),
                onTap: () {
                  // Mark as read when tapped
                  provider.toggleReadStatus(index);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Delete notification
                    await provider.deleteNotification(notification['id']);
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
