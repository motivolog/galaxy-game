import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class LevelSelectMathScreen extends StatelessWidget {
  final AudioPlayer incomingPlayer;

  const LevelSelectMathScreen({super.key, required this.incomingPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matematik Gezegeni'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Matematik seviyeleri buraya gelecek 🎯',
              style: TextStyle(fontSize: 24),
            ),
            // Buraya seviyeleri (level buttons) ekleyeceğiz...
          ],
        ),
      ),
    );
  }
}
