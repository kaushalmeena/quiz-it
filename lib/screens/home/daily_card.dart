import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_bank.dart';
import '../../state/clock.dart';
import '../../state/daily.dart';
import '../../widgets/start_button.dart';
import '../quiz/quiz.dart';

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
    final date =
        '${_weekdays[today.weekday - 1]}, ${today.day} ${_months[today.month - 1]}';

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.today_rounded, color: scheme.onPrimaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Daily challenge',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StreakChip(streak: streak),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              done
                  ? '$date · You scored ${progress.lastCorrect}/${progress.lastTotal} '
                        'for ${progress.lastPoints} points. Back tomorrow!'
                  : '$date · ${DailyBank.questionsPerDay} timed questions, '
                        'the same for everyone today.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 14),
            if (done)
              FilledButton.tonalIcon(
                onPressed: null,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Done for today'),
              )
            else
              StartQuizButton(
                label: "Play today's challenge",
                icon: Icons.bolt_rounded,
                daily: true,
                onStarted: _openQuiz,
              ),
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$streak day streak',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 16,
              color: streak > 0 ? Colors.deepOrange : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              streak == 1 ? '1 day' : '$streak days',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
