import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsugar/services/auth_service.dart';
import 'package:fitsugar/services/connectivity_service.dart';
import 'package:fitsugar/screens/login_screen.dart';
import 'package:fitsugar/screens/dashboard_screen.dart';
import 'package:fitsugar/screens/no_wifi_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    //start loading after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  //check authentication and prepare navigation
  Future<void> _checkAuthAndNavigate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

    //check connectivity
    await connectivityService.checkConnectivity();

    //2 second wait for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!connectivityService.isConnected) {
      setState(() {
        _nextScreen = const NoWifiScreen();
        _isLoading = false;
      });
      return;
    }

    //getter for current user
    try {
      final User? user = await authService.authStateChanges.first;
      setState(() {
        _nextScreen = user != null ? const DashboardScreen() : const LoginScreen();
        _isLoading = false;
      });
    } catch (e) {
      print('Error during auth check: $e');
      setState(() {
        _nextScreen = const LoginScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //recognise connectivity changes
    final connectivity = Provider.of<ConnectivityService>(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _isLoading
          ? _buildSplashScreen()
          : !connectivity.isConnected && _nextScreen != const NoWifiScreen()
          ? const NoWifiScreen()
          : _nextScreen,
    );
  }

  //splash screen
  Widget _buildSplashScreen() {
    return Scaffold(
      key: const ValueKey<String>('splashScreen'),
      backgroundColor: Colors.pink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage('assets/logo_white.png'),
              width: 80,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}