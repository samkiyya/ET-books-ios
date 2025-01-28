import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:book_mobile/routes.dart';
import 'package:book_mobile/services/permission_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:go_router/go_router.dart';
import 'package:book_mobile/exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  AppPermission appPermission = AppPermission();

  @override
  void initState() {
    super.initState();

    _setupDeepLinks();
    disableScreenshots();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        appPermission.initializePermissions(context);
      }
    });
  }

  @override
  void dispose() {
    _appLinkSubscription.cancel();
    enableScreenshot();
    super.dispose();
  }

  void _setupDeepLinks() {
    _appLinks = AppLinks();
    _appLinkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (mounted) {
        _navigateToRoute(uri);
      }
    });
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
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp.router(
          title: 'Flutter Signup',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.color1),
            useMaterial3: true,
            scaffoldBackgroundColor:
                AppColors.color1, // Set background color of the entire app
          ),
          debugShowCheckedModeBanner: false,
          // initialRoute: '/',
          // onGenerateRoute: _onGenerateRoute,
          routerConfig: _router,
          builder: (context, child) {
            return child!;
          }),
    );
  }

  final Map<String, String> pathMapping = MyRoute.deepLinks;

  void _navigateToRoute(Uri uri) {
    final route = pathMapping[uri.pathSegments.first] ?? '/';
    context.go(route, extra: uri.queryParameters);
  }

  final GoRouter _router = MyRoute.myroutes;
}
