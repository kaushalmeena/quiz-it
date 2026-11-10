import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/stats.dart';
import '../../utils/format.dart';

/// The line under the home headline: lifetime figures for a returning player,
/// or what to do for a first-time one.
class StatsSummary extends ConsumerWidget {
  const StatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (stats.quizzesPlayed == 0) {
      return Text(
        'Set your options, pick a topic and test yourself.',
        style: muted,
      );
    }

    final figure = TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final quizzes = stats.quizzesPlayed == 1 ? 'quiz' : 'quizzes';

    return Text.rich(
      TextSpan(
        style: muted,
        children: [
          TextSpan(text: formatNumber(stats.quizzesPlayed), style: figure),
          TextSpan(text: ' $quizzes · '),
          TextSpan(text: formatPercent(stats.accuracy), style: figure),
          const TextSpan(text: ' accuracy · best streak '),
          TextSpan(text: '${stats.bestStreak}', style: figure),
        ],
      ),
    );
  }
}
