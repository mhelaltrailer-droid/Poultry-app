import 'package:flutter/material.dart';

class BrandSplashScreen extends StatelessWidget {
  const BrandSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: const SafeArea(
        child: SizedBox.expand(
          child: Image(
            image: AssetImage('assets/images/splash_day_to_day.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
