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

  // Kartlar tek yerde
  static const List<Map<String, String>> _planetCards = [
    {'image': 'assets/images/planet1/dünya.png',   'sound': 'audio/planet1/dünya.mp3'},
    {'image': 'assets/images/planet1/jüpiter.png', 'sound': 'audio/planet1/jüpiter.mp3'},
    {'image': 'assets/images/planet1/mars.png',    'sound': 'audio/planet1/mars.mp3'},
    {'image': 'assets/images/planet1/merkür.png',  'sound': 'audio/planet1/merkür.mp3'},
    {'image': 'assets/images/planet1/neptün.png',  'sound': 'audio/planet1/neptün.mp3'},
    {'image': 'assets/images/planet1/satürn.png',  'sound': 'audio/planet1/satürn.mp3'},
    {'image': 'assets/images/planet1/uranüs.png',  'sound': 'audio/planet1/uranüs.mp3'},
    {'image': 'assets/images/planet1/venus.png',   'sound': 'audio/planet1/venus.mp3'},
  ];

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
    if (!_completed && _gameSW.isRunning) _gameSW.stop();
    ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'exit'});
    super.dispose();
  }
  Widget _core({
    required int colsPortrait,
    required int colsLandscape,
    required double cardSize,
    bool centerGrid = false,
  }) {
    return MatchGameCore(
      cards: _planetCards,
      pairCount: 8,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: colsPortrait,
      crossAxisCountLandscape: colsLandscape,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      flipBackDelayMs: 60,
      cardSize: cardSize,
      centerGrid: centerGrid,
      onGameCompleted: _onWin,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double phoneGap  = 15.0;
    const double phoneCard = 175.0;
    const double kGapTablet = 15.0;
    const double tabletScaleLandscape = 0.90;
    const double tabletScalePortrait  = 0.92;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final isPortrait   = mq.orientation == Orientation.portrait;
            final shortestSide = mq.size.shortestSide;
            final bool isTablet = shortestSide >= 600;
            final pr = mq.devicePixelRatio;

            if (isTablet) {
              if (isPortrait) {
                const cols = 2;
                const gap  = kGapTablet;

                final usableW = constraints.maxWidth  - mq.padding.horizontal;
                final usableH = constraints.maxHeight - mq.padding.vertical;

                double card = (usableW - gap * (cols - 1)) / cols;
                card *= tabletScalePortrait;
                card = (card * pr).floorToDouble() / pr;
                card = card.clamp(96.0, 720.0);

                final rows  = (_planetCards.length * 2 / cols).ceil();
                final gridW = cols * card + gap * (cols - 1);
                final gridH = rows * card + gap * (rows - 1);

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: SizedBox(
                      width: gridW,
                      height: gridH,
                      child: _core(
                        colsPortrait: cols,
                        colsLandscape: cols,
                        cardSize: card,
                        centerGrid: true,
                      ),
                    ),
                  ),
                );
              } else {
                const rows = 2;
                const gap  = kGapTablet;

                final usableH = constraints.maxHeight - mq.padding.vertical;

                double card = (usableH - gap * (rows - 1)) / rows;
                card *= tabletScaleLandscape;
                card = (card * pr).floorToDouble() / pr;
                card = card.clamp(96.0, 720.0);

                final cols = ((_planetCards.length * 2) / rows).ceil();
                final gridW = cols * card + gap * (cols - 1);

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Center(
                    child: SizedBox(
                      width: gridW,
                      height: usableH,
                      child: _core(
                        colsPortrait: cols,
                        colsLandscape: cols,
                        cardSize: card,
                        centerGrid: true,
                      ),
                    ),
                  ),
                );
              }
            }

            if (isPortrait) {
              const cols = 2;
              const gap  = phoneGap;

              final usableW = constraints.maxWidth  - mq.padding.horizontal;
              double card = (usableW - gap * (cols - 1)) / cols;
              card = (card * pr).floorToDouble() / pr;
              card = card.clamp(88.0, 520.0);

              final rows  = (_planetCards.length * 2 / cols).ceil();
              final gridW = cols * card + gap * (cols - 1);
              final gridH = rows * card + gap * (rows - 1);

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: SizedBox(
                    width: gridW,
                    height: gridH,
                    child: _core(
                      colsPortrait: cols,
                      colsLandscape: cols,
                      cardSize: card,
                      centerGrid: true,
                    ),
                  ),
                ),
              );
            }
            final totalCardWidth = (phoneCard * 8 + phoneGap * 7).toDouble();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalCardWidth,
                child: _core(
                  colsPortrait: 2,
                  colsLandscape: 8,
                  cardSize: phoneCard,
                  centerGrid: false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onWin(int score, int mistakes) {
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
  }
}
