import 'dart:async';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/home_screen.dart';
// import 'package:book_mobile/screens/verification_screen.dart';
import 'package:book_mobile/screens/wellcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/providers/login_provider.dart';
// import 'package:book_mobile/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLogin();
    _setupAnimation();
    _navigateToNextScreen(context);
  }

  Future<void> _initializeLogin() async {
    await Provider.of<LoginProvider>(context, listen: false)
        .initializeLoginStatus();
    if (context.mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _navigateToNextScreen(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!mounted) return;

    await loginProvider.checkLoginStatus();
    if (!mounted) return;

    if (loginProvider.isAuthenticated && !loginProvider.isTokenExpired) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else if (loginProvider.isAuthenticated && loginProvider.isTokenExpired) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.color1.withOpacity(0.6),
                AppColors.color1,
                AppColors.color1..withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  child: const Icon(
                    Icons.book,
                    size: 150,
                    color: AppColors.color3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Book App',
                style: TextStyle(
                  fontSize: 30,
                  color: AppColors.color3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isInitialized) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
