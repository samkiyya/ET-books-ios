import 'dart:async';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
// import 'package:book_mobile/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    _navigateToNextScreen();
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

  void _navigateToNextScreen() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!mounted) return;

    await loginProvider.initializeLoginStatus();
    if (!mounted) return;

    if (loginProvider.isAuthenticated && !loginProvider.isTokenExpired) {
      context.go('/home');
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
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
                  child: Icon(
                    Icons.book,
                    size: width * 0.4,
                    color: AppColors.color3,
                  ),
                ),
              ),
              SizedBox(height: height * 0.009),
              Text(
                'Book App',
                style: TextStyle(
                  fontSize: width * 0.05,
                  color: AppColors.color3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isInitialized) ...[
                SizedBox(height: height * 0.09),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
