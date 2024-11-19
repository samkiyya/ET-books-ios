import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/screens/verification_screen.dart';
import 'package:book_mobile/screens/forgot_password_screen.dart'; // Add your Forgot Password Screen import
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginProvider>(context, listen: false)
          .addListener(_handleLoginResponse);
    });
  }

  @override
  void dispose() {
    Provider.of<LoginProvider>(context, listen: false)
        .removeListener(_handleLoginResponse);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLoginResponse() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    if (loginProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (loginProvider.errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: Text(loginProvider.errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  loginProvider.clearError();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.color1,
                AppColors.color2,
              ]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Login Page!',
                style: AppTextStyles.heading1,
              ),
            ),
          ),
          // Login form container
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.color1,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Consumer<LoginProvider>(
                    builder: (context, loginProvider, child) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Email field
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: "Enter your Email",
                              icon: Icons.email,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your email'
                                      : null,
                            ),

                            const SizedBox(height: 20),
                            // Password field
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: "Enter your password",
                              icon: Icons.lock,
                              obscureText: true,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                            ),
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.color3,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            // Login button
                            loginProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CustomButton(
                                    text: 'LOGIN',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        loginProvider.login(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                        );
                                      }
                                    },
                                    backgroundColor: AppColors.color2,
                                    borderColor: Colors.transparent,
                                    textStyle: AppTextStyles.buttonText,
                                  ),
                            const SizedBox(height: 30),
                            // Navigate to Verification Screen
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const VerificationScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Verify your account here.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color3,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            // Signup prompt
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.color3,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
