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
                                    // int.parse(userId.toString()),
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



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';

// class EmailVerificationScreen extends StatelessWidget {
//   const EmailVerificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify Email'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Icon(
//               Icons.mark_email_unread_outlined,
//               size: 64,
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Verify Your Email',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             if (authProvider.error != null)
//               Text(
//                 authProvider.error!,
//                 style: const TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center,
//               ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: authProvider.isLoading
//                   ? null
//                   : () async {
//                       await authProvider.resendVerificationEmail();
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Verification email resent'),
//                           ),
//                         );
//                       }
//                     },
//               child: authProvider.isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Resend Verification Email'),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pushReplacementNamed('/login');
//               },
//               child: const Text('Back to Login'),
//             ),
//           ],
//         ),