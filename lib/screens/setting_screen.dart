import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/providers/notification_provider.dart';
import 'package:bookreader/providers/auth_provider.dart';
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
              .copyWith(fontSize: width * 0.05, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications toggle
            SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: AppTextStyles.buttonText
                    .copyWith(fontSize: width * 0.045, color: AppColors.color3),
              ),
              value: context.watch<NotificationProvider>().notificationsEnabled,
              onChanged: (value) {
                context.read<NotificationProvider>().toggleNotifications();

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
            Divider(height: height * 0.04, color: AppColors.color3),

            // Two-Factor Authentication (2FA) toggle
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SwitchListTile(
                  title: Text(
                    'Enable Two-Factor Authentication (2FA)',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: width * 0.045,
                      color: AppColors.color3,
                    ),
                  ),
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
                  secondary: authProvider.isLoading &&
                          authProvider.is2FAEnabled == false
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : null,
                );
              },
            ),
            Text(
              context.watch<AuthProvider>().is2FAEnabled
                  ? 'Two-Factor Authentication (2FA) is currently enabled.'
                  : 'Two-Factor Authentication (2FA) is currently disabled.',
              style: TextStyle(
                fontSize: width * 0.042,
                fontWeight: FontWeight.w500,
                color: AppColors.color6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
