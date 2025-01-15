import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
// import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
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
              const Text(
                'Welcome Back',
                style: AppTextStyles.heading1,
              ),
              SizedBox(height: height * 0.0225),
              // Sign In button
              CustomButton(
                text: 'LOG IN',
                onPressed: () {
                  context.push('/login');
                },
                backgroundColor: Colors.transparent,
                borderColor: AppColors.color3,
                textStyle: AppTextStyles.buttonText,
              ),
              SizedBox(height: height * 0.05),
              // Sign Up button
              CustomButton(
                text: 'SIGN UP',
                onPressed: () {
                  context.push('/signup');
                },
                backgroundColor: AppColors.color2,
                borderColor: AppColors.color3,
                textStyle: AppTextStyles.buttonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
