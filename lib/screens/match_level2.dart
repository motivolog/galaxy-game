import 'package:flutter/material.dart';
import 'matchgame_core.dart';

class MatchLevel2 extends StatelessWidget {
  const MatchLevel2({super.key});

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
      pairCount: 3, // 3 çift, yani toplam 6 kart
      backgroundImage: 'assets/images/space_bg_repeat.png',
      crossAxisCountPortrait: 2,     // dikeyde 2 sütun → 3x2 yerleşim
      crossAxisCountLandscape: 3,    // yatayda 3 sütun → 2x3 yerleşim
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
    );
  }
}
