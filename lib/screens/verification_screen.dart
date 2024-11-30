import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late TextEditingController codeController;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ensure that userData is not null
    final userData = authProvider.userData;
    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Safely get userId from userData
    final userId = userData.id;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(width * 0.0148),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.0225),
              const Text(
                'Two-Factor Authentication',
                style: AppTextStyles.heading2,
              ),
              SizedBox(height: height * 0.009),
              const Text(
                'Enter the verification code sent to your email:',
                style: AppTextStyles.bodyText,
              ),
              SizedBox(height: height * 0.0045),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  hintText: 'Enter Verification Code',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.color6,
                ),
              ),
              SizedBox(height: height * 0.009),
              Consumer<LoginProvider>(
                builder: (context, loginProvider, child) {
                  return loginProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (codeController.text.isNotEmpty) {
                                try {
                                  await authProvider.verify2FA(
                                    codeController.text.trim(),
                                    int.parse(userId.toString()),
                                  );

                                  if (mounted) {
                                    // Check if widget is still mounted
                                    if (loginProvider.isAuthenticated) {
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .popAndPushNamed('/home');
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              loginProvider.errorMessage.isEmpty
                                                  ? 'Verification failed. Try again.'
                                                  : loginProvider.errorMessage,
                                              style: const TextStyle(
                                                  color: AppColors.color3),
                                            ),
                                            backgroundColor: AppColors.color5,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'An error occurred. Please try again.'),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please enter the verification code'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              backgroundColor: AppColors.color6,
                            ),
                            child: const Text(
                              'Verify',
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
