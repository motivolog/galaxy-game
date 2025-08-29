import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'instrument_questions.dart';
import '../../analytics_helper.dart'; // ✅ Analytics

class Level3 extends StatefulWidget {
  const Level3({super.key});

  @override
  State<Level3> createState() => _Level3State();
}

class _Level3State extends State<Level3> {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  late final AudioPlayer _bgPlayer; // ✅ initState'de başlatılacak
  AudioPlayer? _congratsPlayer;

  int _currentQuestionIndex = 0;
  bool _answered = false;
  final Map<int, List<String>> _shuffledOptionsMap = {};

  // ✅ Analytics sayaçları
  final Map<int, int> _attempts = {};
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _finished = false;
  final Stopwatch _levelSW = Stopwatch();

  @override
  void initState() {
    super.initState();
    _bgPlayer = AudioPlayer(); // ✅ null hatasını önle
    _levelSW.start();          // ✅ level süresi

    _generateShuffledOptionsForIndex(_currentQuestionIndex);
    _logQuestionStart();       // ✅ ilk soru
    _playCurrentSound();
  }

  void _generateShuffledOptionsForIndex(int index) {
    if (!_shuffledOptionsMap.containsKey(index)) {
      final rawOptions = instrumentQuestions[index]['options'] as List<String>;
      final shuffled = List<String>.from(rawOptions)..shuffle();
      _shuffledOptionsMap[index] = shuffled;
    }
  }

  String _currentQId() {
    final soundPath = instrumentQuestions[_currentQuestionIndex]['sound'] as String;
    return p.basenameWithoutExtension(soundPath);
  }

  void _logQuestionStart() {
    ALog.e('sound_question_start', params: {
      'category': 'instruments',
      'q_id': _currentQId(),
    });
    _attempts[_currentQuestionIndex] = 0;
  }

  Future<void> _playCurrentSound() async {
    await _sfxPlayer.stop();
    await _sfxPlayer.play(
      AssetSource(instrumentQuestions[_currentQuestionIndex]['sound']),
    );
  }

  Future<void> _playHint() async {
    // ✅ hint (tekrar dinleme) kaydı
    ALog.e('sound_hint_used', params: {
      'category': 'instruments',
      'q_id': _currentQId(),
    });

    await _sfxPlayer.stop();
    await _sfxPlayer.play(
      UrlSource(instrumentQuestions[_currentQuestionIndex]['hint']),
    );
  }

  Future<void> _checkAnswer(String selectedImage) async {
    if (_answered) return;

    final q = instrumentQuestions[_currentQuestionIndex];
    final correct = q['correct'] as String;

    await _sfxPlayer.stop();

    final isCorrect = p.basename(selectedImage) == p.basename(correct);

    // ✅ cevap + deneme sayısı
    final attempt = (_attempts[_currentQuestionIndex] ?? 0) + 1;
    _attempts[_currentQuestionIndex] = attempt;

    ALog.e('sound_answer', params: {
      'category': 'instruments',
      'q_id': _currentQId(),
      'correct': isCorrect ? 1 : 0,
      'attempt': attempt,
    });

    if (isCorrect) {
      _correctCount++;
      _answered = true;

      await _sfxPlayer.play(AssetSource(q['correct_sound']));
      await _sfxPlayer.onPlayerComplete.first;

      if (_currentQuestionIndex < instrumentQuestions.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _generateShuffledOptionsForIndex(_currentQuestionIndex);
        });
        _logQuestionStart(); // ✅ sıradaki soru
        await _playCurrentSound();
      } else {
        // ✅ level bitti
        final timeMs = _levelSW.elapsedMilliseconds;
        _levelSW.stop();

        ALog.e('sound_level_complete', params: {
          'category': 'instruments',
          'time_ms': timeMs,
          'correct_count': _correctCount,
          'wrong_count': _wrongCount,
        });

        // level_select_sound.dart'ta başlatılan kategori zamanlayıcısını kapat
        ALog.endTimer('sound:instruments', extra: {'category': 'instruments'});

        _finished = true;
        await _showCongratulations();
        if (mounted) Navigator.of(context).pop();
      }
    } else {
      _wrongCount++;
      await _sfxPlayer.play(AssetSource('audio/game2_tekrar_dene.mp3'));
      await _sfxPlayer.onPlayerComplete.first;
    }
  }

  Future<void> _showCongratulations() async {
    _congratsPlayer = AudioPlayer();
    await _congratsPlayer!.setReleaseMode(ReleaseMode.loop);
    await _congratsPlayer!.play(AssetSource('audio/vehicle/sci-fi.mp3'));

    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _congratsPlayer?.stop();
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Lottie.asset(
              'assets/animations/alien_transition.json',
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
      ),
    ));
  }

  @override
  void dispose() {
    // ✅ yarıda çıkış
    if (!_finished) {
      final total = instrumentQuestions.length;
      int completed = _currentQuestionIndex + (_answered ? 1 : 0);
      if (completed > total) completed = total;
      final progressPct = ((completed / total) * 100).round();

      ALog.e('sound_exit', params: {
        'category': 'instruments',
        'progress_pct': progressPct,
        'reason': 'back',
      });

      ALog.endTimer('sound:instruments', extra: {'category': 'instruments'});
      _levelSW.stop();
    }

    _sfxPlayer.dispose();
    _bgPlayer.stop();
    _bgPlayer.dispose();
    _congratsPlayer?.stop();
    _congratsPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _shuffledOptionsMap[_currentQuestionIndex]!;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final cardSize = isPortrait
        ? shortestSide * 0.45
        : shortestSide * 0.50;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: OrientationBuilder(
                builder: (context, orientation) {
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
                            .map<Widget>((img) => _buildOption(img, cardSize))
                            .toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: _playHint, // ✅ hint (url)
                child: const Icon(Icons.info_outline, size: 45, color: Colors.orange),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  if (_currentQuestionIndex > 0)
                    GestureDetector(
                      onTap: () {
                        // (opsiyonel) geri soru
                        ALog.tap('sound_prev_question', place: 'instruments');

                        setState(() {
                          _currentQuestionIndex--;
                          _answered = false;
                        });
                        _generateShuffledOptionsForIndex(_currentQuestionIndex);
                        _logQuestionStart(); // ✅ geri gidince yeni soru
                        _playCurrentSound();
                      },
                      child: Image.asset(
                        'assets/images/planet2/back_arrow.png',
                        width: 60,
                        height: 60,
                      ),
                    )
                  else
                    const SizedBox(width: 60),

                  GestureDetector(
                    onTap: () async {
                      // ✅ tekrar dinleme: hint gibi say
                      ALog.e('sound_hint_used', params: {
                        'category': 'instruments',
                        'q_id': _currentQId(),
                      });
                      await _playCurrentSound();
                    },
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
