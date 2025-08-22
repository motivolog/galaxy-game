import 'package:flutter/material.dart';
import '../../../analytics_helper.dart';
import 'matchgame_core.dart';

class MatchLevel3 extends StatefulWidget {
  const MatchLevel3({super.key});

  @override
  State<MatchLevel3> createState() => _MatchLevel3State();
}

class _MatchLevel3State extends State<MatchLevel3> {
  static const int LEVEL = 3;
  final Stopwatch _gameSW = Stopwatch();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    ALog.screen('match_level_$LEVEL');
    ALog.startTimer('screen:match_level_$LEVEL');


    ALog.levelStart('matching', LEVEL, difficulty: 'easy');

    _gameSW
      ..reset()
      ..start();
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
        {
          'image': 'assets/images/red_balloon.png',
          'sound': 'audio/kirmizi_balon.mp3',
        },
        {
          'image': 'assets/images/yesil_kurbaga.png',
          'sound': 'audio/yesil_kurbaga.mp3',
        },
        {
          'image': 'assets/images/pembe_ucgen.png',
          'sound': 'audio/pembe_ucgen.mp3',
        },
        {
          'image': 'assets/images/turuncu_top.png',
          'sound': 'audio/turuncu_top.mp3',
        },
      ],
      pairCount: 4,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 4,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      flipBackDelayMs: 100,
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
