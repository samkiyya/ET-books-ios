import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationDetailScreen extends StatelessWidget {
  final int notificationIndex;

  const NotificationDetailScreen({super.key, required this.notificationIndex});

  @override
  Widget build(BuildContext context) {
    final notification =
        context.watch<NotificationProvider>().notifications[notificationIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification['title'] ?? 'Notification Details',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['body'] ?? 'No details available',
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
