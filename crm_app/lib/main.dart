import 'package:crm_app/Controller/login_page.dart';
import 'package:crm_app/utilities/user_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
// Define the custom colors based on the logo
const Color kPrimaryBlue = Color(0xFF1D648B); // The blue from the logo
const Color kDarkText = Color(0xFF333333); // The dark grey from the logo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void checkUserLogin() async {
    final user = await UserLocalStorage.getSavedUser();

    if (user != null) {
      // Already logged in
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reach Login',
      theme: ThemeData(
        // Set the primary theme color to the logo's blue
        primarySwatch: const MaterialColor(0xFF1D648B, <int, Color>{
          50: Color(0xFFE4E9EC),
          100: Color(0xFFBCC6CF),
          200: Color(0xFF90A0B0),
          300: Color(0xFF637B91),
          400: Color(0xFF425E7B),
          500: Color(0xFF1D648B), // Primary Blue
          600: Color(0xFF195C81),
          700: Color(0xFF135175),
          800: Color(0xFF0F476A),
          900: Color(0xFF083556),
        }),
        // Use a light theme
        brightness: Brightness.light,
        // Set the default elevated button style to use the primary blue
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Set the input field decoration
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kPrimaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kPrimaryBlue, width: 2.0),
          ),
          labelStyle: const TextStyle(color: kDarkText),
        ),
      ),
      home: const LoginPage(),
    );
  }
}


