import 'package:bookreader/constants/size.dart';
import 'package:bookreader/exports.dart';
// Add your Forgot Password Screen import
import 'package:bookreader/widgets/custom_button.dart';
import 'package:bookreader/widgets/custom_text_field.dart';
import 'package:bookreader/widgets/modal.dart';
import 'package:bookreader/widgets/square_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/services/device_info.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;

  String? deviceName;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  Map<String, dynamic> _deviceData = {};
  String _getDeviceType(BuildContext context) {
    return _deviceInfoService.detectDeviceType(context);
  }

  Future<void> _getDeviceInfo() async {
    final deviceData = await _deviceInfoService.getDeviceData();
    setState(() {
      _deviceData = deviceData;
    });
    String brand = _deviceData['brand'] ?? 'Unknown';
    String board = _deviceData['board'] ?? 'Unknown';
    String model = _deviceData['model'] ?? 'Unknown';
    String deviceId = _deviceData['id'] ?? 'Unknown';
    String deviceType = _getDeviceType(context);
    deviceName =
        "Brand: $brand Board: $board Model: $model deviceId: $deviceId DeviceType: $deviceType";
    // print('device information is: $deviceName');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginProvider>(context, listen: false)
          .addListener(_handleLoginResponse);
    });
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
          type: isSuccess ? 'success' : 'error',
          onClose: () {
            Navigator.of(context).pop();
            if (isSuccess) {
              context.go('/home');
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    loginProvider.removeListener(_handleLoginResponse);

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLoginResponse() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    // Handle successful login
    if (loginProvider.successMessage.isNotEmpty &&
        loginProvider.isAuthenticated) {
      _showResponseDialog(
        context,
        loginProvider.successMessage,
        "Close",
        true,
      );
      loginProvider.clearMessages();
    }
    // Handle 2FA requirement
    else if (loginProvider.is2FARequired &&
        loginProvider.errorMessage.isNotEmpty) {
      _showResponseDialog(
        context,
        'You need to set up a two-factor authentication code. Check your email for the code.',
        "Close",
        false,
      );
      loginProvider.clearMessages();
      // Navigate to OTP screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
    }
    // Handle account deactivation
    else if (loginProvider.isAccountDeactivated &&
        loginProvider.errorMessage.isNotEmpty) {
      _showResponseDialog(
        context,
        'Your account has been deactivated. Please contact support.',
        "Close",
        false,
      );
      loginProvider.clearMessages();
    }
    // Handle email verification required
    else if (loginProvider.isEmailVerificationRequired &&
        loginProvider.errorMessage.isNotEmpty) {
      _showResponseDialog(
        context,
        'Please verify your email address. Check your inbox for the verification link.',
        "Close",
        false,
      );
      loginProvider.clearMessages();
    }
    // Handle errors during login
    else if (loginProvider.errorMessage.isNotEmpty) {
      _showResponseDialog(
        context,
        loginProvider.errorMessage,
        "Retry",
        false,
      );
      loginProvider.clearMessages();
    }
  }

  String? _validateField(String key, String value) {
    if (value.isEmpty) {
      return 'Please enter your $key';
    }
    if (key == 'email') {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }
    }
    if (key == 'password' && value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    return null; // No errors
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final authprovider = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.color1,
                  AppColors.color2,
                ]),
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(top: height * 0.09, left: width * 0.36),
                child: const Text(
                  'Login',
                  style: AppTextStyles.heading1,
                ),
              ),
            ),
            // Login form container
            Padding(
              padding: EdgeInsets.only(top: height * 0.25),
              child: Container(
                height: height * .8,
                width: width,
                decoration: const BoxDecoration(
                  color: AppColors.color1,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.055),
                    child: Consumer<LoginProvider>(
                      builder: (context, loginProvider, child) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Email field
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: "Enter your Email",
                                icon: Icons.email,
                                validator: (value) =>
                                    _validateField('email', value!),
                              ),
                              SizedBox(height: height * 0.02),
                              // Password field
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: "Enter your password",
                                suffixIcon: IconButton(
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
                                ),
                                obscureText: _hidePassword,
                                validator: (value) =>
                                    _validateField('password', value!),
                              ),
                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.color3,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              // Login button
                              loginProvider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)))
                                  : CustomButton(
                                      text: 'LOGIN',
                                      onPressed: () async {
                                        await _getDeviceInfo();
                                        if (_formKey.currentState!.validate()) {
                                          loginProvider.login(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                            deviceName,
                                          );
                                        }
                                        _handleLoginResponse();
                                      },
                                      backgroundColor: AppColors.color2,
                                      borderColor: AppColors.color3,
                                      textStyle: AppTextStyles.buttonText,
                                    ),
                              SizedBox(height: height * 0.07),
                              // Social Login Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SquareTile(
                                    imagePath: 'assets/images/g_logo.png',
                                    onTap: () async {
                                      await authprovider.loginWithGoogle();

                                      if (authprovider.isAuthenticated) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          context.go('/home');
                                        });
                                      } else {
                                        _handleLoginResponse();
                                      }
                                    },
                                  ),
                                  SizedBox(width: width * 0.1),
                                  SquareTile(
                                    imagePath: 'assets/images/fb_logo.png',
                                    onTap: () async {
                                      await authprovider.loginWithFacebook();
                                      if (authprovider.isAuthenticated) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          context.go('/home');
                                        });
                                      } else {
                                        _handleLoginResponse();
                                      }
                                    },
                                  )
                                ],
                              ),
                              SizedBox(height: height * 0.06),
                              // Signup prompt
                              TextButton(
                                onPressed: () {
                                  context.push('/signup');
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Don\'t have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: width * 0.045,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.color3,
                                          fontSize: width * .055,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
