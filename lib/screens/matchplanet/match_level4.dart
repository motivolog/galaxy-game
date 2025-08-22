import 'package:flutter/material.dart';
import '../../../analytics_helper.dart';
import 'matchgame_core.dart';

class MatchLevel4 extends StatefulWidget {
  const MatchLevel4({super.key});

  @override
  State<MatchLevel4> createState() => _MatchLevel4State();
}

class _MatchLevel4State extends State<MatchLevel4> {
  static const int LEVEL = 4;
  final Stopwatch _gameSW = Stopwatch();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    ALog.screen('match_level_$LEVEL');
    ALog.startTimer('screen:match_level_$LEVEL');
    ALog.levelStart('matching', LEVEL, difficulty: 'easy');

    _gameSW..reset()..start();
  }

  @override
  void dispose() {
    if (!_completed && _gameSW.isRunning) {
      _gameSW.stop();
    }
    ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'exit'});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MatchGameCore(
      cards: const [
        {'image': 'assets/images/planet1/agac.png',    'sound': 'audio/planet1/agac.mp3'},
        {'image': 'assets/images/planet1/ahtapot.png', 'sound': 'audio/planet1/ahtapot.mp3'},
        {'image': 'assets/images/planet1/kelebek.png', 'sound': 'audio/planet1/kelebek.mp3'},
        {'image': 'assets/images/planet1/gunes.png',   'sound': 'audio/planet1/gunes.mp3'},
        {'image': 'assets/images/planet1/roket.png',   'sound': 'audio/planet1/roket.mp3'},
      ],
      pairCount: 5,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 5,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      flipBackDelayMs: 70,
      onGameCompleted: (int score, int mistakes) {
        if (_completed) return;
        _completed = true;

        _gameSW.stop();

        ALog.levelComplete(
          'matching',
          LEVEL,
          score: score,
          mistakes: mistakes,
          durationMs: _gameSW.elapsedMilliseconds,
        );

        ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'win'});

      },
    );
  }
}
