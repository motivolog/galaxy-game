import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/spinning_planet.dart';
import '../../widgets/spinning_sound_planet.dart';
import '../matchplanet/level_select_screen.dart';
import 'package:flutter_projects/screens/soundplanet/level_select_sound.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playWelcomeAudio();
  }

  Future<void> _playWelcomeAudio() async {
    await _audioPlayer.play(AssetSource('audio/hosgeldin.mp3'));
  }

  Future<void> _playGezegenAudio() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(
      AssetSource('audio/eslestirme_gezegeni.mp3'),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<void> _navigateToLevelSelect() async {
     _playGezegenAudio();
     await Future.delayed(const Duration(
         seconds: 4));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Lottie.asset(
              'assets/animations/space_animation.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. GEZEGEN – EŞLEŞTİRME (Animasyonlu)
                  GestureDetector(
                    onTap: () async {
                      await _audioPlayer.stop();
                      await _audioPlayer.play(
                        AssetSource('audio/eslestirme_gezegeni.mp3'),
                      );
                      await Future.delayed(const Duration(seconds: 3));
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                      );
                    },
                    child: const SpinningPlanet(),
                  ),

                  const SizedBox(height: 40),

                  // 2. GEZEGEN – BU NEYİN SESİ
                  GestureDetector(
                    onTap: () async {
                      await _audioPlayer.stop();
                      await _audioPlayer.play(
                        AssetSource('audio/ses_gezegeni.mp3'),
                      );
                      await Future.delayed(const Duration(seconds: 3));
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LevelSelectSoundScreen()),
                      );
                    },
                    child: const SpinningSoundPlanet(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
