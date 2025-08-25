import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/spinning_planet.dart';
import '../../widgets/spinning_sound_planet.dart';
import '../../widgets/spinning_math_planet.dart';
import '../matchplanet/level_select_screen.dart';
import '../math_planet/level_select_math.dart';
import '../soundplanet/level_select_sound.dart';
import '../../analytics_helper.dart';

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

    // ANALYTICS: Home ekranı görüntülendi + süre ölçümü
    ALog.screen('home');
    ALog.startTimer('screen:home');
  }

  Future<void> _playWelcomeAudio() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/hosgeldin.mp3'));
  }

  Future<void> _playGezegenAudio() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/eslestirme_gezegeni.mp3'));
  }

  @override
  void dispose() {
    // ANALYTICS: Home ekranında geçirilen süreyi bitir
    ALog.endTimer('screen:home');

    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _goToMatchPlanet() async {
    // ANALYTICS: Tıklama + gezegen açılışı
    ALog.tap('open_match', place: 'home');
    ALog.planetOpened('match');

    await _audioPlayer.stop();
    await _playGezegenAudio();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(homePlayer: _audioPlayer),
      ),
    );
  }

  Future<void> _goToSoundPlanet() async {
    ALog.tap('open_sound', place: 'home');
    ALog.planetOpened('sound');

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/ses_gezegeni.mp3'));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelSelectSoundScreen(incomingPlayer: _audioPlayer),
      ),
    );
  }

  Future<void> _goToMathPlanet() async {
    ALog.tap('open_math', place: 'home');
    ALog.planetOpened('math');

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/mathplanet/math_planet.mp3'));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelSelectMathScreen(incomingPlayer: _audioPlayer),
      ),
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
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: _goToMatchPlanet,
                    child: const SpinningPlanet(),
                  ),
                  const SizedBox(width: 50),
                  GestureDetector(
                    onTap: _goToSoundPlanet,
                    child: const SpinningSoundPlanet(),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: _goToMathPlanet,
                    child: const SpinningMathPlanet(),
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
