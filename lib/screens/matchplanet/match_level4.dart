import 'package:flutter/material.dart';
import 'matchgame_core.dart';

class MatchLevel4 extends StatelessWidget {
  const MatchLevel4({super.key});

  @override
  Widget build(BuildContext context) {
    return MatchGameCore(
      cards: const [
        {
          'image': 'assets/images/planet1/agac.png',
          'sound': 'audio/planet1/agac.mp3',
        },
        {
          'image': 'assets/images/planet1/ahtapot.png',
          'sound': 'audio/planet1/ahtapot.mp3',
        },
        {
          'image': 'assets/images/planet1/kelebek.png',
          'sound': 'audio/planet1/kelebek.mp3',
        },
        {
          'image': 'assets/images/planet1/gunes.png',
          'sound': 'audio/planet1/gunes.mp3',
        },
        {
          'image': 'assets/images/planet1/roket.png',
          'sound': 'audio/planet1/roket.mp3',
        },
      ],
      pairCount: 5,
      backgroundImage: 'assets/gif/bgg.gif',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 5,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      flipBackDelayMs: 70,
    );
  }
}
