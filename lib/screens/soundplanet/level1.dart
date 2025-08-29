import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'question.dart';
import '../../analytics_helper.dart'; // ✅ Analytics

class Level1 extends StatefulWidget {
  const Level1({super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _promptPlayer = AudioPlayer();
  AudioPlayer? _congratsPlayer;

  int _currentQuestionIndex = 0;
  bool _answered = false;
  final Map<int, List<String>> _shuffledOptionsMap = {};

  // ✅ Analytics yardımcı sayaçlar
  final Map<int, int> _attempts = {};      // soru bazlı deneme sayısı
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _finished = false;
  final Stopwatch _levelSW = Stopwatch();  // level süresi (ms) için

  @override
  void initState() {
    super.initState();
    _levelSW.start(); // ✅ Level süresi başlat

    _generateShuffledOptionsForIndex(_currentQuestionIndex);
    _logQuestionStart(); // ✅ İlk soru başladı
    _playCurrentSoundWithOptionalPrompt();
  }

  void _generateShuffledOptionsForIndex(int index) {
    if (_shuffledOptionsMap.containsKey(index)) return;
    final rawOptions = (soundQuestions[index]['options'] as List).cast<String>();
    final shuffled = List<String>.from(rawOptions)..shuffle();
    _shuffledOptionsMap[index] = shuffled;
  }

  String _currentQId() {
    // ✅ Soru kimliği: ses dosyasının adı
    final soundUrl = soundQuestions[_currentQuestionIndex]['sound'] as String;
    return p.basenameWithoutExtension(soundUrl);
  }

  void _logQuestionStart() {
    // ✅ Yeni soru başladığında
    ALog.e('sound_question_start', params: {
      'category': 'animals',
      'q_id': _currentQId(),
    });
    // soru için deneme sayacını sıfırlama
    _attempts[_currentQuestionIndex] = 0;
  }

  Future<void> _playCurrentSoundWithOptionalPrompt() async {
    await _promptPlayer.stop();
    await _sfxPlayer.stop();

    final soundUrl = soundQuestions[_currentQuestionIndex]['sound'] as String;
    await _sfxPlayer.play(UrlSource(soundUrl));

    if (_currentQuestionIndex == 0) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _currentQuestionIndex == 0 && !_answered) {
        await _promptPlayer.play(AssetSource('audio/neyin_sesi.mp3'));
      }
    }
  }

  Future<void> _checkAnswer(String selectedImagePath) async {
    if (_answered) return;

    final q = soundQuestions[_currentQuestionIndex] as Map<String, dynamic>;
    final correct = q['correct'] as String;

    await _promptPlayer.stop();
    await _sfxPlayer.stop();

    final isCorrect = p.basename(selectedImagePath) == p.basename(correct);

    // ✅ Deneme sayısı + cevap olayı
    final attempt = (_attempts[_currentQuestionIndex] ?? 0) + 1;
    _attempts[_currentQuestionIndex] = attempt;

    ALog.e('sound_answer', params: {
      'category': 'animals',
      'q_id': _currentQId(),
      'correct': isCorrect ? 1 : 0,
      'attempt': attempt,
    });

    if (isCorrect) {
      _correctCount++;
      setState(() => _answered = true);

      final correctSfx = q['correct_sound'] as String?;
      if (correctSfx != null && correctSfx.isNotEmpty) {
        await _sfxPlayer.play(AssetSource(correctSfx));
        await _sfxPlayer.onPlayerComplete.first;
      }

      final isLast = _currentQuestionIndex >= soundQuestions.length - 1;
      if (!isLast) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
        });
        _generateShuffledOptionsForIndex(_currentQuestionIndex);
        _logQuestionStart(); // ✅ sıradaki soru
        await _playCurrentSoundWithOptionalPrompt();
      } else {
        // ✅ Level bitti
        final timeMs = _levelSW.elapsedMilliseconds;
        _levelSW.stop();

        ALog.e('sound_level_complete', params: {
          'category': 'animals',
          'time_ms': timeMs,
          'correct_count': _correctCount,
          'wrong_count': _wrongCount,
        });

        // category timer'ını (level_select_sound'da başlatıldıysa) kapat
        ALog.endTimer('sound:animals', extra: {'category': 'animals'});

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
        onTap: () async {
          await _congratsPlayer?.stop();
          await _congratsPlayer?.dispose();
          _congratsPlayer = null;
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
    // ✅ Yarıda çıkış senaryosu
    if (!_finished) {
      final total = soundQuestions.length;
      int completed = _currentQuestionIndex + (_answered ? 1 : 0);
      if (completed > total) completed = total;
      final progressPct = ((completed / total) * 100).round();

      ALog.e('sound_exit', params: {
        'category': 'animals',
        'progress_pct': progressPct,
        'reason': 'back',
      });

      // Category timer açıksa kapat
      ALog.endTimer('sound:animals', extra: {'category': 'animals'});
      _levelSW.stop();
    }

    _sfxPlayer.dispose();
    _promptPlayer.stop();
    _promptPlayer.dispose();
    _congratsPlayer?.stop();
    _congratsPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _shuffledOptionsMap[_currentQuestionIndex]!;
    final shortestSide = MediaQuery.of(context).size.shortestSide;

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
                  final isPortrait = orientation == Orientation.portrait;
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

            // ✅ Alt çubuk: geri soru / tekrar dinle (hint)
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
                      onTap: () async {
                        // (isteğe bağlı) navigasyon takibi
                        ALog.tap('sound_prev_question', place: 'animals');

                        setState(() {
                          _currentQuestionIndex--;
                          _answered = false;
                        });
                        _generateShuffledOptionsForIndex(_currentQuestionIndex);
                        _logQuestionStart(); // ✅ geri gidince yeni soru başlangıcı
                        await _playCurrentSoundWithOptionalPrompt();
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
                    onTap: () async {
                      // ✅ hint olarak sayalım (tekrar dinle)
                      ALog.e('sound_hint_used', params: {
                        'category': 'animals',
                        'q_id': _currentQId(),
                      });
                      await _playCurrentSoundWithOptionalPrompt();
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
    return Semantics(
      label: p.basenameWithoutExtension(imagePath),
      button: true,
      child: GestureDetector(
        onTap: _answered ? null : () => _checkAnswer(imagePath),
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
      ),
    );
  }
}
