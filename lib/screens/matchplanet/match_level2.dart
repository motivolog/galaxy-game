import 'package:flutter/material.dart';
import '../../../analytics_helper.dart';
import 'matchgame_core.dart';

class MatchLevel2 extends StatefulWidget {
  const MatchLevel2({super.key});

  @override
  State<MatchLevel2> createState() => _MatchLevel2State();
}

class _MatchLevel2State extends State<MatchLevel2> {
  static const int LEVEL = 2;
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
          'image': 'assets/images/siyah_kedi.png',
          'sound': 'audio/siyah_kedi.mp3',
        },
        {
          'image': 'assets/images/yesil_armut.png',
          'sound': 'audio/yesil_armut.mp3',
        },
        {
          'image': 'assets/images/mavi_yildiz.png',
          'sound': 'audio/mavi_yildiz.mp3',
        },
      ],
      pairCount: 3,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 3,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      centerGrid: true,
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
