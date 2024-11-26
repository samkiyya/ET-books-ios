import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SwitchListTile(
        title: const Text('Enable Notifications'),
        value: context.watch<NotificationProvider>().notificationsEnabled,
        onChanged: (value) {
          // Toggle notifications in the provider
          context.read<NotificationProvider>().toggleNotifications();
        },
      ),
    );
  }
}
