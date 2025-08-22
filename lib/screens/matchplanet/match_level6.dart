import 'package:flutter/material.dart';
import '../../../analytics_helper.dart';
import 'matchgame_core.dart';

class MatchLevel6 extends StatefulWidget {
  const MatchLevel6({super.key});

  @override
  State<MatchLevel6> createState() => _MatchLevel6State();
}

class _MatchLevel6State extends State<MatchLevel6> {
  static const int LEVEL = 6;

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
    final double totalCardWidth = (175 * 8 + 15 * 7).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalCardWidth,
            child: MatchGameCore(
              cards: const [
                {'image': 'assets/images/planet1/dünya.png',   'sound': 'audio/planet1/dünya.mp3'},
                {'image': 'assets/images/planet1/jüpiter.png', 'sound': 'audio/planet1/jüpiter.mp3'},
                {'image': 'assets/images/planet1/mars.png',    'sound': 'audio/planet1/mars.mp3'},
                {'image': 'assets/images/planet1/merkür.png',  'sound': 'audio/planet1/merkür.mp3'},
                {'image': 'assets/images/planet1/neptün.png',  'sound': 'audio/planet1/neptün.mp3'},
                {'image': 'assets/images/planet1/satürn.png',  'sound': 'audio/planet1/satürn.mp3'},
                {'image': 'assets/images/planet1/uranüs.png',  'sound': 'audio/planet1/uranüs.mp3'},
                {'image': 'assets/images/planet1/venus.png',   'sound': 'audio/planet1/venus.mp3'},
              ],
              pairCount: 8,
              backgroundImage: 'assets/gif/bgg.gif',
              crossAxisCountPortrait: 2,
              crossAxisCountLandscape: 8,
              successSound: 'audio/eslestirme_basarili.mp3',
              failSound: 'audio/tekrar_dene.mp3',
              congratsSound: 'audio/tebrikler.mp3',
              flipBackDelayMs: 60,
              cardSize: 175,

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
            ),
          ),
        ),
      ),
    );
  }
}
