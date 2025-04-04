import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class VerificationScreen extends StatefulWidget {
  final String token;

  const VerificationScreen({required this.token, super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late TextEditingController emailController;
  bool showEmailField = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    verifyWithToken(); // Trigger token verification automatically
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void verifyWithToken() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.verifyAccount(widget.token);
      if (mounted) {
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your Account verified successfully! \nlogin to use the app',
              style: const TextStyle(color: AppColors.color3),
            ),
            backgroundColor: Colors.green,
          ),
        ); // Navigate to home on success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          showEmailField = true; // Show email field if verification fails
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: AppColors.color3),
            ),
            backgroundColor: AppColors.color5,
          ),
        );
      }
    }
  }

  void resendVerificationEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (emailController.text.isNotEmpty) {
      try {
        bool success = await authProvider
            .sendVerificationEmail(emailController.text.trim());
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification email resent successfully'),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authProvider.error ?? 'Failed to resend verification email',
                  style: const TextStyle(color: AppColors.color3),
                ),
                backgroundColor: AppColors.color5,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: $e',
                style: const TextStyle(color: AppColors.color3),
              ),
              backgroundColor: AppColors.color5,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(width * 0.0148),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.0225),
              const Text(
                'Account Verification',
                style: AppTextStyles.heading2,
              ),
              SizedBox(height: height * 0.009),
              const Text(
                'We are verifying your account. If you encounter an issue, you can resend the verification email below.',
                style: AppTextStyles.bodyText,
              ),
              if (showEmailField) ...[
                SizedBox(height: height * 0.0225),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.color6,
                  ),
                ),
                SizedBox(height: height * 0.0225),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return authProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: resendVerificationEmail,
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              backgroundColor: AppColors.color6,
                            ),
                            child: const Text(
                              'Resend Verification Email',
                              style: AppTextStyles.buttonText,
                            ),
                          );
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
