import 'package:flutter/material.dart';

import '../../models/session.dart';
import '../../theme/palette.dart';

/// One line of feedback above the next button. Always the same height, so
/// answering never shifts the layout.
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({super.key, required this.session});

  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final question = session.current;

    final (IconData icon, String text, Color color) = !question.isAnswered
        ? (
            Icons.touch_app_outlined,
            'Choose an answer',
            scheme.onSurfaceVariant,
          )
        : question.isCorrect
        ? (
            Icons.celebration_outlined,
            session.streak >= 2
                ? 'Correct! ${session.streak} in a row'
                : 'Correct!',
            Palette.of(context).success,
          )
        : (
            Icons.info_outline_rounded,
            'Answer: ${question.correctAnswer}',
            scheme.error,
          );

    return SizedBox(
      height: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Row(
          key: ValueKey(text),
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
