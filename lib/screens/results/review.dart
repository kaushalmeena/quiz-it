import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/session.dart';
import '../../theme/palette.dart';

/// Every question with the player's answer and, if wrong, the right one.
class AnswerReview extends StatelessWidget {
  const AnswerReview({super.key, required this.session});

  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < session.total; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReviewCard(number: i + 1, question: session.questions[i]),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.number, required this.question});

  final int number;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = Palette.of(context);
    final correct = question.isCorrect;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 20,
                  color: correct ? palette.success : scheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Question $number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  question.difficulty.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(question.text, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _AnswerLine(
              label: 'Your answer',
              value: question.selectedAnswer ?? 'Skipped',
              color: correct ? palette.success : scheme.error,
            ),
            if (!correct) ...[
              const SizedBox(height: 4),
              _AnswerLine(
                label: 'Correct answer',
                value: question.correctAnswer,
                color: palette.success,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}
