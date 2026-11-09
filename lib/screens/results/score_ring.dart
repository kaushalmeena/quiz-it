import 'package:flutter/material.dart';

import '../../theme/palette.dart';

/// Animated circular score with the percentage in the middle.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    required this.correct,
    required this.total,
  });

  final double score;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = score >= 0.5 ? Palette.of(context).success : scheme.primary;

    return Semantics(
      label: 'Score: $correct of $total correct',
      child: SizedBox.square(
        dimension: 176,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '$correct of $total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
