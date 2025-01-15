import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/notification_provider.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.heading2
              .copyWith(fontSize: width * 0.5, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Switch to toggle notifications
            SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: AppTextStyles.buttonText
                    .copyWith(fontSize: width * 0.045, color: AppColors.color3),
              ),
              value: context.watch<NotificationProvider>().notificationsEnabled,
              onChanged: (value) {
                // Toggle notifications in the provider
                context.read<NotificationProvider>().toggleNotifications();

                // Show a Snackbar with feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notifications have been enabled.'
                          : 'Notifications have been disabled.',
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: height * 0.007),
            // Display the current status of notifications
            Text(
              context.watch<NotificationProvider>().notificationsEnabled
                  ? 'Notifications are currently enabled.'
                  : 'Notifications are currently disabled.',
              style: TextStyle(
                fontSize: width * 0.042,
                fontWeight: FontWeight.w500,
                color: AppColors.color6,
              ),
            ),
            SizedBox(height: height * 0.02),
            // Toggle Two-Factor Authentication (2FA)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ListTile(
                  title: Text(
                    'Enable Two-Factor Authentication (2FA)',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: width * 0.045,
                      color: AppColors.color3,
                    ),
                  ),
                  trailing: authProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Switch(
                          value: authProvider.is2FAEnabled,
                          onChanged: (value) async {
                            try {
                              await authProvider.toggle2FA();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? '2FA has been enabled.'
                                        : '2FA has been disabled.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${e.toString()}',
                                    style: const TextStyle(
                                      color: AppColors.color3,
                                    ),
                                  ),
                                  backgroundColor: AppColors.color5,
                                ),
                              );
                            }
                          },
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
