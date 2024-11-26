import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/providers/login_provider.dart';
import 'package:book_mobile/providers/notification_provider.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:book_mobile/providers/profile_provider.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/providers/signup_provider.dart';
import 'package:book_mobile/screens/all_audio_screen.dart';
import 'package:book_mobile/screens/all_book_screen.dart';
// import 'package:book_mobile/screens/author_screen.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/screens/login_screen.dart';
import 'package:book_mobile/screens/forgot_password_screen.dart';
import 'package:book_mobile/screens/notification_screen.dart';
import 'package:book_mobile/screens/profile_screen.dart';
import 'package:book_mobile/screens/setting_screen.dart';
import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/screens/splash_screen.dart';
import 'package:book_mobile/services/background_service.dart';
// import 'package:book_mobile/services/notification_service.dart';
// import 'package:book_mobile/screens/verfication_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
// Initialize the background service
  final authProvider = AuthProvider(); // Initialize AuthProvider
  final loginProvider = LoginProvider(authProvider: authProvider);

  // Initialize the background service
  await AuthProvider().loadTokenFromStorage();
  await loginProvider.initializeLoginStatus();
  await initializeBackgroundService(loginProvider);

  // Schedule the background task
  scheduleBackgroundTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // You can add more providers here in the list
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..loadTokenFromStorage()),

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
          'settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationScreen(),
          '/allEbook': (context) => const AllBooksScreen(),
          // '/notifications': (context) => const NotificationsScreen(),
          // '/category': (context) => const CategoryScreen(),
          // '/author': (context) => const AuthorScreen(),
        },
      ),
    );
  }
}
