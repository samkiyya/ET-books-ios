import 'package:book/constants/styles.dart';
import 'package:book/providers/login_provider.dart';
import 'package:book/providers/signup_provider.dart';
import 'package:book/screens/home_screen.dart';
import 'package:book/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        // You can add more providers here in the list
        ChangeNotifierProvider(create: (context) => SignupProvider()),
       ChangeNotifierProvider(create: (context) => LoginProvider()),
        // Other providers can be added like:
        // ChangeNotifierProvider(create: (context) => AnotherProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Signup',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.color1),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.color1,  // Set background color of the entire app
        ),
        home: HomeScreen(),  // Set SplashScreen as the home page
      ),
    );
  }
}
