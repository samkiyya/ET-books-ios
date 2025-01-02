import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:book_mobile/providers/content_access_provider.dart';
import 'package:book_mobile/providers/review_provider.dart';
import 'package:book_mobile/screens/all_author_screen.dart';
import 'package:book_mobile/screens/wellcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:no_screenshot/no_screenshot.dart';

import 'package:book_mobile/exports.dart';

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

class MyApp extends StatefulWidget {
  final StorageService storageService;
  const MyApp({super.key, required this.storageService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  late StreamSubscription _appLinkSubscription;
  final _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _appLinkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _navigateToRoute(uri, context);
    });
    disableScreenshots();
  }

  @override
  void dispose() {
    _appLinkSubscription.cancel();
    enableScreenshot();
    super.dispose();
  }

  void disableScreenshots() async {
    bool result = await _noScreenshot.screenshotOff();
    if (!result) {
      debugPrint('Failed to disable screenshots.');
    } else {
      debugPrint('Screenshot blocking enabled.');
    }
    await _noScreenshot.startScreenshotListening();
    debugPrint('Screenshot listening started.');
    _noScreenshot.screenshotStream.listen((event) {
      _showScreenshotNotAllowedAlert();
    });
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    if (!result) {
      debugPrint('Failed to enable screenshots.');
    } else {
      debugPrint('Screenshot blocking disabled.');
    }
  }

  /// Show a notification when the user attempts to take a screenshot
  void _showScreenshotNotAllowedAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            "Screenshots and screen recording are not allowed. in this app"),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(storageService: widget.storageService)),
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
        ChangeNotifierProvider(create: (_) => AuthorProvider()),
        ChangeNotifierProvider(create: (_) => UserActivityProvider()),
        ChangeNotifierProvider(create: (_) => AccessProvider()),

        ChangeNotifierProvider(create: (_)=>ReviewProvider()),
      ],
      child: MaterialApp(
          title: 'Flutter Signup',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.color1),
            useMaterial3: true,
            scaffoldBackgroundColor:
                AppColors.color1, // Set background color of the entire app
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
          builder: (context, child) {
            _handleAppLinks(context);
            return child!;
          }),
    );
  }

  // Method to handle incoming app links
  void _handleAppLinks(BuildContext context) async {
    // _appLinks is already initialized in initState
    _appLinks.uriLinkStream.listen((uri) {
      _navigateToRoute(uri, context);
    });
  }

  // Navigation logic based on the link
  void _navigateToRoute(Uri uri, BuildContext context) {
    if (uri.pathSegments.contains('login')) {
      Navigator.pushNamed(context, '/login');
    } else if (uri.pathSegments.contains('signup')) {
      Navigator.pushNamed(context, '/signup');
    } else if (uri.pathSegments.contains('allAudio')) {
      Navigator.pushNamed(context, '/allAudio');
    } else if (uri.pathSegments.contains('allEbook')) {
      Navigator.pushNamed(context, '/allEbook');
    } else if (uri.pathSegments.contains('settings')) {
      Navigator.pushNamed(context, '/settings');
    } else if (uri.pathSegments.contains('notification')) {
      Navigator.pushNamed(context, '/notification');
    } else if (uri.pathSegments.contains('profile')) {
      Navigator.pushNamed(context, '/profile');
    } else if (uri.pathSegments.contains('home')) {
      Navigator.pushNamed(context, '/home');
    } else if (uri.pathSegments.contains('edit-profile')) {
      Navigator.pushNamed(context, '/edit-profile');
    } else if (uri.pathSegments.contains('my-books')) {
      Navigator.pushNamed(context, '/my-books');
    } else if (uri.pathSegments.contains('downloaded')) {
      Navigator.pushNamed(context, '/downloaded');
    } else if (uri.pathSegments.contains('subscription-tier')) {
      Navigator.pushNamed(context, '/subscription-tier');
    } else if (uri.pathSegments.contains('contact-us')) {
      Navigator.pushNamed(context, '/contact-us');
    } else if (uri.pathSegments.contains('announcements')) {
      Navigator.pushNamed(context, '/announcements');
    } else if (uri.pathSegments.contains('purchase-order')) {
      Navigator.pushNamed(context, '/purchase-order');
    } else if (uri.pathSegments.contains('user-activity')) {
      Navigator.pushNamed(context, '/user-activity');
    } else if (uri.pathSegments.contains('forgot-password')) {
      Navigator.pushNamed(context, '/forgot-password');
    } else if (uri.pathSegments.contains('welcome')) {
      Navigator.pushNamed(context, '/welcome');
    } else if (uri.pathSegments.contains('authors')) {
      Navigator.pushNamed(context, '/authors');
    } else {
      Navigator.pushNamed(context, '/');
    }
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/allAudio':
        return MaterialPageRoute(builder: (_) => const AllAudioScreen());
      case '/allEbook':
        return MaterialPageRoute(builder: (_) => const AllBooksScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/notification':
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case '/edit-profile':
        return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());
      case '/my-books':
        return MaterialPageRoute(builder: (_) => const DownloadScreen());
      case '/downloaded':
        return MaterialPageRoute(builder: (_) => const DownloadedBooksScreen());
      case '/subscription-tier':
        return MaterialPageRoute(
            builder: (_) => const SubscriptionTierScreen());
      case '/contact-us':
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());
      case '/announcements':
        return MaterialPageRoute(
            builder: (_) => const AnnouncementListScreen());
      case '/authors':
        return MaterialPageRoute(builder: (_) => const AuthorsScreen());
      default:
        return null;
    }
  }
}
