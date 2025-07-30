import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;

final List<Map<String, dynamic>> vehicleQuestions = [
  {
    'sound': 'audio/vehicle/train.mp3',
    'correct': 'assets/images/planet2/train.png',
    'correct_sound': 'audio/vehicle/correct_train.mp3',
    'hint': 'audio/vehicle/hint_train.mp3',
    'options': [
      'assets/images/planet2/train.png',
      'assets/images/planet2/tractor.png',
      'assets/images/planet2/helicopter.png',
    ],
  },
  {
    'sound': 'audio/vehicle/motorcycle.mp3',
    'correct': 'assets/images/planet2/motorcycle.png',
    'correct_sound': 'audio/vehicle/correct_motorcycle.mp3',
    'hint': 'audio/vehicle/hint_motorcycle.mp3',
    'options': [
      'assets/images/planet2/motorcycle.png',
      'assets/images/planet2/tram.png',
      'assets/images/planet2/submarine.png',
    ],
  },

  {
    'sound': 'audio/vehicle/helicopter.mp3',
    'correct': 'assets/images/planet2/helicopter.png',
    'correct_sound': 'audio/vehicle/correct_helicopter.mp3',
    'hint': 'audio/vehicle/hint_helicopter.mp3',
    'options': [
      'assets/images/planet2/helicopter.png',
      'assets/images/planet2/train.png',
      'assets/images/planet2/motorcycle.png',
    ],
  },
  {
    'sound': 'audio/vehicle/submarine.mp3',
    'correct': 'assets/images/planet2/submarine.png',
    'correct_sound': 'audio/vehicle/correct_submarine.mp3',
    'hint': 'audio/vehicle/hint_submarine.mp3',
    'options': [
      'assets/images/planet2/submarine.png',
      'assets/images/planet2/ship.png',
      'assets/images/planet2/firetruck.png',
    ],
  },
  {
    'sound': 'audio/vehicle/car.mp3',
    'correct': 'assets/images/planet2/car.png',
    'correct_sound': 'audio/vehicle/correct_car.mp3',
    'hint': 'audio/vehicle/hint_car.mp3',
    'options': [
      'assets/images/planet2/car.png',
      'assets/images/planet2/policecar.png',
      'assets/images/planet2/helicopter.png',
    ],
  },

  {
    'sound': 'audio/vehicle/ambulance.mp3',
    'correct': 'assets/images/planet2/ambulance.png',
    'correct_sound': 'audio/vehicle/correct_ambulance.mp3',
    'hint': 'audio/vehicle/hint_ambulance.mp3',
    'options': [
      'assets/images/planet2/airplane.png',
      'assets/images/planet2/ambulance.png',
      'assets/images/planet2/tram.png',
    ],
  },
  {
    'sound': 'audio/vehicle/tram.mp3',
    'correct': 'assets/images/planet2/tram.png',
    'correct_sound': 'audio/vehicle/correct_tram.mp3',
    'hint': 'audio/vehicle/hint_helicopter.mp3',
    'options': [
      'assets/images/planet2/car.png',
      'assets/images/planet2/tractor.png',
      'assets/images/planet2/tram.png',
    ],
  },
  {
    'sound': 'audio/vehicle/police.mp3',
    'correct': 'assets/images/planet2/policecar.png',
    'correct_sound': 'audio/vehicle/correct_policecar.mp3',
    'hint': 'audio/vehicle/hint_policecar.mp3',
    'options': [
      'assets/images/planet2/policecar.png',
      'assets/images/planet2/airplane.png',
      'assets/images/planet2/ambulance.png',
    ],
  },
  {
    'sound': 'audio/vehicle/ship.mp3',
    'correct': 'assets/images/planet2/ship.png',
    'correct_sound': 'audio/vehicle/correct_ship.mp3',
    'hint': 'audio/vehicle/hint_ship.mp3',
    'options': [
      'assets/images/planet2/train.png',
      'assets/images/planet2/ship.png',
      'assets/images/planet2/tractor.png',
    ],
  },
  {
    'sound': 'audio/vehicle/firetruck.mp3',
    'correct': 'assets/images/planet2/firetruck.png',
    'correct_sound': 'audio/vehicle/correct_firetruck.mp3',
    'hint': 'audio/vehicle/hint_firetruck.mp3',
    'options': [
      'assets/images/planet2/firetruck.png',
      'assets/images/planet2/ambulance.png',
      'assets/images/planet2/train.png',
    ],
  },
  {
    'sound': 'audio/vehicle/airplane.mp3',
    'correct': 'assets/images/planet2/airplane.png',
    'correct_sound': 'audio/vehicle/correct_airplane.mp3',
    'hint': 'audio/vehicle/hint_airplane.mp3',
    'options': [
      'assets/images/planet2/helicopter.png',
      'assets/images/planet2/airplane.png',
      'assets/images/planet2/train.png',
    ],
  },
  {
    'sound': 'audio/vehicle/tractor.mp3',
    'correct': 'assets/images/planet2/tractor.png',
    'correct_sound': 'audio/vehicle/correct_tractor.mp3',
    'hint': 'audio/vehicle/hint_tractor.mp3',
    'options': [
      'assets/images/planet2/car.png',
      'assets/images/planet2/firetruck.png',
      'assets/images/planet2/tractor.png',
    ],
  },
];

class Level2 extends StatefulWidget {
  const Level2({super.key});

  @override
  State<Level2> createState() => _Level2State();
}

class _Level2State extends State<Level2> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentQuestionIndex = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _playCurrentSound();
  }

  Future<void> _playCurrentSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(
      AssetSource(vehicleQuestions[_currentQuestionIndex]['sound']),
    );
  }

  Future<void> _playHint() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(
      AssetSource(vehicleQuestions[_currentQuestionIndex]['hint']),
    );
  }

  Future<void> _checkAnswer(String selectedImage) async {
    if (_answered) return;
    setState(() => _answered = true);

    final q = vehicleQuestions[_currentQuestionIndex];
    final correct = q['correct'];

    if (p.basename(selectedImage) == p.basename(correct)) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(q['correct_sound']));
      await _audioPlayer.onPlayerComplete.first;
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/game2_tekrar_dene.mp3'));
      await _audioPlayer.onPlayerComplete.first;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentQuestionIndex < vehicleQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
      });
      _playCurrentSound();
    } else {
      setState(() => _answered = false);
      // 🎉 Kutlama animasyonu veya bitiş ekranı buraya eklenecek
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = vehicleQuestions[_currentQuestionIndex]['options'];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/vehicle_background.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.info_outline, size: 40, color: Colors.orange),
                onPressed: _playHint,
              ),
            ),
            Center(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isPortrait = orientation == Orientation.portrait;
                  final shortestSide = MediaQuery.of(context).size.shortestSide;
                  final cardSize = isPortrait
                      ? shortestSide * 0.45
                      : shortestSide * 0.50;

                  if (isPortrait) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildOption(options[0], cardSize),
                            _buildOption(options[1], cardSize),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildOption(options[2], cardSize),
                        const SizedBox(height: 30),
                        IconButton(
                          onPressed: _playCurrentSound,
                          icon: const Icon(Icons.volume_up, size: 48, color: Colors.white),
                        ),
                      ],
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: options
                            .map<Widget>((img) => _buildOption(img, cardSize))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        onPressed: _playCurrentSound,
                        icon: const Icon(Icons.volume_up, size: 60, color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String imagePath, double size) {
    return GestureDetector(
      onTap: _answered ? null : () => _checkAnswer(imagePath),
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
