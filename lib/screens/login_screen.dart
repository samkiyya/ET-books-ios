import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/screens/signup_screen.dart';
import 'package:book_mobile/screens/forgot_password_screen.dart'; // Add your Forgot Password Screen import
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:book_mobile/widgets/modal.dart';
import 'package:book_mobile/widgets/square_tile.dart';
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
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginProvider>(context, listen: false)
          .addListener(_handleLoginResponse);
    });
  }

// Show success or error dialog
  void _showResponseDialog(
      BuildContext context, String message, String buttonText, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomMessageModal(
          message: message,
          buttonText: buttonText,
          type: isSuccess ? 'success' : 'error',
          onClose: () {
            Navigator.of(context).pop();
            if (isSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    loginProvider.removeListener(_handleLoginResponse);

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLoginResponse() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (loginProvider.successMessage.isNotEmpty) {
      _showResponseDialog(
        context,
        loginProvider.successMessage,
        "Close",
        true,
      );
      loginProvider.clearMessages();
    } else if (loginProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (loginProvider.errorMessage.isNotEmpty) {
      _showResponseDialog(
        context,
        loginProvider.errorMessage,
        "Retry",
        false,
      );
      loginProvider.clearMessages();
    }
  }

  String? _validateField(String key, String value) {
    if (value.isEmpty) {
      return 'Please enter your $key';
    }
    if (key == 'email') {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }
    }
    if (key == 'password' && value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    return null; // No errors
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.color1,
                  AppColors.color2,
                ]),
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(top: height * 0.09, left: width * 0.04),
                child: Center(
                  child: const Text(
                    'Login',
                    style: AppTextStyles.heading1,
                  ),
                ),
              ),
            ),
            // Login form container
            Padding(
              padding: EdgeInsets.only(top: height * 0.25),
              child: Container(
                height: height * .8,
                width: width,
                decoration: const BoxDecoration(
                  color: AppColors.color1,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.055),
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
                                    _validateField('email', value!),
                              ),
                              SizedBox(height: height * 0.02),
                              // Password field
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: "Enter your password",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.color1,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                                obscureText: _hidePassword,
                                validator: (value) =>
                                    _validateField('password', value!),
                              ),
                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.color3,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              // Login button
                              loginProvider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)))
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
                                      borderColor: AppColors.color3,
                                      textStyle: AppTextStyles.buttonText,
                                    ),
                              SizedBox(height: height * 0.07),
                              // Social Login Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SquareTile(
                                    imagePath: 'assets/images/g_logo.png',
                                    onTap: () async {
                                      try {
                                        await loginProvider.loginWithGoogle();

                                        if (loginProvider.isAuthenticated) {
                                          if (context.mounted) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const HomeScreen()),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Google Login Failed: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  SizedBox(width: width * 0.1),
                                  SquareTile(
                                    imagePath: 'assets/images/fb_logo.png',
                                    onTap: () async {
                                      try {
                                        await loginProvider.loginWithFacebook();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Logged in with Facebook'),
                                            ),
                                          );
                                        }
                                        // Check if user is authenticated after Facebook login and navigate

                                        if (loginProvider.isAuthenticated) {
                                          if (context.mounted) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const HomeScreen()),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Facebook Login Failed: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  )
                                ],
                              ),
                              SizedBox(height: height * 0.06),
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
                                      fontSize: width * 0.045,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.color3,
                                          fontSize: width * .055,
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
      ),
    );
  }
}
