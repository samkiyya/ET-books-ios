import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/providers/auth_provider.dart';
import 'package:bookreader/widgets/custom_button.dart';
import 'package:bookreader/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  Color successColor = Colors.green;
  Color errorColor = Colors.red;
  Color _messageColor = Colors.green;

  void _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your email address.';
        _messageColor = errorColor;
      });
      return;
    }
    bool isValid = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);

    if (!isValid) {
      setState(() {
        _message = 'Please enter a valid email address.';
        _messageColor = errorColor;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .forgotPassword(email);
      setState(() {
        _message = 'Password reset email sent successfully.';
        _messageColor = successColor;
      });
    } catch (error) {
      setState(() {
        _message = 'Failed to send reset email: $error';
        _messageColor = errorColor;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Password Recovery'),
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: height * 0.16, left: width * 0.04, right: width * 0.04),
          child: Align(
            alignment: Alignment.center,
            child: Card(
              color: AppColors.color1,
              elevation: 5.0, // Add elevation for a card-like effect
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(width * 0.04), // Rounded corners
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.03),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter your email address to receive a password reset link.',
                      style: AppTextStyles.bodyText
                          .copyWith(fontSize: width * 0.045),
                    ),
                    SizedBox(height: height * 0.009),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                    ),
                    SizedBox(height: height * 0.009),
                    if (_message != null)
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.startsWith('Failed')
                              ? errorColor
                              : _messageColor,
                        ),
                      ),
                    SizedBox(height: height * 0.009),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      CustomButton(
                        backgroundColor: AppColors.color2,
                        borderColor: AppColors.color3,
                        text: 'Send Reset Email',
                        onPressed: _submitEmail,
                        textStyle: AppTextStyles.buttonText,
                      ),
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
