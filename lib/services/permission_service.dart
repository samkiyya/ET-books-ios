import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission{
  Future<void> initializePermissions(BuildContext context) async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        // Show an alert dialog when permission is denied
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
      } else if (status.isPermanentlyDenied) {
        // Show an alert dialog when permission is permanently denied
        if (context.mounted) {
          _showPermissionPermanentlyDeniedDialog(context);
        }
      }
    }
  }
}

// Function to show a dialog when the notification permission is denied
void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Notification Permission Denied'),
        content: Text(
            'The app needs notification permissions to keep you informed. Please allow notifications in your settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

// Function to show a dialog when the notification permission is permanently denied
void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Notification Permission Permanently Denied'),
        content: Text(
            'You have permanently denied the notification permission. Please go to your device settings and enable notifications for this app.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
}
