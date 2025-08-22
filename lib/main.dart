import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'firebase_options.dart';
import 'screens/home/intro_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Analytics açık olsun ve uygulama açılışını gönder
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await FirebaseAnalytics.instance.logAppOpen();

  runApp(const GalaksimdeOgreniyorumApp());
}

class GalaksimdeOgreniyorumApp extends StatelessWidget {
  const GalaksimdeOgreniyorumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galaksimde Öğreniyorum',
      theme: ThemeData.dark(),

      // Route geçişlerinde ekran görüntüleme (screen_view) event'lerini otomatik yollar
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],

      home: const IntroScreen(),
    );
  }
}
