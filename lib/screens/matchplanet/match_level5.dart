import 'package:flutter/material.dart';
import '../../../analytics_helper.dart';
import 'matchgame_core.dart';

class MatchLevel5 extends StatefulWidget {
  const MatchLevel5({super.key});

  @override
  State<MatchLevel5> createState() => _MatchLevel5State();
}

class _MatchLevel5State extends State<MatchLevel5> {
  static const int LEVEL = 5;

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
    final double totalCardWidth = (175 * 6 + 15 * 5).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalCardWidth,
            child: MatchGameCore(
              cards: const [
                {'image': 'assets/images/planet1/astronot.png','sound': 'audio/planet1/astronot.mp3'},
                {'image': 'assets/images/planet1/cilek.png',   'sound': 'audio/planet1/cilek.mp3'},
                {'image': 'assets/images/planet1/mantar.png',  'sound': 'audio/planet1/mantar.mp3'},
                {'image': 'assets/images/planet1/ordek.png',   'sound': 'audio/planet1/ordek.mp3'},
                {'image': 'assets/images/planet1/zambak.png',  'sound': 'audio/planet1/zambak.mp3'},
                {'image': 'assets/images/planet1/salyangoz.png','sound': 'audio/planet1/salyangoz.mp3'},
              ],
              pairCount: 6,
              backgroundImage: 'assets/gif/bgg.gif',
              crossAxisCountPortrait: 2,
              crossAxisCountLandscape: 6,
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
