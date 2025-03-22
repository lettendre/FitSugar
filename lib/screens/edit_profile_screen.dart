import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsugar/services/auth_service.dart';
import 'package:fitsugar/screens/login_screen.dart';
import 'package:fitsugar/screens/dashboard_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      // Set background color to match your brand color (pink/red)
      backgroundColor: const Color(0xFFE83A5F), // You may need to adjust this color code to match exactly
      body: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)), // Simulate loading
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<User?>(
              stream: authService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final user = snapshot.data;
                  if (user != null) {
                    return const DashboardScreen();
                  } else {
                    return const LoginScreen();
                  }
                }
                // Show the splash logo instead of circular indicator
                return _buildSplashContent();
              },
            );
          }
          // Show the splash logo instead of circular indicator
          return _buildSplashContent();
        },
      ),
    );
  }

  // Create a method to show your splash screen content
  Widget _buildSplashContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Your logo from the image
          Image(
            image: AssetImage('assets/images/logo_white.png'), // Make sure this asset exists
            width: 80, // Adjust size as needed
            height: 80,
          ),
          // You can add other elements like app name if needed
          // SizedBox(height: 16),
          // Text(
          //   'FitSugar',
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),
    );
  }
}