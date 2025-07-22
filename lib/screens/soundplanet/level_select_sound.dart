import 'package:flutter/material.dart';
import 'level1.dart';

class LevelSelectSoundScreen extends StatelessWidget {
  const LevelSelectSoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/gif/bgg.gif',
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: Semantics(
                label: 'Seviye 1: Hayvan Sesleri',
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SoundLevel1()),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 230,
                      height: 230,
                      child: Image.asset(
                        'assets/images/soundplanet1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
