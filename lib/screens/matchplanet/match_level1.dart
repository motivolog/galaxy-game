import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../analytics_helper.dart';
import 'matchgame_core.dart';

class MatchLevel1 extends StatefulWidget {
  const MatchLevel1({super.key});

  @override
  State<MatchLevel1> createState() => _MatchLevel1State();
}

class _MatchLevel1State extends State<MatchLevel1> {
  final FlutterTts _flutterTts = FlutterTts();
  final Stopwatch _gameSW = Stopwatch();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    ALog.screen('match_level_1');
    ALog.startTimer('screen:match_level_1');
    ALog.levelStart('matching', 1, difficulty: 'easy');
    _gameSW..reset()..start();
  }

  void _onLevelComplete({required int score, required int mistakes}) {
    if (_completed) return;
    _completed = true;
    _gameSW.stop();
    ALog.levelComplete('matching', 1,
      score: score,
      mistakes: mistakes,
      durationMs: _gameSW.elapsedMilliseconds,
    );
    ALog.endTimer('screen:match_level_1', extra: {'result': 'win'});
  }

  @override
  void dispose() {
    if (!_completed) {
      if (_gameSW.isRunning) _gameSW.stop();
      ALog.endTimer('screen:match_level_1', extra: {'result': 'exit'});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MatchGameCore(
      cards: const [
        {'image': 'assets/images/kirmizi_cicek.png','sound': 'audio/kirmizi_cicek.mp3'},
        {'image': 'assets/images/sari_araba.png','sound': 'audio/sari_araba.mp3'},
      ],
      pairCount: 2,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 4,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      centerGrid: true,

      onGameCompleted: (int score, int mistakes) {
        _onLevelComplete(score: score, mistakes: mistakes);
      },
    );
  }
}
