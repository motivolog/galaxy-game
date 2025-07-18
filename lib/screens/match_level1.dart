import 'package:flutter/material.dart';
import 'matchgame_core.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchLevel1 extends StatefulWidget {
  const MatchLevel1({super.key});

  @override
  State<MatchLevel1> createState() => _MatchLevel1State();
}
//istediğimiz yazı sese dönüşür.
class _MatchLevel1State extends State<MatchLevel1> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    print("MatchLevel1 init çalıştı");
    Future.delayed(Duration.zero, () {
      _speakLevelIntro();
    });
  }
  Future<void> _speakLevelIntro() async{
    await _flutterTts.setLanguage("en-US");  //Türkçe
    await _flutterTts.setSpeechRate(0.5);   //Konuşma hızı
    await _flutterTts.setPitch(1.0);       //sesin tonlaması
    await _flutterTts.setVolume(1.0);     //sesin yüksekliği
    await _flutterTts.awaitSpeakCompletion(true);

    await _flutterTts.speak(
      "Welcome to level one. Are you ready to match the items?"
    );
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
      centerGrid: true, // sadece Level 1'de true
    );

  }
}
