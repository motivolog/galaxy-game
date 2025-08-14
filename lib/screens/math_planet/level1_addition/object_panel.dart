import 'dart:math';
import 'package:flutter/material.dart';

class ObjectPanel extends StatelessWidget {
  const ObjectPanel({
    super.key,
    required this.count,
    required this.asset,
    required this.maxTargetSize,
    required this.semantic,
    required this.pulse,
  });

  final int count;
  final String asset;
  final double maxTargetSize;
  final String semantic;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;

    return Semantics(
      label: semantic,
      child: AnimatedScale(
        scale: pulse ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1D3A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: LayoutBuilder(
            builder: (_, cons) {
              final maxW = cons.maxWidth;
              int perRow = max(1, (maxW / (maxTargetSize + gap)).floor());
              perRow = perRow.clamp(1, max(1, count));
              if (count > 1) perRow = max(2, perRow);

              final tile = ((maxW - gap * (perRow - 1)) / perRow)
                  .clamp(24.0, maxTargetSize);

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(
                  count,
                      (_) => Image.asset(asset, width: tile, height: tile),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
