import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'object_panel.dart';
import 'space_background.dart';
import 'package:flutter_projects/screens/math_planet/tts_manager.dart';
import 'package:flutter_projects/screens/math_planet/speech_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/screens/math_planet/celebration_galaxy.dart';
import 'package:flutter_projects/analytics_helper.dart';
import 'package:flutter_projects/widgets/accessible_zoom.dart';

class AdditionLevelPage extends StatefulWidget {
  const AdditionLevelPage({
    super.key,
    this.maxA = 100,
    this.maxB = 100,
    this.targetCorrect = 6,
    required this.objectAssets,
    this.objectSize = 56,
    this.distinctSides = true,
    this.changeAssetsEveryQuestion = true,
    this.visualizeUpTo = 10,
  });

  final int maxA;
  final int maxB;
  final int targetCorrect;
  final List<String> objectAssets;
  final double objectSize;
  final bool distinctSides;
  final bool changeAssetsEveryQuestion;
  final int visualizeUpTo;

  @override
  State<AdditionLevelPage> createState() => _AdditionLevelPageState();
}

class _AdditionLevelPageState extends State<AdditionLevelPage> {
  final _rnd = Random();
  late _AdditionQuestion q;
  int correct = 0;
  int wrong = 0;
  bool lockingUi = false;
  bool pulseHint = false;
  final AudioPlayer _fx = AudioPlayer();
  int? _shakeIdx;
  int _shakeKey = 0;
  int _tapSeq = 0;

  // analytics yardımcıları
  final Stopwatch _levelSW = Stopwatch();
  final Map<String, int> _attempts = {}; // q_id -> attempt
  bool _finished = false;
  bool _exitLogged = false;

  late String _leftAsset;
  late String _rightAsset;
  bool get _showObjects =>
      q.a <= widget.visualizeUpTo && q.b <= widget.visualizeUpTo;

  @override
  void initState() {
    super.initState();

    ALog.screen('math_add', clazz: 'AdditionLevelPage'); //  screen_view
    ALog.startTimer('screen:math_add');                  // ekran süresi

    ALog.e('math_mode_enter', params: {'mode': 'add'});
    ALog.startTimer('math:add');
    _levelSW.start();

    q = _AdditionQuestion.generate(_rnd, widget.maxA, widget.maxB);
    _pickAssets();
    _logQuestionStart();
    _speakCurrentQuestion();
    _fx.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final p in widget.objectAssets) {
      precacheImage(AssetImage(p), context);
    }
  }

  void _pickAssets() {
    if (widget.objectAssets.isEmpty) {
      _leftAsset = _rightAsset = '';
      return;
    }
    _leftAsset = widget.objectAssets[_rnd.nextInt(widget.objectAssets.length)];
    if (widget.distinctSides && widget.objectAssets.length > 1) {
      String candidate;
      do {
        candidate = widget.objectAssets[_rnd.nextInt(widget.objectAssets.length)];
      } while (candidate == _leftAsset);
      _rightAsset = candidate;
    } else {
      _rightAsset = widget.objectAssets[_rnd.nextInt(widget.objectAssets.length)];
    }
  }

  String _qid() => '${q.a}+${q.b}';

  void _logQuestionStart() {
    _attempts[_qid()] = 0;
    ALog.e('math_question', params: {
      'mode': 'add',
      'a': q.a,
      'b': q.b,
      'op': '+',
    });
  }

  Future<void> _onPick(int idx, int value) async {
    if (lockingUi) return;
    final int seq = ++_tapSeq;
    try {
      await _fx.stop();
    } catch (_) {}
    await TTSManager.instance.stop();
    final isRight = value == q.answer;

    final attempt = (_attempts[_qid()] ?? 0) + 1;
    _attempts[_qid()] = attempt;
    ALog.e('math_answer', params: {
      'mode': 'add',
      'a': q.a,
      'b': q.b,
      'op': '+',
      'user': value,
      'correct': isRight ? 1 : 0,
      'attempt': attempt,
    });

    if (isRight) {
      setState(() {
        lockingUi = true;
        correct++;
      });

      final ansText = mathAnswerToSpeech(a: q.a, op: '+', b: q.b);

      try {
        await TTSManager.instance
            .speakNow(ansText)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}

      if (!mounted) return;

      if (correct >= widget.targetCorrect) {
        await _completeLevel();
        return;
      }

      setState(() {
        q = _AdditionQuestion.generate(_rnd, widget.maxA, widget.maxB);
        if (widget.changeAssetsEveryQuestion) _pickAssets();
        lockingUi = false;
      });
      _logQuestionStart();
      TTSManager.instance.speakOnce(
        mathQuestionToSpeech(a: q.a, op: '+', b: q.b),
        id: _qid(),
      );
    } else {
      wrong++;
      HapticFeedback.mediumImpact();
      setState(() {
        pulseHint = true;
        _shakeIdx = idx;
        _shakeKey++;
      });

      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => pulseHint = false);
      try {
        await _fx.play(AssetSource('audio/tekrar_dene.mp3'));
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted || seq != _tapSeq) return;
      _speakCurrentQuestion();
    }
  }

  Future<void> _completeLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('math_level1_done', true);

    if (!mounted) return;
    await TTSManager.instance.stop();
    try {
      await _fx.stop();
    } catch (_) {}
    final timeMs = _levelSW.elapsedMilliseconds;
    _levelSW.stop();
    ALog.e('math_level_complete', params: {
      'mode': 'add',
      'time_ms': timeMs,
      'q_total': widget.targetCorrect,
      'q_correct': correct,
      'q_wrong': wrong,
    });
    ALog.endTimer('math:add', extra: {'mode': 'add'});
    ALog.endTimer('screen:math_add', extra: {'result': 'win'});

    _finished = true;

    await showCelebrationGalaxy(
      context, duration: const Duration(seconds: 4),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _speakCurrentQuestion() {
    final speech = mathQuestionToSpeech(a: q.a, op: '+', b: q.b);
    TTSManager.instance.speakOnce(speech, id: _qid());
  }

  @override
  void dispose() {
    if (!_finished && !_exitLogged) {
      final progressPct = ((correct / widget.targetCorrect) * 100).round();
      ALog.e('math_exit', params: {
        'mode': 'add',
        'progress_pct': progressPct,
        'reason': 'dispose',
      });
      ALog.endTimer('math:add', extra: {'mode': 'add'});
      // ekran süresini de kapat (erken çıkış)
      ALog.endTimer('screen:math_add', extra: {'result': 'exit'});
    }

    TTSManager.instance.stop();
    _fx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600;
    final titleFs = isTablet ? 56.0 : (size.width < 360 ? 30.0 : 38.0);

    return Scaffold(
      body: AccessibleZoom(
        persistKey: 'math_access_zoom',
        showButton: false,
        child: SafeArea(
          child: Stack(
            children: [
              const SpaceBackground(),
              Positioned(
                top: -2, left: 1, right: 8,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final progressPct =
                        ((correct / widget.targetCorrect) * 100).round();
                        ALog.tap('back', place: 'math_add');
                        ALog.e('math_exit', params: {
                          'mode': 'add',
                          'progress_pct': progressPct,
                          'reason': 'back',
                        });
                        ALog.endTimer('math:add', extra: {'mode': 'add'});
                        //  geri tuşunda ekran süresini kapat
                        ALog.endTimer('screen:math_add', extra: {'result': 'back'});

                        _exitLogged = true;
                        Navigator.pop(context, false);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: correct / widget.targetCorrect,
                            minHeight: isTablet ? 14 : 10,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Doğru: $correct / ${widget.targetCorrect}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Container(
                  width: size.width * (isTablet ? 0.92 : 0.96),
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2148).withOpacity(0.55),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: titleFs,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                const TextSpan(
                                    text: '  ', style: TextStyle(color: Colors.white)),
                                TextSpan(
                                  text: '${q.a}',
                                  style: const TextStyle(color: Color(0xFF9AE6FF)),
                                ),
                                const TextSpan(
                                    text: '  +  ', style: TextStyle(color: Colors.white)),
                                TextSpan(
                                  text: '${q.b}',
                                  style: const TextStyle(color: Color(0xFFFF84B8)),
                                ),
                                const TextSpan(
                                    text: '  =  ?', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_showObjects) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ObjectPanel(
                                count: q.a,
                                asset: _leftAsset,
                                maxTargetSize: isTablet
                                    ? widget.objectSize * 1.8
                                    : widget.objectSize * 1.1,
                                semantic: 'Birinci sayı ${q.a}',
                                pulse: pulseHint,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ObjectPanel(
                                count: q.b,
                                asset: _rightAsset,
                                maxTargetSize: isTablet
                                    ? widget.objectSize * 1.8
                                    : widget.objectSize * 1.1,
                                semantic: 'İkinci sayı ${q.b}',
                                pulse: pulseHint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        const SizedBox(height: 4),
                      ],
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 0, right: 0, bottom: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                  child: LayoutBuilder(
                    builder: (_, cons) {
                      final btnH = isTablet ? 90.0 : (size.width < 360 ? 52.0 : 62.0);
                      final btnW = isTablet ? 160.0 : (size.width < 360 ? 90.0 : 112.0);
                      final spacing = isTablet ? 20.0 : 14.0;
                      final fs = isTablet ? 32.0 : 24.0;

                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.24),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: spacing,
                            runSpacing: 10,
                            children: [
                              for (int idx = 0; idx < q.options.length; idx++)
                                SizedBox(
                                  width: btnW,
                                  height: btnH,
                                  child: TweenAnimationBuilder<double>(
                                    key: ValueKey(
                                        'shake$_shakeKey-$idx-${_shakeIdx == idx}'),
                                    tween: Tween<double>(
                                        begin: 0,
                                        end: _shakeIdx == idx ? 1 : 0),
                                    duration: const Duration(milliseconds: 450),
                                    builder: (context, t, child) {
                                      final dx = (_shakeIdx == idx)
                                          ? sin(t * pi * 6) * 6
                                          : 0.0;
                                      return Transform.translate(
                                        offset: Offset(dx, 0),
                                        child: child,
                                      );
                                    },
                                    child: ElevatedButton(
                                      onPressed: lockingUi
                                          ? null
                                          : () => _onPick(idx, q.options[idx]),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        '${q.options[idx]}',
                                        style: TextStyle(fontSize: fs),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdditionQuestion {
  final int a, b, answer;
  final List<int> options;
  _AdditionQuestion(this.a, this.b, this.answer, this.options);
  static _AdditionQuestion generate(Random rnd, int maxA, int maxB) {
    final a = rnd.nextInt(maxA + 1);
    final b = rnd.nextInt(maxB + 1);
    final ans = a + b;
    final span = max(3, (ans * 0.15).round());
    int jitter() => rnd.nextInt(span * 2 + 1) - span;

    final set = <int>{ans};
    while (set.length < 3) {
      final d = ans + jitter();
      if (d >= 0) set.add(d);
    }
    final opts = set.toList()..shuffle(rnd);
    return _AdditionQuestion(a, b, ans, opts);
  }
}
