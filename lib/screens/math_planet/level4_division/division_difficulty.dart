import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'division_page.dart';

class DivisionDifficultyPage extends StatelessWidget {
  const DivisionDifficultyPage({super.key});

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  Widget _levelButton({
    required BuildContext context,
    required String title,
    required String diff,
    required double width,
    required double height,
    required double fontSize,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DivisionPage(difficulty: diff)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1F2B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);
    final titleSize   = isTablet ? 40.0 : 28.0;
    final gapSmall    = isTablet ? 20.0 : 12.0;
    final gapLarge    = isTablet ? 28.0 : 14.0;
    final btnHeight   = isTablet ? 92.0 : 70.0;
    final btnFont     = isTablet ? 30.0 : 24.0;
    final maxBtnWidth = isTablet ? 540.0 : 410.0;
    final btnWidth    = math.min(size.width * (isTablet ? 0.55 : 0.85), maxBtnWidth);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1224),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
                vertical: isTablet ? 24 : 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bölme - Zorluk Seviyesi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: gapLarge),
                  _levelButton(
                    context: context,
                    title: 'Kolay',
                    diff: 'easy',
                    width: btnWidth,
                    height: btnHeight,
                    fontSize: btnFont,
                  ),
                  SizedBox(height: gapSmall),
                  _levelButton(
                    context: context,
                    title: 'Orta',
                    diff: 'medium',
                    width: btnWidth,
                    height: btnHeight,
                    fontSize: btnFont,
                  ),
                  SizedBox(height: gapSmall),
                  _levelButton(
                    context: context,
                    title: 'Zor',
                    diff: 'hard',
                    width: btnWidth,
                    height: btnHeight,
                    fontSize: btnFont,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
