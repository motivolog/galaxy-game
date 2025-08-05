import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'question.dart';
import 'package:flutter_projects/screens/soundplanet/level_select_sound.dart';


class Level1 extends StatefulWidget {
  const Level1({super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _neyinSesiPlayer = AudioPlayer();
  final AudioPlayer _congratsPlayer = AudioPlayer(); // 🎉 kutlama player'ı

  int _currentQuestionIndex = 0;
  bool _answered = false;
  bool _neyinSesiBekleniyor = false;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _prepareLevel();
  }

  Future<void> _prepareLevel() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _playSoundWithPrompt();
  }

  Future<void> _playSoundWithPrompt() async {
    await _audioPlayer.stop();
    await _neyinSesiPlayer.stop();

    await _audioPlayer.play(
      UrlSource(soundQuestions[_currentQuestionIndex]['sound']),
    );

    if (_currentQuestionIndex == 0) {
      _neyinSesiBekleniyor = true;
      await Future.delayed(const Duration(seconds: 2));

      if (_neyinSesiBekleniyor) {
        await _neyinSesiPlayer.play(AssetSource('audio/neyin_sesi.mp3'));
      }
    }
  }

  Future<void> _handleAnswer(String selectedImage) async {
    if (_answered) return;

    _neyinSesiBekleniyor = false;
    await _neyinSesiPlayer.stop();

    final question = soundQuestions[_currentQuestionIndex];
    final correct = question['correct'];

    if (p.basename(selectedImage) == p.basename(correct)) {
      await _audioPlayer.stop();

      setState(() => _answered = true);

      final correctSound = question['correct_sound'];
      if (correctSound != null) {
        await _audioPlayer.play(AssetSource(correctSound));
        await _audioPlayer.onPlayerComplete.first;
      }

      if (!mounted) return;
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
      });

      if (_currentQuestionIndex >= soundQuestions.length) {
        setState(() {
          _showCelebration = true;
        });
      } else {
        Future.microtask(() => _playSoundWithPrompt());
      }
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/game2_tekrar_dene.mp3'));
      await _audioPlayer.onPlayerComplete.first;
      if (mounted) setState(() => _answered = false);
    }
  }

  Future<void> _playCelebrationAndExit() async {
    await _congratsPlayer.setReleaseMode(ReleaseMode.stop);
    await _congratsPlayer.play(AssetSource('audio/vehicle/sci-fi.mp3'));
    await Future.delayed(const Duration(seconds: 4));
    await _congratsPlayer.stop();
    await _congratsPlayer.dispose();

    if (mounted) {
      Navigator.pop(context); // Oyun sonrası geri dönüş
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _neyinSesiPlayer.dispose();
    _congratsPlayer.dispose();
    super.dispose();
  }

  Widget _buildImage(String imagePath, {required double size}) {
    return GestureDetector(
      onTap: () => _handleAnswer(imagePath),
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCelebration) {
      _congratsPlayer.setReleaseMode(ReleaseMode.loop);
      _congratsPlayer.play(AssetSource('audio/vehicle/sci-fi.mp3'));

      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            _congratsPlayer.stop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LevelSelectSoundScreen(incomingPlayer: _congratsPlayer),
              ),
            );
          },

          child: Center(
            child: Lottie.asset(
              'assets/animations/alien_transition.json',
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              repeat: true,
            ),
          ),
        ),
      );
    }


    final question = soundQuestions[_currentQuestionIndex];
    final options = question['options'] as List;

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final cardSize = isPortrait ? shortestSide * 0.45 : shortestSide * 0.50;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/gif/back.gif',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildImage(options[0], size: cardSize),
                            _buildImage(options[1], size: cardSize),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildImage(options[2], size: cardSize),
                        const SizedBox(height: 80),
                      ],
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: options
                            .map<Widget>((img) => _buildImage(img, size: cardSize))
                            .toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  if (_currentQuestionIndex > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentQuestionIndex--;
                          _answered = false;
                        });
                        _playSoundWithPrompt();
                      },
                      child: Image.asset(
                        'assets/images/planet2/back_arrow.png',
                        width: 55,
                        height: 55,
                      ),
                    )
                  else
                    const SizedBox(width: 55),
                  GestureDetector(
                    onTap: _playSoundWithPrompt,
                    child: Image.asset(
                      'assets/images/planet2/sound_button.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
