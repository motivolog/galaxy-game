import 'package:flutter/material.dart';
import 'level1/meteor_quiz_page.dart';

class LevelSelectMathScreen extends StatelessWidget {
  const LevelSelectMathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          children: [
            _LevelCard(
              title: "Level 1",
              subtitle: "Meteor Quiz",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeteorQuizPage()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade800,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
