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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ensure that userData is not null
    final userData = authProvider.userData;
    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Safely get userId from userData
    final userId = userData.id;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Two-Factor Authentication',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter the verification code sent to your email:',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: codeController,
              decoration: const InputDecoration(
                hintText: 'Enter Verification Code',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.color6,
              ),
            ),
            const SizedBox(height: 20),
            Consumer<LoginProvider>(
              builder: (context, loginProvider, child) {
                return loginProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
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
    );
  }
}
