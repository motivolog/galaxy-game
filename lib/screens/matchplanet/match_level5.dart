import 'package:flutter/material.dart';
import 'matchgame_core.dart';

class MatchLevel5 extends StatelessWidget {
  const MatchLevel5({super.key});

  @override
  Widget build(BuildContext context){
    return MatchGameCore(cards: const[
      {
        'image': 'assets/images/planet1/astronot.png',
        'sound': 'audio/planet1/astronot.mp3',
      },
      {
        'image': 'assets/images/planet1/cilek.png',
        'sound': 'audio/planet1/cilek.mp3',
      },
      {
        'image': 'assets/images/planet1/mantar.png',
        'sound': 'audio/planet1/mantar.mp3',
      },
      {
        'image': 'assets/images/planet1/ordek.png',
        'sound': 'audio/planet1/ordek.mp3',
      },{
        'image': 'assets/images/planet1/zambak.png',
        'sound': 'audio/planet1/zambak.mp3',
      },{
        'image': 'assets/images/planet1/salyangoz.png',
        'sound': 'audio/planet1/salyangoz.mp3',
      },
    ],
        pairCount: 6,
        backgroundImage: 'assets/gif/bgg.gif',
        crossAxisCountPortrait: 2,
        crossAxisCountLandscape: 6,
        successSound: 'audio/eslestirme_basarili.mp3',
        failSound: 'audio/tekrar_dene.mp3',
        congratsSound: 'audio/tebrikler.mp3',
        flipBackDelayMs: 60,
    );
  }

}