import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'level1.dart';
import 'level2.dart';
import 'package:lottie/lottie.dart';

class LevelSelectSoundScreen extends StatefulWidget {
  final AudioPlayer incomingPlayer;

  const LevelSelectSoundScreen({super.key, required this.incomingPlayer});

  @override
  State<LevelSelectSoundScreen> createState() =>
      _LevelSelectSoundScreenState();
}

class _LevelSelectSoundScreenState extends State<LevelSelectSoundScreen> {
  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await widget.incomingPlayer.play(
      AssetSource('audio/hosgeldin_ses_gezegeni.mp3'),
    );
  }

  @override
  void dispose() {
    widget.incomingPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final double buttonSize = shortestSide * 0.65;

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
            Positioned(
              top: 20,
              left: 10,
              child: GestureDetector(
                onTap: () async {
                  await widget.incomingPlayer.stop();
                  Navigator.pop(context);
                },
                child: Lottie.asset(
                  'assets/animations/back_arrow.json',
                  width: 70,
                  height: 70,
                  repeat: true,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16), // Sol boşluk
                    _buildLevelButton(
                      label: 'Seviye 1: Hayvan Sesleri',
                      imagePath: 'assets/images/soundplanet1.png',
                      onTap: () async {
                        await widget.incomingPlayer.stop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Level1(),
                          ),
                        );
                      },
                      size: buttonSize,
                    ),
                    const SizedBox(width: 32),
                    _buildLevelButton(
                      label: 'Seviye 2: Taşıt Sesleri',
                      imagePath: 'assets/images/soundplanet2.png',
                      onTap: () async {
                        await widget.incomingPlayer.stop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Level2(),
                          ),
                        );
                      },
                      size: buttonSize,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton({
    required String label,
    required String imagePath,
    required VoidCallback onTap,
    required double size,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
