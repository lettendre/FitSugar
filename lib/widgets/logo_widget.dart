import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'logo.png',
      width: size,
      height: size,
    );
  }
}