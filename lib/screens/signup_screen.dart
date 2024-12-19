import 'dart:io';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/signup_provider.dart';
import 'package:book_mobile/screens/login_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:book_mobile/widgets/modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  File? _profileImage; // Hide password by default

  // Form field controllers
  final Map<String, TextEditingController> controllers = {
    'First Name': TextEditingController(),
    'Last Name': TextEditingController(),
    'Email': TextEditingController(),
    'Password': TextEditingController(),
    'Phone': TextEditingController(),
    'City': TextEditingController(),
    'Country': TextEditingController(),
    'Bio': TextEditingController(),
    'referalCode': TextEditingController(),
  };
  String? selectedRole;
  File? imageFile;

  String? _validateField(String key, String value) {
    // Required fields
    if ((key == 'First Name' ||
            key == 'Last Name' ||
            key == 'Password' ||
            key == 'Email') &&
        value.isEmpty) {
      return '$key cannot be empty';
    }

    if ((key == 'First Name' || key == 'Last Name') && value.isNotEmpty) {
      if (value.length < 2) {
        return '$key must be at least 2 characters long';
      }
    }

    // Email validation
    if (key == 'Email' &&
        value.isNotEmpty &&
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(value)) {
      return 'Enter a valid email';
    }

    // Password length validation
    if (key == 'Password' && value.isNotEmpty && value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (key == 'Bio' && value.isNotEmpty) {
      if (value.length > 30) {
        return 'Bio must not exceed 30 characters';
      }
    }

    // Phone number validation (if provided)
    if (key == 'Phone' && value.isNotEmpty) {
      if (!RegExp(r"^[0-9]{10,13}$").hasMatch(value)) {
        return 'Phone number must be between 10 and 13 digits';
      }
    }

    // Optional fields, no validation for other cases
    return null; // No errors
  }

  // Show success or error dialog
  void _showResponseDialog(
      BuildContext context, String message, String buttonText, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomMessageModal(
          message: message,
          buttonText: buttonText,
          type: isSuccess
              ? 'success'
              : 'error', // Set type based on success or error
          onClose: () {
            Navigator.of(context).pop();
          },
          onSuccess: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.color1,
                  AppColors.color2,
                ]),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: width * 0.0555556, left: width * 0.02037),
                child: const Text(
                  'Create Your Account',
                  style: AppTextStyles.heading1,
                ),
              ),
            ),
            // Form container
            Padding(
              padding: EdgeInsets.only(top: height * 0.09),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: AppColors.color1,
                ),
                height: double.infinity,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width * 0.016666,
                    right: width * 0.016666,
                  ),
                  child: Consumer<SignupProvider>(
                    builder: (context, signupProvider, child) {
                      // Display dialog based on success or error message
                      if (signupProvider.successMessage.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showResponseDialog(
                            context,
                            "You are registered successfully. Please check your email to verify your account before logging in.",
                            "Login",
                            true,
                          );
                          signupProvider.clearMessages();
                        });
                      } else if (signupProvider.errorMessage.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showResponseDialog(context,
                              signupProvider.errorMessage, "Retry", false);
                          signupProvider.clearMessages();
                        });
                      }

                      return SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Dynamically generate CustomTextFields
                              ...controllers.entries.map((entry) {
                                return CustomTextField(
                                  controller: entry.value,
                                  labelText: entry.key,
                                  validator: (value) =>
                                      _validateField(entry.key, value!),
                                  suffixIcon: entry.key == 'Password'
                                      ? IconButton(
                                          icon: Icon(
                                            _hidePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.color1,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _hidePassword = !_hidePassword;
                                            });
                                          },
                                        )
                                      : null,
                                  obscureText: entry.key == 'Password'
                                      ? _hidePassword
                                      : false,
                                );
                              }),
                              SizedBox(height: height * 0.009),
                              // Role Selection
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Role',
                                  style: AppTextStyles.bodyText,
                                ),
                              ),
                              ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButtonFormField<String>(
                                  value: selectedRole ?? selectedRole,
                                  hint: const Text(
                                    "Please Select your Role",
                                    style: AppTextStyles.hintText,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRole = newValue!;
                                    });
                                  },
                                  items: [
                                    {'display': 'Author', 'value': 'AUTHOR'},
                                    {'display': 'Reader', 'value': 'USER'},
                                  ].map<DropdownMenuItem<String>>(
                                      (Map<String, String> role) {
                                    return DropdownMenuItem<String>(
                                      value: role[
                                          'value'], // Send this value to the backend
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.01),
                                        child: Text(
                                          role[
                                              'display']!, // Display this value in the dropdown
                                          style: AppTextStyles.hintText,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    labelStyle: const TextStyle(
                                        color: AppColors.color3),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: height * 0.0045),
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: AppColors.color6,
                                  ),
                                  dropdownColor: AppColors
                                      .color6, // Background color for the dropdown menu
                                ),
                              ),

                              SizedBox(height: height * 0.009),
                              // Image Upload Button
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () async {
                                      await signupProvider.pickProfileImage();
                                      setState(() {
                                        _profileImage = signupProvider
                                            .profileImage; // Sync with provider
                                      });
                                    },
                                    icon: const Icon(Icons.image,
                                        color: AppColors.color3),
                                    label: Text(
                                      _profileImage == null
                                          ? 'Upload profile Image'
                                          : 'Change Image',
                                      style: AppTextStyles.bodyText,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.037),
                                  // Image preview (optional)
                                  Flexible(
                                      child: signupProvider.profileImage == null
                                          ? const Text(
                                              'No profile image selected',
                                              style: AppTextStyles.caption,
                                            )
                                          : Image.file(
                                              signupProvider.profileImage!,
                                              fit: BoxFit.cover,
                                              height: height * 0.09))
                                ],
                              ),
                              SizedBox(height: height * 0.009),
                              // Show loading spinner if the provider is loading
                              signupProvider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : CustomButton(
                                      text: 'Sign Up',
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          signupProvider.signup(
                                            email: controllers['Email']!
                                                .text
                                                .trim(),
                                            password: controllers['Password']!
                                                .text
                                                .trim(),
                                            fname:
                                                controllers['First Name']!.text,
                                            lname:
                                                controllers['Last Name']!.text,
                                            phone: controllers['Phone']!.text,
                                            city: controllers['City']!.text,
                                            country:
                                                controllers['Country']!.text,
                                            role: selectedRole,
                                            bio: controllers['Bio']!.text,
                                            context: context,
                                          );
                                        } else {
                                          print(
                                              "Error: Form validation failed.");
                                        }
                                      },
                                      backgroundColor: AppColors.color2,
                                      borderColor: AppColors.color3,
                                      textStyle: AppTextStyles.buttonText,
                                    ),
                              SizedBox(height: height * 0.037),
                              // Bottom TextButton for navigation
                              TextButton(
                                onPressed: () {
                                  // Navigate to LoginScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: width * 0.045,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Go to Login',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.color3,
                                          fontSize: width * 0.045,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
