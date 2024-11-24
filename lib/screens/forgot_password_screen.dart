import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  void _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .reserPassword(email);
      setState(() {
        _message = 'Password reset email sent successfully.';
      });
    } catch (error) {
      setState(() {
        _message = 'Failed to send reset email: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Password Recovery')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address to receive a password reset link.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
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
                  onPressed: _submitEmail,
                  child: const Text('Send Reset Email'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
