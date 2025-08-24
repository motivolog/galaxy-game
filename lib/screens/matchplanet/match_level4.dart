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
  static const List<Map<String, String>> _cards = [
    {'image': 'assets/images/planet1/agac.png',    'sound': 'audio/planet1/agac.mp3'},
    {'image': 'assets/images/planet1/ahtapot.png', 'sound': 'audio/planet1/ahtapot.mp3'},
    {'image': 'assets/images/planet1/kelebek.png', 'sound': 'audio/planet1/kelebek.mp3'},
    {'image': 'assets/images/planet1/gunes.png',   'sound': 'audio/planet1/gunes.mp3'},
    {'image': 'assets/images/planet1/roket.png',   'sound': 'audio/planet1/roket.mp3'},
  ];

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
    if (!_completed && _gameSW.isRunning) _gameSW.stop();
    ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'exit'});
    super.dispose();
  }
  Widget _core({
    required int colsPortrait,
    required int colsLandscape,
    double? cardSize,
    bool center = true,
  }) {
    return MatchGameCore(
      cards: _cards,
      pairCount: 5,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: colsPortrait,
      crossAxisCountLandscape: colsLandscape,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      flipBackDelayMs: 70,
      cardSize: cardSize,
      centerGrid: center,
      onGameCompleted: (score, mistakes) {
        if (_completed) return;
        _completed = true;
        _gameSW.stop();
        ALog.levelComplete('matching', LEVEL,
            score: score, mistakes: mistakes, durationMs: _gameSW.elapsedMilliseconds);
        ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'win'});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 15.0;
    const totalCards = 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final isPortrait   = mq.orientation == Orientation.portrait;
        final isTablet     = mq.size.shortestSide >= 600;
        if (!isTablet && isPortrait) {
          const cols = 2;
          final rows = (totalCards / cols).ceil();

          final usableW = constraints.maxWidth  - mq.padding.horizontal;
          final usableH = constraints.maxHeight - mq.padding.vertical;

          final cardFromW = (usableW - spacing * (cols - 1)) / cols;
          final cardFromH = (usableH - spacing * (rows - 1)) / rows;
          final card = cardFromW < cardFromH ? cardFromW : cardFromH;

          final gridW = cols * card + spacing * (cols - 1);
          final gridH = rows * card + spacing * (rows - 1);

          return Center(
            child: SizedBox(
              width: gridW,
              height: gridH,
              child: _core(
                colsPortrait: cols,
                colsLandscape: 5,
                cardSize: card,
                center: true,
              ),
            ),
          );
        }
        return _core(
          colsPortrait: 2,
          colsLandscape: 5,
          center: true,
        );
      },
    );
  }
}
