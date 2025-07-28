import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'level1.dart';

class LevelSelectSoundScreen extends StatefulWidget {
  final AudioPlayer incomingPlayer;

  const LevelSelectSoundScreen({super.key, required this.incomingPlayer});

  @override
  State<LevelSelectSoundScreen> createState() => _LevelSelectSoundScreenState();
}

class _LevelSelectSoundScreenState extends State<LevelSelectSoundScreen> {
  bool _navigated = false;

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

  Future<void> _stopAndNavigate() async {
    if (_navigated) return;
    _navigated = true;

    await widget.incomingPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SoundLevel1()),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                  onTap: _stopAndNavigate,
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