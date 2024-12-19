import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/providers/auth_provider.dart';

class PasswordResetScreen extends StatefulWidget {
  final String resetToken; // Pass this token to the screen
  const PasswordResetScreen({super.key, required this.resetToken});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  void _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      setState(() {
        _message = 'Please enter a new password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).resetPassword(
        widget.resetToken,
        newPassword,
      );
      setState(() {
        _message = 'Password reset successfully.';
      });
    } catch (error) {
      setState(() {
        _message = 'Failed to reset password: $error';
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
          title: Text(
            'Reset Password',
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.0148148, vertical: height * 0.0072072),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a new password to reset your password.',
                style: TextStyle(fontSize: width * 0.0148148),
              ),
              SizedBox(height: height * 0.0072072),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * 0.0072072),
              if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.startsWith('Failed')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              SizedBox(height: height * 0.0072072),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Reset Password'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
