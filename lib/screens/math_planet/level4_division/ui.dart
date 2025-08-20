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

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTablet(context);
    final double qFont = compact
        ? (size.shortestSide * (isTablet ? 0.075 : 0.065)).clamp(22.0, isTablet ? 56.0 : 40.0).toDouble()
        : prominent
        ? (size.shortestSide * (isTablet ? 0.085 : 0.075)).clamp(28.0, isTablet ? 64.0 : 52.0).toDouble()
        : (isTablet ? 34.0 : 28.0);

    // Kapsül genişlik/padding ayarları
    final double maxW = compact
        ? size.width * (isTablet ? 0.55 : 0.45)
        : size.width * (isTablet ? 0.70 : 0.85);
    final double maxWClamped = compact
        ? maxW.clamp(240.0, isTablet ? 520.0 : 380.0)
        : maxW;

    final double padH = compact ? (isTablet ? 20 : 16) : (isTablet ? 26 : 22);
    final double padV = compact ? (isTablet ? 10 : 8) : (isTablet ? 14 : 10);
    final double borderW = isTablet ? 1.2 : 1.0;
    final double shadowBlur = isTablet ? 14 : 12;

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
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: borderW),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: shadowBlur, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              title,
              if (showProgress) ...[
                SizedBox(height: isTablet ? 8 : 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: compact ? (isTablet ? 8 : 6) : (isTablet ? 10 : 8),
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4FA6)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepLabel,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

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

    final isTablet = _isTablet(context);

    return Align(
      alignment: Alignment.centerRight,
      child: SafeArea(
        minimum: const EdgeInsets.only(right: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availH = constraints.maxHeight;
            final doorCount = q.options.length;
            final spacing = isTablet ? gap + 2 : gap;
            double idealDoorH =
            doorCount > 0 ? ((availH - spacing * (doorCount - 1)) / doorCount) : 0.0;
            final maxDoorH = isTablet ? 200.0 : 160.0;
            final minDoorH = 80.0;

            double doorH = idealDoorH.clamp(minDoorH, maxDoorH);
            double contentH = doorCount * doorH + (doorCount - 1) * spacing;
            if (contentH > availH) {
              doorH = ((availH - spacing * (doorCount - 1)) / doorCount).clamp(minDoorH, maxDoorH);
              contentH = doorCount * doorH + (doorCount - 1) * spacing;
            }

            final doorW = doorH * 0.62;

            return SizedBox(
              height: contentH,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(doorCount, (i) {
                  final opt = q.options[i];
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

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final barWidth = isTablet ? (width * 1.5) : (width * 1.2);
    final minH = isTablet ? 20.0 : 10.0;
    final stepFont = isTablet ? 18.0 : 12.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: barWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: minH,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4FA6)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stepLabel,
            style: TextStyle(color: Colors.white70, fontSize: stepFont),
          ),
        ],
      ),
    );
  }
}
