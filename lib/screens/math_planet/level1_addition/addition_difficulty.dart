import 'package:flutter/material.dart';
import 'addition_page.dart';

class AdditionDifficultyPage extends StatelessWidget {
  const AdditionDifficultyPage({super.key});

  void _start(
      BuildContext context, {
        required int maxA,
        required int maxB,
        required int visualizeUpTo,
        required List<String> objectAssets,
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
    final media = MediaQuery.of(context);
    final shortest = media.size.shortestSide;
    final isTablet = shortest >= 600;

    final scale = isTablet ? 1.8 : 1.0;

    final titleSize = (22.0 * scale).clamp(22.0, 48.0);
    final buttonHeight = (56.0 * scale).clamp(56.0, 100.0);
    final buttonTextSize = (16.0 * scale).clamp(16.0, 34.0);
    final verticalGapLarge = (24.0 * scale).clamp(24.0, 54.0);
    final verticalGap = (12.0 * scale).clamp(12.0, 34.0);
    final radius = Radius.circular((22.0 * scale).clamp(22.0, 44.0));
    final maxContentWidth = isTablet ? 800.0 : 420.0;
    final horizontalPadding = EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: horizontalPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Toplama - Zorluk Seviyesi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: verticalGapLarge),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(radius),
                        ),
                      ),
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
                      child: Text(
                        "Kolay (Görselli)",
                        style: TextStyle(fontSize: buttonTextSize, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalGap),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(radius),
                        ),
                      ),
                      onPressed: () => _start(
                        context,
                        maxA: 50,
                        maxB: 50,
                        visualizeUpTo: 0,
                        objectAssets: const [],
                      ),
                      child: Text(
                        "Orta",
                        style: TextStyle(fontSize: buttonTextSize, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalGap),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(radius),
                        ),
                      ),
                      onPressed: () => _start(
                        context,
                        maxA: 100,
                        maxB: 100,
                        visualizeUpTo: 0,
                        objectAssets: const [],
                      ),
                      child: Text(
                        "Zor",
                        style: TextStyle(fontSize: buttonTextSize, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
