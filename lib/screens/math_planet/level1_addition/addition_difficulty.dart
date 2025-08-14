import 'package:flutter/material.dart';
import 'addition_page.dart';

class AdditionDifficultyPage extends StatelessWidget {
  const AdditionDifficultyPage({super.key});

  void _start(
      BuildContext context, {
        required int maxA,
        required int maxB,
        required int visualizeUpTo,
        required List<String> objectAssets
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdditionLevelPage(
          maxA: maxA,
          maxB: maxB,
          targetCorrect: 6,
          objectAssets: objectAssets,
          objectSize: 56,
          distinctSides: true,
          changeAssetsEveryQuestion: true,
          visualizeUpTo: visualizeUpTo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Toplama • Zorluk Seviyesi",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _start(
                      context,
                      maxA: 10,
                      maxB: 10,
                      visualizeUpTo: 10,
                      objectAssets: const [
                        'assets/images/planet3/meteor.png',
                        'assets/images/planet3/asteroid.png',
                         'assets/images/planet3/monster.png',
                        'assets/images/planet3/planet.png',
                        'assets/images/planet3/alien.png',
                        'assets/images/planet3/ship.png',
                        'assets/images/planet3/space.png',
                        'assets/images/planet3/star.png',
                      ],
                    ),
                    child: const Text("Kolay (Görselli)"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _start(
                      context,
                      maxA: 50,
                      maxB: 50,
                      visualizeUpTo: 0,
                      objectAssets: const [],
                    ),
                    child: const Text("Orta"),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _start(
                      context,
                      maxA: 100,
                      maxB: 100,
                      visualizeUpTo: 0,
                      objectAssets: const [],
                    ),
                    child: const Text("Zor"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
