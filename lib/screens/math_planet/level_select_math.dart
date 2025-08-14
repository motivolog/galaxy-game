import 'package:flutter/material.dart';
import 'level1_addition/addition_difficulty.dart';
import 'level5_quiz/level5_meteor_quiz_page.dart';


class LevelSelectMathScreen extends StatelessWidget {
  const LevelSelectMathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = <_LevelInfo>[
      _LevelInfo(number: 1, title: 'Toplama', unlocked: true,  progress: 0.7),
      _LevelInfo(number: 2, title: 'Çıkarma',     unlocked: false, progress: 0.0),
      _LevelInfo(number: 3, title: 'Çarpma',     unlocked: false, progress: 0.0),
      _LevelInfo(number: 4, title: 'Bölme',      unlocked: false, progress: 0.0),
      _LevelInfo(number: 5, title: 'Meteor Quiz',       unlocked: false, progress: 0.0),
    ];

    final w = MediaQuery.of(context).size.width;

    int crossAxisCount;
    double aspect;
    if (w >= 1000) { crossAxisCount = 4; aspect = 3/4; }
    else if (w >= 700) { crossAxisCount = 3; aspect = 3/4; }
    else { crossAxisCount = 2; aspect = 4/5; }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1224), Color(0xFF0B0F1D)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: levels.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: aspect,
            ),
            itemBuilder: (_, i) => _LevelCard(
              info: levels[i],
              onTap: () {
                if (!levels[i].unlocked) return;

                switch (levels[i].number) {
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdditionDifficultyPage(),
                      ),
                    );
                    break;




                  case 5: // Meteor Quiz
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  Level5MeteorQuizPage()),
                    );
                    break;


                }
              },

            ),
          ),
        ),
      ),
    );
  }
}

class _LevelInfo {
  final int number;
  final String title;
  final bool unlocked;
  final double progress;
  const _LevelInfo({
    required this.number, required this.title,
    required this.unlocked, required this.progress,
  });
}

class _LevelCard extends StatefulWidget {
  const _LevelCard({required this.info, required this.onTap});
  final _LevelInfo info;
  final VoidCallback onTap;

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final unlocked = widget.info.unlocked;
    final baseColor = unlocked ? const Color(0xFF2C3E50) : const Color(0xFF1E2730);

    return GestureDetector(
      onTapDown: (_) => setState(() => _hover = true),
      onTapCancel: () => setState(() => _hover = false),
      onTapUp: (_) => setState(() => _hover = false),
      onTap: unlocked ? widget.onTap : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _hover ? 0.98 : 1.0,
        child: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    baseColor.withOpacity(0.95),
                    baseColor.withOpacity(0.80),
                  ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12, offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          unlocked ? Icons.auto_awesome : Icons.lock,
                          color: unlocked ? Colors.amberAccent : Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("Level ${widget.info.number}",
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  Text(
                    widget.info.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    unlocked ? "Hazır" : "Kilidi açmak için önceki seviyeyi bitir",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: unlocked ? Colors.white70 : Colors.white38,
                    ),
                  ),
                  const Spacer(),

                  _ProgressBar(value: widget.info.progress, enabled: unlocked),
                ],
              ),
            ),


            if (!unlocked)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.35),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.enabled});
  final double value; // 0..1
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(0.10);
    final fg = enabled ? Colors.lightBlueAccent : Colors.white24;

    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(color: fg),
        ),
      ),
    );
  }
}
