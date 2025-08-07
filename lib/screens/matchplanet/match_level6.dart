import 'package:flutter/material.dart';
import 'matchgame_core.dart';

class MatchLevel6 extends StatelessWidget {
  const MatchLevel6({super.key});

  @override
  Widget build(BuildContext context){
    return MatchGameCore(cards: const [
      {
        'image': 'assets/images/planet1/dünya.png',
        'sound': 'audio/planet1/dünya.mp3',
      },
      {
        'image': 'assets/images/planet1/jüpiter.png',
        'sound': 'audio/planet1/jüpiter.mp3',
      },
      {
        'image': 'assets/images/planet1/mars.png',
        'sound': 'audio/planet1/mars.mp3',
      },
      {
        'image': 'assets/images/planet1/merkür.png',
        'sound': 'audio/planet1/merkür.mp3',
      },
      {
        'image': 'assets/images/planet1/neptün.png',
        'sound': 'audio/planet1/neptün.mp3',
      },
      {
        'image': 'assets/images/planet1/satürn.png',
        'sound': 'audio/planet1/satürn.mp3',
      },
      {
        'image': 'assets/images/planet1/uranüs.png',
        'sound': 'audio/planet1/uranüs.mp3',
      },
      {
        'image': 'assets/images/planet1/venüs.png',
        'sound': 'audio/planet1/venüs.mp3',
      },
    ],
        pairCount: 8,
        backgroundImage:'assets/gif/bgg.gif',
        crossAxisCountPortrait: 2,
        crossAxisCountLandscape: 8,
        successSound: 'audio/eslestirme_basarili.mp3',
        failSound: 'audio/tekrar_dene.mp3',
        congratsSound: 'audio/tebrikler.mp3',
        flipBackDelayMs: 100,
    );
  }
}