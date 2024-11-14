import 'dart:io';
import 'package:book/constants/styles.dart';
import 'package:book/providers/signup_provider.dart';
import 'package:book/screens/login_screen.dart';
import 'package:book/widgets/modal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String selectedRole = 'AUTHOR'; // Default role
  File? imageFile; // To store the selected image file

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path); // Save the selected image
      });
    }
  }

  // Show success or error dialog
 

void _showResponseDialog(BuildContext context, String message, String buttonText, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomMessageModal(
          message: message,
          buttonText: buttonText,
          type: isSuccess ? 'success' : 'error', // Set type based on success or error
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: AppColors.color5,
      ),
      body: Consumer<SignupProvider>(
        builder: (context, signupProvider, child) {
          // Display dialog based on success or error message
          if (signupProvider.successMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showResponseDialog(context,"you are registered successfully please login now", "login",true);
              signupProvider.notifyListeners(); // Reset the message
            });
          } else if (signupProvider.errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showResponseDialog(context,"please fill the form correctly", "Retry",false);
              signupProvider.notifyListeners(); // Reset the message
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign up for an account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.color3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(fnameController, 'First Name'),
                    const SizedBox(height: 20),
                    _buildTextField(lnameController, 'Last Name'),
                    const SizedBox(height: 20),
                    _buildTextField(emailController, 'Email'),
                     const SizedBox(height: 20),
                    _buildTextField(passwordController, 'password'),
                    const SizedBox(height: 20),
                    _buildTextField(phoneController, 'Phone'),
                    const SizedBox(height: 20),
                    _buildTextField(cityController, 'City'),
                    const SizedBox(height: 20),
                    _buildTextField(countryController, 'Country'),
                    const SizedBox(height: 20),
                    _buildTextField(bioController, 'Bio'),
                    const SizedBox(height: 20),

                    // Role Selection
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                      items: <String>['AUTHOR', 'USER']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Who Are U?',
                        labelStyle: TextStyle(color: AppColors.color3),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image Upload Button
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(imageFile == null ? 'Upload Image' : 'Change Image'),
                    ),
                    const SizedBox(height: 20),

                    // Image preview (optional)
                    imageFile != null
                        ? Image.file(imageFile!, height: 100, width: 100)
                        : const Text('No image selected'),

                    const SizedBox(height: 20),

                    // Show loading spinner if the provider is loading
                    signupProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Call signup method from SignupProvider
                                signupProvider.signup(
                                  email: emailController.text,
                                  password: passwordController.text, // You can add password logic here
                                  fname: fnameController.text,
                                  lname: lnameController.text,
                                  phone: phoneController.text,
                                  city: cityController.text,
                                  country: countryController.text,
                                  role: selectedRole,
                                  bio: bioController.text,
                                  image: imageFile,
                                );
                              }
                            },
                            child: const Text('Sign Up'),
                          ),
                          TextButton(
              onPressed: () {
                // Navigate to LoginScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                "Already have an account? Go to Login",
                style: TextStyle(color: Colors.blue),
              ),
            ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Utility function for form fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AppColors.color3),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.color3),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
