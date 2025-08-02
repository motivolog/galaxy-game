import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
          body: Image.asset(
            'assets/gif/intro_space.gif',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
      ),
    );
  }
}
