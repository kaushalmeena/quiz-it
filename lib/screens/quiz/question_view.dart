import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../models/question.dart';
import '../../state/quiz.dart';
import '../../theme/palette.dart';
import '../../theme/radii.dart';

/// A question with its tags and answer options.
class QuestionView extends StatelessWidget {
  const QuestionView({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Tag(Category.shortName(question.category)),
            _Tag(question.difficulty.label),
          ],
        ),
        const SizedBox(height: 16),
        Text(question.text, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 28),
        for (var i = 0; i < question.answers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AnswerTile(question: question, index: i),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: Radii.small,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

enum _AnswerState { idle, correct, wrong, dimmed }

class _AnswerTile extends ConsumerWidget {
  const _AnswerTile({required this.question, required this.index});

  final Question question;
  final int index;

  String get answer => question.answers[index];

  _AnswerState get state {
    if (!question.isAnswered) return _AnswerState.idle;
    if (answer == question.correctAnswer) return _AnswerState.correct;
    if (answer == question.selectedAnswer) return _AnswerState.wrong;
    return _AnswerState.dimmed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = Palette.of(context);
    final state = this.state;
    const radius = Radii.medium;

    void handleTap() => ref.read(quizProvider.notifier).answer(answer);

    final (background, border, foreground) = switch (state) {
      _AnswerState.idle => (
        scheme.surfaceContainerLow,
        scheme.outlineVariant,
        scheme.onSurface,
      ),
      _AnswerState.correct => (
        palette.successContainer,
        palette.success,
        palette.onSuccessContainer,
      ),
      _AnswerState.wrong => (
        scheme.errorContainer,
        scheme.error,
        scheme.onErrorContainer,
      ),
      _AnswerState.dimmed => (
        scheme.surface,
        scheme.outlineVariant,
        scheme.onSurfaceVariant,
      ),
    };

    final (badgeColor, onBadge) = switch (state) {
      _AnswerState.correct => (palette.success, palette.onSuccess),
      _AnswerState.wrong => (scheme.error, scheme.onError),
      _ => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };

    final badge = switch (state) {
      _AnswerState.correct => Icon(
        Icons.check_rounded,
        size: 18,
        color: onBadge,
      ),
      _AnswerState.wrong => Icon(Icons.close_rounded, size: 18, color: onBadge),
      _ => Text(
        String.fromCharCode(65 + index),
        style: theme.textTheme.labelLarge?.copyWith(
          color: onBadge,
          fontWeight: FontWeight.w700,
        ),
      ),
    };

    return Semantics(
      button: state == _AnswerState.idle,
      selected: answer == question.selectedAnswer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: Border.all(color: border, width: 1.5),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: state == _AnswerState.idle ? handleTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: badge,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      answer,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
