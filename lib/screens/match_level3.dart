import 'package:flutter/material.dart';
import 'matchgame_core.dart';

class MatchLevel3 extends StatelessWidget {
  const MatchLevel3({super.key});

  @override
  Widget build(BuildContext context) {
    return MatchGameCore(
      cards: const [
        {
          'image': 'assets/images/kirmizi_balon.png',
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
      backgroundImage: 'assets/images/space_bg_repeat.png',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 4,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
    );
  }
}
