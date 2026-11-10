import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bank.dart';
import '../../state/clock.dart';
import '../../state/daily.dart';
import '../../theme/palette.dart';
import '../../theme/radii.dart';
import '../../utils/format.dart';
import '../../widgets/start.dart';
import '../quiz/screen.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Today's daily challenge: play it, or see today's result and the streak.
class DailyCard extends ConsumerWidget {
  const DailyCard({super.key});

  void _openQuiz(BuildContext context) {
    Navigator.of(context).push(QuizScreen.route());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyProvider);
    final today = ref.watch(clockProvider)();
    final done = progress.isDoneOn(today);
    final streak = progress.streakOn(today);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = Palette.of(context);
    final date =
        '${_weekdays[today.weekday - 1]} ${today.day} ${_months[today.month - 1]}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: done
                        ? palette.successContainer
                        : scheme.primaryContainer,
                    borderRadius: Radii.medium,
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : Icons.today_rounded,
                    size: 22,
                    color: done
                        ? palette.onSuccessContainer
                        : scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily challenge',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (streak > 0) _Streak(days: streak),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              done
                  ? 'You scored ${progress.lastCorrect} of ${progress.lastTotal} '
                        'for ${formatNumber(progress.lastPoints)} points. '
                        'A new set unlocks tomorrow.'
                  : '${DailyBank.questionsPerDay} timed questions, the same for '
                        'everyone today.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (!done) ...[
              const SizedBox(height: 16),
              StartQuizButton(
                label: "Play today's challenge",
                icon: Icons.bolt_rounded,
                daily: true,
                tonal: true,
                onStarted: _openQuiz,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Streak extends StatelessWidget {
  const _Streak({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$days day streak',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: Palette.of(context).streak,
          ),
          const SizedBox(width: 4),
          Text(
            days == 1 ? '1 day' : '$days days',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
