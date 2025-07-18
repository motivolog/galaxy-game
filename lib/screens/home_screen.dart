import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/spinning_planet.dart';
import '../widgets/spinning_sound_planet.dart';
import 'level_select_screen.dart';
import 'package:flutter_projects/screens/soundplanet/soundplanet_game.dart';


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

  /* --------- Açılış “Hoş geldin” sesi --------- */
  Future<void> _playWelcomeAudio() async {
    await _audioPlayer.play(AssetSource('audio/hosgeldin.mp3'));
  }

  /* --------- Gezegen tıklanınca çalınacak ses --------- */
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

  /* --------- Gezegen → Seviye Seç ekranı --------- */
  Future<void> _navigateToLevelSelect() async {
     _playGezegenAudio();
     await Future.delayed(const Duration(
         seconds: 4));                          // 2) Yalnızca 2 sn bekle
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
    );
  }

  /* ----------------- build ----------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /* Animasyonlu galaksi arka planı */
          SizedBox.expand(
            child: Lottie.asset(
              'assets/animations/space_animation.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          /* Ortada dönen gezegen */
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

                  // 2. GEZEGEN – BU NEYİN SESİ (Düz PNG)
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
                        MaterialPageRoute(builder: (_) => const SoundPlanetGame()),
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
