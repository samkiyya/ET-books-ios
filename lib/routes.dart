import 'package:book_mobile/exports.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class MyRoute{
static Map<String, String> deepLinks = {
    'gcallback?token=': '/home',
    'reset-password': '/reset-password/:token',
    'verify-email': '/verify-email/:token',
    'fcallback?token': '/home',
  };

  static GoRouter myroutes = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/gcallback',
        builder: (BuildContext context, GoRouterState state) {
          return HomeScreen();
        },
      ),
      GoRoute(
        path: '/reset-password/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return PasswordResetScreen(token: token);
        },
      ),
      GoRoute(
        path: '/verify-email/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return VerificationScreen(token: token);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/allAudio',
        builder: (context, state) => const AllAudioScreen(),
      ),
      GoRoute(
        path: '/allEbook',
        builder: (context, state) => const AllBooksScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        path: '/my-books',
        builder: (context, state) => const DownloadScreen(),
      ),
      GoRoute(
        path: '/downloaded',
        builder: (context, state) => const DownloadedBooksScreen(),
      ),
      GoRoute(
        path: '/subscription-tier',
        builder: (context, state) => const SubscriptionTierScreen(),
      ),
      GoRoute(
        path: '/contact-us',
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementListScreen(),
      ),
      GoRoute(
        path: '/authors',
        builder: (context, state) => const AuthorsScreen(),
      ),
      GoRoute(
        path: '/2fa',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path:'/status',
        builder: (context, state) => const OrderStatusScreen(),
      ),
      GoRoute(
        path: '/subscriptionOrder/:tier',
        builder: (context, state) {
          final tier = state.pathParameters;
          return SubscriptionOrderScreen(tier: tier);
        },
      ),
      GoRoute(
      path: '/notification/:id',
      builder: (context, state) {
        final notificationId = state.pathParameters['id'];
        return NotificationDetailScreen(notificationId: int.parse(notificationId!));
      },
    ),
    ],
  );
}