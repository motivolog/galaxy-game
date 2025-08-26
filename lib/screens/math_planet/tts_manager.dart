import 'package:flutter_tts/flutter_tts.dart';

class TTSManager {
  TTSManager._internal();
  static final TTSManager instance = TTSManager._internal();

  final FlutterTts _tts = FlutterTts();
  String? _lastSpokenId;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.6);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }
  Future<void> speak(String text, {String? id}) async {
    await _ensureInitialized();
    if (id != null && _lastSpokenId == id) return;
    await stop();
    _lastSpokenId = id;
    if (text.trim().isEmpty) return;
    await _tts.speak(text);
  }
  Future<void> speakOnce(String text, {required String id}) async {
    await _ensureInitialized();
    if (_lastSpokenId == id) return;
    await stop();
    _lastSpokenId = id;
    if (text.trim().isEmpty) return;
    await _tts.speak(text);
  }
  Future<void> speakNow(String text) async {
    await _ensureInitialized();
    await stop();
    if (text.trim().isEmpty) return;
    await _tts.speak(text);
  }
  Future<void> stop() async {
    await _ensureInitialized();
    try { await _tts.stop();
    } catch (_) {}
  }
  Future<void> dispose() async {
    await stop();
  }
  void resetLastId() {
    _lastSpokenId = null;
  }
}
