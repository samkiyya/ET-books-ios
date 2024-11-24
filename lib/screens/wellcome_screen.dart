import 'package:book_mobile/constants/styles.dart';
// import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
// import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              const Text(
                'Welcome Back',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 50),
              // Sign In button
              SizedBox(
                width: 350,
                child: CustomButton(
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
              ),
              const SizedBox(height: 40),
              // Sign Up button
              SizedBox(
                width: 350,
                child: CustomButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
