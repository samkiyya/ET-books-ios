import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
// import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
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
                  Navigator.pushNamed(context, '/login');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const LoginScreen()),
                  // );
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
                  Navigator.pushNamed(context, '/signup');

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const SignupScreen()),
                  // );
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
