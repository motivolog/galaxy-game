import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../analytics_helper.dart'; // ✅ ekle

void showSoundPlanetCelebration(BuildContext context) {
  // ✅ kutlama süresi ölçümü (genel anahtar)
  ALog.startTimer('sound:celebration');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // ✅ analytics: kutlamadan çıkış tıklaması + süreyi bitir
          ALog.tap('sound_celebration_dismiss', place: 'sound_celebration');
          ALog.endTimer('sound:celebration',
              metric: 'celebration_time_ms', extra: {'planet': 'sound'});

          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.biggest.shortestSide * 0.5;

                        return SizedBox(
                          width: size,
                          height: size,
                          child: Lottie.asset(
                            'assets/animations/celebrate.json',
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tebrikler!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
