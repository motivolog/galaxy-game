import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Uygulama genelinde Analytics çağrıları için yardımcı sınıf.
/// - Ekran takibi: screen()
/// - Gezegen/oyun: planetOpened(), levelStart(), levelComplete()
/// - Tıklama/CTA: tap()
/// - Süre ölçümü: startTimer()/endTimer()
class ALog {
  static final _a = FirebaseAnalytics.instance;

  // ---- Temel ekran/gezegen olayları ----
  static Future<void> screen(String name, {String? clazz}) =>
      _a.logScreenView(screenName: name, screenClass: clazz ?? name);

  static Future<void> planetOpened(String planet) =>
      _a.logEvent(name: 'planet_opened', parameters: {'planet': planet});

  static Future<void> levelStart(
      String game,
      int level, {
        String? difficulty,
      }) =>
      _a.logEvent(name: 'level_start', parameters: {
        'game': game,
        'level': level,
        if (difficulty != null) 'difficulty': difficulty,
      });

  static Future<void> levelComplete(
      String game,
      int level, {
        required int score,
        required int mistakes,
        required int durationMs,
      }) =>
      _a.logEvent(name: 'level_complete', parameters: {
        'game': game,
        'level': level,
        'score': score,
        'mistakes': mistakes,
        'duration_ms': durationMs,
      });

  // ---- Tıklama/CTA ----
  static Future<void> tap(String id, {String? place}) =>
      _a.logEvent(name: 'cta_tap', parameters: {
        'id': id, // örn: start_matching, play_sound, back_btn
        if (place != null) 'place': place, // örn: intro, header, footer
      });

  // ---- Ekranda kalma süresi ölçümü (Stopwatch + dispose) ----
  static final Map<String, Stopwatch> _sw = {};

  /// Bir ekran/oyun için süre ölçümünü başlat.
  /// Örn: ALog.startTimer('screen:matchplanet')
  static void startTimer(String key) {
    _sw.putIfAbsent(key, () => Stopwatch()).start();
  }

  /// Ölçümü bitir ve `screen_time_ms` (veya verdiğin metric) event'i gönder.
  /// `extra` ile ek parametreler (örn: {'planet':'match'}) geçebilirsin.
  static Future<void> endTimer(
      String key, {
        String metric = 'screen_time_ms',
        Map<String, Object?>? extra,
      }) async {
    final s = _sw[key];
    if (s == null) return;
    s.stop();
    final elapsed = s.elapsedMilliseconds;
    _sw.remove(key);

    // Tipi netleştirip ek parametreleri ekleyelim
    final Map<String, Object> params = <String, Object>{
      'key': key,
      'elapsed_ms': elapsed,
    };
    if (extra != null) {
      extra.forEach((k, v) {
        if (v != null) params[k] = v;
      });
    }
    await _a.logEvent(
      name: metric,
      parameters: params,
    );
  }
}
