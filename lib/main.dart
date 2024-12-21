import 'dart:io';

import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/announcement_provider.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/providers/author_provider.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/providers/login_provider.dart';
import 'package:book_mobile/providers/notification_provider.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:book_mobile/providers/profile_provider.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/providers/signup_provider.dart';
import 'package:book_mobile/providers/subscription_provider.dart';
import 'package:book_mobile/providers/subscription_tiers_provider.dart';
import 'package:book_mobile/providers/update_profile_provider.dart';

import 'package:book_mobile/screens/all_audio_screen.dart';
import 'package:book_mobile/screens/all_book_screen.dart';
import 'package:book_mobile/screens/announcement_screen.dart';
import 'package:book_mobile/screens/contact_us_screen.dart';
import 'package:book_mobile/screens/downloaded_book_screen.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/screens/login_screen.dart';
import 'package:book_mobile/screens/forgot_password_screen.dart';
import 'package:book_mobile/screens/my_books_screen.dart';
import 'package:book_mobile/screens/notification_screen.dart';
import 'package:book_mobile/screens/profile_screen.dart';
import 'package:book_mobile/screens/setting_screen.dart';
import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/screens/splash_screen.dart';
import 'package:book_mobile/screens/subscription_tier_screen.dart';
import 'package:book_mobile/screens/update_profile_screen.dart';
import 'package:book_mobile/services/background_service.dart';
import 'package:book_mobile/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('Notification permission denied');
      } else if (status.isPermanentlyDenied) {
        print('Notification permission permanently denied');
      }
    }
  }
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  // Initialize WorkManager
  final authProvider =
      AuthProvider(storageService: storageService); // Initialize AuthProvider
  final loginProvider = LoginProvider(authProvider: authProvider);

  // Initialize the background service
  await loginProvider.initializeLoginStatus();
  await initializeBackgroundService(loginProvider);

  // Schedule the background task
  scheduleBackgroundTask();
  runApp(MyApp(
    storageService: storageService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(
            create: (context) => LoginProvider(
                authProvider: Provider.of<AuthProvider>(context, listen: false))
              ..initializeLoginStatus()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => OrderStatusProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(
            create: (context) => SubscriptionTiersProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (context) => UpdateProfileProvider()),
        ChangeNotifierProvider(create: (context) => AuthorProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Signup',
        initialRoute: '/',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.color1),
          useMaterial3: true,
          scaffoldBackgroundColor:
              AppColors.color1, // Set background color of the entire app
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          // '/verify': (context) => const VerificationScreen(),
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/splash': (context) => const SplashScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/allAudio': (context) => const AllAudioScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/notification': (context) => const NotificationScreen(),
          '/allEbook': (context) => const AllBooksScreen(),
          '/edit-profile': (context) => const UpdateProfileScreen(),
          '/my-books': (context) => const DownloadScreen(),
          '/downloaded': (context) => const DownloadedBooksScreen(),
          '/subscription-tier': (context) => const SubscriptionTierScreen(),
          '/contact-us': (context) => const ContactUsScreen(),
          '/announcements': (context) => const AnnouncementListScreen(),
          // '/notifications': (context) => const NotificationsScreen(),
          // '/author': (context) => const AuthorScreen(),
        },
      ),
    );
  }
}
