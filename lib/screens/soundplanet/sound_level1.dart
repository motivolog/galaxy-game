import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'question_data.dart';

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
    _playSoundWithPrompt();
  }

  Future<void> _playSoundWithPrompt() async {
    await _audioPlayer.stop();

    // 1️⃣ Hayvan sesi
    await _audioPlayer.play(
      UrlSource(soundQuestions[_currentQuestionIndex]['sound']),
    );

    // 2️⃣ Bekleme + Yönlendirme sesi
    await Future.delayed(const Duration(seconds: 3));
    await _audioPlayer.play(
      AssetSource('audio/neyin_sesi.mp3'),
    );
  }

  Future<void> _handleAnswer(String selectedImage) async {
    if (_answered) return;

    setState(() {
      _answered = true;
    });

    final question = soundQuestions[_currentQuestionIndex];
    final correct = question['correct'];

    if (selectedImage == correct) {
      final correctSound = question['correct_sound'] ?? 'audio/tebrikler.mp3';
      await _audioPlayer.play(AssetSource(correctSound));


      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      setState(() {
        _currentQuestionIndex++;
        _answered = false;
      });

      if (_currentQuestionIndex < soundQuestions.length) {
        _playSoundWithPrompt();
      }
    } else {
      await _audioPlayer.play(AssetSource('audio/game2_tekrar_dene.mp3'));
      await _audioPlayer.onPlayerComplete.first;

      if (mounted) {
        setState(() {
          _answered = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildImage(String imagePath) {
    return GestureDetector(
      onTap: () => _handleAnswer(imagePath),
      child: Image.asset(
        imagePath,
        width: 190,
        height: 190,
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
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;

            final question = soundQuestions[_currentQuestionIndex];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPortrait) ...[
                  // DİKEY GÖRÜNÜM
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImage(question['options'][0]),
                      const SizedBox(width: 20),
                      _buildImage(question['options'][1]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildImage(question['options'][2]),
                ] else ...[
                  // YATAY GÖRÜNÜM
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImage(question['options'][0]),
                      const SizedBox(width: 20),
                      _buildImage(question['options'][1]),
                      const SizedBox(width: 20),
                      _buildImage(question['options'][2]),
                    ],
                  ),
                ],

                const SizedBox(height: 40),
                IconButton(
                  onPressed: _playSoundWithPrompt,
                  icon: const Icon(
                    Icons.volume_up,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),

    );
  }
}