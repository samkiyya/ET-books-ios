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
      await Provider.of<AuthProvider>(context, listen: false)
          .changePassword(widget.resetToken, newPassword);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a new password to reset your password.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('Failed')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            const SizedBox(height: 16.0),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Reset Password'),
              ),
          ],
        ),
      ),
    );
  }
}
