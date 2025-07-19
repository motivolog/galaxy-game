import 'package:flutter/material.dart';
import 'level1.dart';

class LevelSelectSoundScreen extends StatelessWidget {
  const LevelSelectSoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka planı artık dekorasyonla verdiğimiz için renk gerekmiyor
      body: SafeArea(
        child: Stack(
          children: [
            /* --- Lacivert arka plan + silik desenler --- */
            Positioned.fill(
              child: Image.asset(
                'assets/images/levelsecsound_bg.png',   // ← arkaplan görseliniz
                fit: BoxFit.cover,
              ),
            ),

            /* --- Merkezde seviye butonu --- */
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
