import 'dart:io';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/signup_provider.dart';
import 'package:book_mobile/screens/login_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:book_mobile/widgets/modal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

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
  };
  String selectedRole = 'AUTHOR'; // Default role
  File? imageFile; // To store the selected image file

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path); // Save the selected image
      });
    }
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
    return Scaffold(
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
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your Account',
                style: AppTextStyles.heading1,
              ),
            ),
          ),
          // Form container
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
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
                padding: const EdgeInsets.only(left: 18.0, right: 18),
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
                              );
                            }),
                            const SizedBox(height: 20),
                            // Role Selection
                            ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonFormField<String>(
                                value: selectedRole,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedRole = newValue!;
                                  });
                                },
                                items: <String>[
                                  'AUTHOR',
                                  'USER'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(value,
                                          style: AppTextStyles.hintText),
                                    ),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  labelText: 'Who Are You?',
                                  labelStyle:
                                      TextStyle(color: AppColors.color3),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: AppColors.color6,
                                ),
                                dropdownColor: AppColors
                                    .color6, // Background color for the dropdown menu
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Image Upload Button
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius
                                            .zero, // No rounding for rectangular shape
                                      ),
                                      backgroundColor: AppColors.color6),
                                  child: Text(
                                    imageFile == null
                                        ? 'Upload Image'
                                        : 'Change Image',
                                    style: AppTextStyles.buttonText,
                                  ),
                                ),

                                const SizedBox(width: 40),
                                // Image preview (optional)
                                imageFile != null
                                    ? Image.file(imageFile!,
                                        height: 100, width: 100)
                                    : const Text(
                                        'No image selected',
                                        style: AppTextStyles.bodyText,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Show loading spinner if the provider is loading
                            signupProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CustomButton(
                                    text: 'Sign Up',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        signupProvider.signup(
                                          email:
                                              controllers['Email']!.text.trim(),
                                          password: controllers['Password']!
                                              .text
                                              .trim(),
                                          fname:
                                              controllers['First Name']!.text,
                                          lname: controllers['Last Name']!.text,
                                          phone: controllers['Phone']!.text,
                                          city: controllers['City']!.text,
                                          country: controllers['Country']!.text,
                                          role: selectedRole,
                                          bio: controllers['Bio']!.text,
                                          image: imageFile,
                                        );
                                      } else {
                                        print("Error: Form validation failed.");
                                      }
                                    },
                                    backgroundColor: AppColors.color2,
                                    borderColor: Colors.transparent,
                                    textStyle: AppTextStyles.buttonText,
                                  ),
                            const SizedBox(height: 80),
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
                                    fontSize: 16,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Go to Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.color3,
                                        fontSize: 17,
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
    );
  }
}
