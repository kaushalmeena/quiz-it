import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/stats.dart';
import '../../widgets/stat_tile.dart';

/// Lifetime stats; hidden until the first quiz is finished.
class StatsSummary extends ConsumerWidget {
  const StatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    if (stats.quizzesPlayed == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: StatRow(
        children: [
          StatTile(
            icon: Icons.emoji_events_outlined,
            value: '${stats.quizzesPlayed}',
            label: stats.quizzesPlayed == 1 ? 'Quiz played' : 'Quizzes played',
          ),
          StatTile(
            icon: Icons.track_changes_rounded,
            value: '${(stats.accuracy * 100).round()}%',
            label: 'Accuracy',
          ),
          StatTile(
            icon: Icons.local_fire_department_outlined,
            value: '${stats.bestStreak}',
            label: 'Best streak',
          ),
        ],
      ),
    );
  }
}
