import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationDetailScreen extends StatelessWidget {
  final int notificationIndex;

  const NotificationDetailScreen({super.key, required this.notificationIndex});

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final notification =
        context.watch<NotificationProvider>().notifications[notificationIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification['title'] ?? 'Notification Details',
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.0148148, vertical: height * 0.0072072),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['body'] ?? 'No details available',
              style: TextStyle(
                  fontSize: width * 0.016666, height: height * 0.00067567),
            ),
            SizedBox(height: height * 0.009),
            ElevatedButton.icon(
              onPressed: () {
                // Toggle the read/unread status when clicked
                context
                    .read<NotificationProvider>()
                    .toggleReadStatus(notificationIndex);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(notification['isRead']
                        ? 'Marked as Unread'
                        : 'Marked as Read'),
                  ),
                );
              },
              icon: Icon(
                  notification['isRead'] ? Icons.markunread : Icons.drafts),
              label: Text(
                notification['isRead'] ? 'Mark as Unread' : 'Mark as Read',
              ),
            ),
            SizedBox(height: height * 0.009),
            ElevatedButton.icon(
              onPressed: () async {
                // Delete the notification
                await context
                    .read<NotificationProvider>()
                    .deleteNotification(notification['id']);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification deleted.')),
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
