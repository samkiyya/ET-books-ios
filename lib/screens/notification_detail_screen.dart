import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationDetailScreen extends StatelessWidget {
  final int notificationId; // Integer ID from API response

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final notification = provider.notifications.firstWhere(
      (notif) => notif['id'] == notificationId,
      orElse: () => {'title': 'Unknown', 'body': 'No details available'},
    );

    // Automatically mark as read if not already read
    if (!notification['isRead']) {
      provider.toggleReadStatus(notificationId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification['title'] ?? 'Notification Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: SingleChildScrollView(
          child: Card(
            elevation: 12.0,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: AppColors.color5,
            child: Padding(
              padding: EdgeInsets.all(width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      notification['title'] ?? 'No title available',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: width * 0.055,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1.0,
                  ),
                  SizedBox(height: height * 0.015),
                  // Body
                  Text(
                    notification['body'] ?? 'No details available',
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: width * 0.04,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  // Divider
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1.0,
                  ),
                  SizedBox(height: height * 0.02),
                  // Delete Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this notification?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // User chose 'No'
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(true); // User chose 'Yes'
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );

                      // If user confirms the deletion
                      if (shouldDelete == true) {
                        await provider.deleteNotification(notificationId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification deleted.')),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.1, vertical: height * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
