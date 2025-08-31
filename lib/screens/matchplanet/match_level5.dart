import 'dart:math' as math;
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
    // Ekran ve süre başlangıcı
    ALog.screen('match_level_$LEVEL');
    ALog.startTimer('screen:match_level_$LEVEL');

    // Level başlangıcı
    ALog.levelStart('matching', LEVEL, difficulty: 'easy');

    _gameSW
      ..reset()
      ..start();
  }

  @override
  void dispose() {
    // Kazanmadan çıkıldıysa süreyi durdur
    if (!_completed && _gameSW.isRunning) {
      _gameSW.stop();
    }
    // Ekran süresi "exit" olarak kapansın
    ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'exit'});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pairCount = 6;

    const double kGapPhonePortrait   = 4.0;
    const double kGapPhoneLandscape  = 4.0;
    const double kGapTabletPortrait  = 12.0;
    const double kGapLandscapeCommon = 10.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final isPortrait = mq.orientation == Orientation.portrait;
            final shortestSide = mq.size.shortestSide;
            final bool isTablet = shortestSide >= 600;
            final pr = mq.devicePixelRatio;

            final totalCards = pairCount * 2;

            _BestLayout best;

            if (!isTablet && isPortrait) {
              const cols = 2;
              final rows = (totalCards / cols).ceil();
              final availableW = constraints.maxWidth  - mq.padding.horizontal;
              final availableH = constraints.maxHeight - mq.padding.vertical;
              const gap = kGapPhonePortrait;

              final sizeByWidth  = (availableW - gap * (cols - 1)) / cols;
              final sizeByHeight = (availableH - gap * (rows - 1)) / rows;

              double card = math.min(sizeByWidth, sizeByHeight);
              card = (card * pr).floorToDouble() / pr;
              card = card.clamp(56.0, 640.0);

              best = _BestLayout(cols: cols, rows: rows, card: card, gap: gap);

            } else if (!isTablet && !isPortrait) {
              const rows = 2;
              final cols = (totalCards / rows).ceil();
              final availableW = constraints.maxWidth  - mq.padding.horizontal;
              final availableH = constraints.maxHeight - mq.padding.vertical;
              const gap = kGapPhoneLandscape;

              final sizeByWidth  = (availableW - gap * (cols - 1)) / cols;
              final sizeByHeight = (availableH - gap * (rows - 1)) / rows;

              double card = math.min(sizeByWidth, sizeByHeight);
              card = (card * pr).floorToDouble() / pr;
              card = card.clamp(56.0, 640.0);

              best = _BestLayout(cols: cols, rows: rows, card: card, gap: gap);

            } else if (isTablet && !isPortrait) {
              const cols = 4;
              final rows = (totalCards / cols).ceil();
              final availableW = constraints.maxWidth  - mq.padding.horizontal;
              final availableH = constraints.maxHeight - mq.padding.vertical;
              const gap = kGapLandscapeCommon;

              final sizeByWidth  = (availableW - gap * (cols - 1)) / cols;
              final sizeByHeight = (availableH - gap * (rows - 1)) / rows;

              double card = math.min(sizeByWidth, sizeByHeight);
              card = (card * pr).floorToDouble() / pr;
              card = card.clamp(84.0, 640.0);

              best = _BestLayout(cols: cols, rows: rows, card: card, gap: gap);

            } else {
              final availableW = constraints.maxWidth  - mq.padding.horizontal;
              final availableH = constraints.maxHeight - mq.padding.vertical;
              final gap = isPortrait ? kGapTabletPortrait : kGapLandscapeCommon;

              best = _bestLayoutFor(
                totalCards: totalCards,
                availableW: availableW,
                availableH: availableH,
                gap: gap,
                minCols: isPortrait ? 2 : 4,
                maxCols: isPortrait ? math.min(5, totalCards) : math.min(8, totalCards),
                pr: pr,
              );
            }

            final gridW = best.cols * best.card + best.gap * (best.cols - 1);
            final gridH = best.rows * best.card + best.gap * (best.rows - 1);

            return Center(
              child: SizedBox(
                width: gridW,
                height: gridH,
                child: MatchGameCore(
                  cards: const [
                    {'image': 'assets/images/planet1/astronot.png','sound': 'audio/planet1/astronot.mp3'},
                    {'image': 'assets/images/planet1/cilek.png',   'sound': 'audio/planet1/cilek.mp3'},
                    {'image': 'assets/images/planet1/mantar.png',  'sound': 'audio/planet1/mantar.mp3'},
                    {'image': 'assets/images/planet1/ordek.png',   'sound': 'audio/planet1/ordek.mp3'},
                    {'image': 'assets/images/planet1/zambak.png',  'sound': 'audio/planet1/zambak.mp3'},
                    {'image': 'assets/images/planet1/salyangoz.png','sound': 'audio/planet1/salyangoz.mp3'},
                  ],
                  pairCount: pairCount,
                  backgroundImage: 'assets/gif/bgg.gif',
                  crossAxisCountPortrait: best.cols,
                  crossAxisCountLandscape: best.cols,
                  successSound: 'audio/eslestirme_basarili.mp3',
                  failSound: 'audio/tekrar_dene.mp3',
                  congratsSound: 'audio/tebrikler.mp3',
                  flipBackDelayMs: 60,
                  cardSize: best.card,

                  //  Kazanma anında Analytics:
                  onGameCompleted: (int score, int mistakes) {
                    if (_completed) return; 
                    _completed = true;

                    if (_gameSW.isRunning) {
                      _gameSW.stop();
                    }

                    // Level tamamlandı
                    ALog.levelComplete(
                      'matching',
                      LEVEL,
                      score: score,
                      mistakes: mistakes,
                      durationMs: _gameSW.elapsedMilliseconds,
                    );

                    // Ekran süresi "win" olarak kapansın
                    ALog.endTimer('screen:match_level_$LEVEL', extra: {'result': 'win'});
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _BestLayout _bestLayoutFor({
    required int totalCards,
    required double availableW,
    required double availableH,
    required double gap,
    required int minCols,
    required int maxCols,
    required double pr,
  }) {
    double bestFill = -1, bestCard = -1;
    int bestCols = minCols, bestRows = (totalCards / minCols).ceil();

    for (int cols = minCols; cols <= math.min(maxCols, totalCards); cols++) {
      final rows = (totalCards / cols).ceil();
      double card = math.min(
        (availableW - gap * (cols - 1)) / cols,
        (availableH - gap * (rows - 1)) / rows,
      );
      card = (card * pr).floorToDouble() / pr;
      final gridW = cols * card + gap * (cols - 1);
      final gridH = rows * card + gap * (rows - 1);
      final fillScore = math.min(gridW / availableW, gridH / availableH);

      if (fillScore > bestFill || (fillScore == bestFill && card > bestCard)) {
        bestFill = fillScore;
        bestCard = card;
        bestCols = cols;
        bestRows = rows;
      }
    }
    final clampedCard = bestCard.clamp(84.0, 640.0);
    return _BestLayout(
      cols: bestCols,
      rows: bestRows,
      card: clampedCard.toDouble(),
      gap: gap,
    );
  }
}

class _BestLayout {
  final int cols, rows;
  final double card, gap;
  const _BestLayout({
    required this.cols,
    required this.rows,
    required this.card,
    required this.gap,
  });
}