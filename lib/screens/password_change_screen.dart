import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordChangeFormScreen extends StatefulWidget {
  const PasswordChangeFormScreen({super.key});

  @override
  State<PasswordChangeFormScreen> createState() =>
      _PasswordChangeFormScreenState();
}

class _PasswordChangeFormScreenState extends State<PasswordChangeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _hideOldPassword = true;
  bool _hideNewPassword = true;

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      Navigator.of(context).pop(); // Close modal
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
        ),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
        centerTitle: true,
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: _oldPasswordController,
                      labelText: 'Old Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideOldPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.color1,
                        ),
                        onPressed: () {
                          setState(() {
                            _hideOldPassword = !_hideOldPassword;
                          });
                        },
                      ),
                      obscureText: _hideOldPassword,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your old password'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _newPasswordController,
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.color1,
                        ),
                        onPressed: () {
                          setState(() {
                            _hideNewPassword = !_hideNewPassword;
                          });
                        },
                      ),
                      obscureText: _hideNewPassword,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your new password'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ))
                        : CustomButton(
                            text: 'Change Password',
                            onPressed: _submit,
                            backgroundColor: AppColors.color2,
                            borderColor: AppColors.color3,
                            textStyle: AppTextStyles.buttonText
                                .copyWith(color: AppColors.color6),
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
