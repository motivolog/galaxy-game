import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Global Analytics helper
class ALog {
  static final _a = FirebaseAnalytics.instance;

  // ---------- Screen ----------
  static Future<void> screen(String name, {String? clazz}) async {
    await _a.logScreenView(screenName: name, screenClass: clazz ?? name);
    if (kDebugMode) print('[ALog] screen=$name');
  }

  // ---------- Planet / Level ----------
  static Future<void> planetOpened(String planet) =>
      _a.logEvent(name: 'planet_opened', parameters: {'planet': planet});

  static Future<void> levelStart(String game, int level, {String? difficulty}) =>
      _a.logEvent(name: 'level_start', parameters: _clean({
        'game': game,
        'level': level,
        'difficulty': difficulty,
      }));

  static Future<void> levelComplete(
      String game,
      int level, {
        required int score,
        required int mistakes,
        required int durationMs,
      }) =>
      _a.logEvent(name: 'level_complete', parameters: _clean({
        'game': game,
        'level': level,
        'score': score,
        'mistakes': mistakes,
        'duration_ms': durationMs,
      }));

  // ---------- CTA / Click ----------
  static Future<void> tap(String id, {String? place}) =>
      _a.logEvent(name: 'cta_tap', parameters: _clean({
        'id': id,            // e.g. start_matching, play_sound, back_btn
        'place': place,      // e.g. intro, header, footer
      }));

  // ---------- Generic Event ----------
  static Future<void> e(String name, {Map<String, Object?> params = const {}}) =>
      _a.logEvent(name: _safeEventName(name), parameters: _clean(params));

  // ---------- User Properties ----------
  static Future<void> setUserProperty(String name, String value) =>
      _a.setUserProperty(name: name, value: value);

  // ---------- Timers ----------
  static final Map<String, Stopwatch> _sw = {};

  /// Aynı key ile yeniden çağrılırsa reset edip tekrar başlatır.
  static void startTimer(String key) {
    final sw = _sw[key];
    if (sw != null) {
      sw
        ..reset()
        ..start();
    } else {
      _sw[key] = Stopwatch()..start();
    }
  }

  /// Ölçümü bitirir ve (default) 'screen_time_ms' adlı event yollar.
  static Future<void> endTimer(
      String key, {
        String metric = 'screen_time_ms',
        Map<String, Object?>? extra,
      }) async {
    final sw = _sw.remove(key);
    if (sw == null) return;
    sw.stop();
    final elapsed = sw.elapsedMilliseconds;

    final params = _clean({
      'key': key,
      'elapsed_ms': elapsed,
      ...?extra,
    });

    await _a.logEvent(name: _safeEventName(metric), parameters: params);
    if (kDebugMode) print('[ALog] $metric $params');
  }

  // ---------- Helpers ----------
  static Map<String, Object> _clean(Map<String, Object?> src) {
    final out = <String, Object>{};
    src.forEach((k, v) {
      if (v == null) return;
      if (v is bool) {
        out[k] = v ? 1 : 0;       // bool -> 0/1
      } else if (v is num || v is String) {
        out[k] = v;
      } else {
        out[k] = v.toString();    // güvenli fallback
      }
    });
    return out;
  }

  static String _safeEventName(String name) {
    // harf/rakam/alt_tire; boşluk & özel karakterleri alt_tire yap
    final cleaned = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    // boş kalmasın
    return cleaned.isEmpty ? 'event' : cleaned;
  }
}
