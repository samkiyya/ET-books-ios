import 'dart:async';
import 'package:book/constants/styles.dart';
import 'package:book/screens/home_screen.dart';
import 'package:book/screens/login_screen.dart';
import 'package:book/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Create a scaling animation
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    // Start the animation
    _controller?.forward();

    // Navigate to home after 3 seconds
    Timer(Duration(seconds: 3), () {
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );

    });
  }   
   
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color1, // Change background color as needed
      body: Center(
        child: FadeTransition(
          opacity: _animation!,
          child: ScaleTransition(
            scale: _animation!,
            child: Image.asset(
              'assets/logo.png', // Path to your logo image
              width: 150, // Adjust logo size as needed
            ),
          ),
        ),
      ),
    );
  }
}


