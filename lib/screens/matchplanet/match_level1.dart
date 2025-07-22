import 'package:flutter/material.dart';
import 'matchgame_core.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchLevel1 extends StatefulWidget {
  const MatchLevel1({super.key});

  @override
  State<MatchLevel1> createState() => _MatchLevel1State();
}

class _MatchLevel1State extends State<MatchLevel1> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
    });
  }


  @override
  Widget build(BuildContext context) {
    return MatchGameCore(
      cards: const [
        {
          'image': 'assets/images/kirmizi_cicek.png',
          'sound': 'audio/kirmizi_cicek.mp3',
        },
        {
          'image': 'assets/images/sari_araba.png',
          'sound': 'audio/sari_araba.mp3',
        },
      ],
      pairCount: 2,
      backgroundImage: 'assets/images/space_bg_repeat.png',
      crossAxisCountPortrait: 2,
      crossAxisCountLandscape: 4,
      successSound: 'audio/eslestirme_basarili.mp3',
      failSound: 'audio/tekrar_dene.mp3',
      congratsSound: 'audio/tebrikler.mp3',
      centerGrid: true,
    );

  }
}