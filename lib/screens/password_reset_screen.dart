import 'package:bookreader/widgets/custom_button.dart';
import 'package:bookreader/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/providers/auth_provider.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';

class PasswordResetScreen extends StatefulWidget {
  final String token;
  const PasswordResetScreen({
    required this.token,
    super.key,
  });

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _message;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      // Simulate delay for token availability if needed
      if (widget.token.isEmpty) {
        setState(() {
          _message = "Invalid or missing reset token.";
        });
      }
    });
  }

  void _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _message = 'Failed: Please enter both new password and confirmation.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _message = 'Failed: Passwords do not match!';
      });
      return;
    }

    setState(() {
      _message = null; // Clear message
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).resetPassword(
        resetToken: widget.token,
        newPassword: newPassword,
      );

      // Display success Snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Password reset successfully! Redirecting to Login...'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the home screen
        Future.delayed(const Duration(seconds: 2), () {
          context.go('/login');
        });
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Reset Password',
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
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
                borderRadius: BorderRadius.circular(width * 0.04),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Enter your new password.',
                      style: AppTextStyles.heading2
                          .copyWith(fontSize: width * 0.045),
                    ),
                    SizedBox(height: height * 0.01),
                    CustomTextField(
                      controller: _newPasswordController,
                      labelText: 'New Password',
                      hintText: 'Your new password',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white10,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your new password',
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white10,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _message!.startsWith('Failed')
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    SizedBox(height: height * 0.01),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : CustomButton(
                            backgroundColor: AppColors.color2,
                            borderColor: AppColors.color3,
                            text: 'Reset Password',
                            onPressed: _resetPassword,
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
