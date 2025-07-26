import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;
import 'question.dart';
import 'celebration.dart';
import '../soundplanet/level_select_sound.dart';



class SoundLevel1 extends StatefulWidget {
  const SoundLevel1({super.key});

  @override
  State<SoundLevel1> createState() => _SoundLevel1State();
}

class _SoundLevel1State extends State<SoundLevel1> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentQuestionIndex = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    LevelSelectSoundScreen.introPlayer.pause(); // önce pause
    LevelSelectSoundScreen.introPlayer.stop(); // 🔇 eklenen satır
    _playSoundWithPrompt(); // mevcut fonksiyonun
  }


  Future<void> _playSoundWithPrompt() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(soundQuestions[_currentQuestionIndex]['sound']));


    if (_currentQuestionIndex == 0) {
      await Future.delayed(const Duration(seconds: 3));
      await _audioPlayer.play(AssetSource('audio/neyin_sesi.mp3'));
    }
  }

  Future<void> _handleAnswer(String selectedImage) async {
    if (_answered) return;
    setState(() => _answered = true);

    final question = soundQuestions[_currentQuestionIndex];
    final correct = question['correct'];



    if (p.basename(selectedImage) == p.basename(correct)) {
      final correctSound = question['correct_sound'];
      if (correctSound != null) {
        await _audioPlayer.play(AssetSource(correctSound));
        await _audioPlayer.onPlayerComplete.first;
      }

      await Future.delayed(const Duration(milliseconds: 20));

      if (!mounted) return;
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
      });

      if (_currentQuestionIndex >= soundQuestions.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showSoundPlanetCelebration(context);
        });
      } else {
        _playSoundWithPrompt();
      }
    } else {
      print("❌ YANLIŞ CEVAPLANDI");
      await _audioPlayer.play(AssetSource('audio/game2_tekrar_dene.mp3'));
      await _audioPlayer.onPlayerComplete.first;
      if (mounted) setState(() => _answered = false);
    }
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
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
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= soundQuestions.length) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Tüm sorular bitti!",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      );
    }

    final question = soundQuestions[_currentQuestionIndex];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/gif/back.gif',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isPortrait = orientation == Orientation.portrait;
                  final double cardSize = isPortrait ? 180 : 230;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isPortrait) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildImage(question['options'][0], size: cardSize),
                            _buildImage(question['options'][1], size: cardSize),
                          ],
                        ),
                        _buildImage(question['options'][2], size: cardSize),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildImage(question['options'][0], size: cardSize),
                            _buildImage(question['options'][1], size: cardSize),
                            _buildImage(question['options'][2], size: cardSize),
                          ],
                        ),
                      ],
                      const SizedBox(height: 30),
                      IconButton(
                        onPressed: _playSoundWithPrompt,
                        icon: const Icon(
                          Icons.volume_up,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
