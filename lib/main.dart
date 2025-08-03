import 'package:flutter/material.dart';
import 'screens/home/intro_screen.dart';

void main() {
  runApp(const GalaksimdeOgreniyorumApp());
}

class GalaksimdeOgreniyorumApp extends StatelessWidget {
  const GalaksimdeOgreniyorumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galaksimde Öğreniyorum',
      theme: ThemeData.dark(),
      home: const IntroScreen(),
    );
  }
}
