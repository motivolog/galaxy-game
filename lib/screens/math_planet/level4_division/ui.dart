import 'package:flutter/material.dart';
import 'division_game.dart';
import 'components.dart';

class DivisionHud extends StatelessWidget {
  const DivisionHud({
    super.key,
    required this.questionText,
    required this.progress,
    required this.stepLabel,
    this.capsule = false,
    this.compact = false,
    this.showProgress = false,
    this.prominent = false,
  });

  final String questionText;
  final double progress;
  final String stepLabel;
  final bool capsule;
  final bool compact;
  final bool showProgress;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double qFont = compact
        ? (size.shortestSide * 0.065).clamp(22.0, 40.0).toDouble()
        : prominent
        ? (size.shortestSide * 0.075).clamp(28.0, 52.0).toDouble()
        : 28.0;
    final double maxW = compact ? size.width * 0.45 : size.width * 0.85;
    final double maxWClamped = compact ? maxW.clamp(220.0, 380.0) : maxW;

    Widget title = Text(
      questionText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: qFont,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: const [
          Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(0, 1)),
        ],
      ),
    );

    if (capsule) {
      title = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWClamped),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 22,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              title,
              if (showProgress) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: compact ? 6 : 8, // mini bar
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4FA6)), // pembe
                  ),
                ),
                const SizedBox(height: 4),
                Text(stepLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ],
          ),
        ),
      );
    }

    return title;
  }
}
class DoorsOverlay extends StatelessWidget {
  const DoorsOverlay({
    super.key,
    required this.game,
    this.gap = 6.0,
  });

  final DivisionGame game;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final q = game.current;
    final disabled = game.state != QuizState.presenting || q == null;
    if (q == null) return const SizedBox.shrink();
    const doorAssets = [
      'assets/images/planet3/door1.png',
      'assets/images/planet3/door2.png',
      'assets/images/planet3/door3.png',
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: SafeArea(
        minimum: const EdgeInsets.only(right: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availH = constraints.maxHeight;
            final doorCount = q.options.length;
            final spacing = gap;

            double doorH = doorCount > 0
                ? ((availH - spacing * (doorCount - 1)) / doorCount).floorToDouble()
                : 0.0;
            doorH = doorH.clamp(80.0, 180.0);

            final contentH = doorCount * doorH + (doorCount - 1) * spacing;
            final doorW = doorH * 0.62;

            return SizedBox(
              height: contentH,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(doorCount, (i) {
                  final opt   = q.options[i];
                  final asset = doorAssets[i % doorAssets.length];

                  final door = DoorView(
                    label: opt.toString(),
                    imageAsset: asset,
                    disabled: disabled,
                    width: doorW,
                    height: doorH,
                    onTap: disabled ? () {} : () => game.onAnswerSelected(opt),
                  );

                  if (i == doorCount - 1) return door;
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: door,
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
class TopRightMiniProgressBar extends StatelessWidget {
  const TopRightMiniProgressBar({
    super.key,
    required this.progress,
    required this.stepLabel,
    this.width = 180,
  });

  final double progress;
  final String stepLabel;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4FA6)),
            ),
          ),
          const SizedBox(height: 4),
          Text(stepLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
