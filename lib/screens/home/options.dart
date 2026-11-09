import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/difficulty.dart';
import '../../models/question_type.dart';
import '../../models/session.dart';
import '../../models/settings.dart';
import '../../state/settings.dart';

/// Difficulty, question type and length pickers.
class QuizOptions extends StatelessWidget {
  const QuizOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Option(label: 'Difficulty', picker: _DifficultyPicker()),
            SizedBox(height: 20),
            _Option(label: 'Question type', picker: _TypePicker()),
            SizedBox(height: 20),
            _Option(label: 'Number of questions', picker: _AmountPicker()),
            SizedBox(height: 20),
            _TimedSwitch(),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.label, required this.picker});

  final String label;
  final Widget picker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        picker,
      ],
    );
  }
}

class _DifficultyPicker extends ConsumerWidget {
  const _DifficultyPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider.select((s) => s.difficulty));

    void handleChanged(Set<Difficulty> selection) {
      ref.read(settingsProvider.notifier).selectDifficulty(selection.single);
    }

    return SegmentedButton<Difficulty>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      selected: {selected},
      onSelectionChanged: handleChanged,
      segments: [
        for (final difficulty in Difficulty.values)
          ButtonSegment(value: difficulty, label: Text(difficulty.label)),
      ],
    );
  }
}

class _TypePicker extends ConsumerWidget {
  const _TypePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider.select((s) => s.type));

    void handleChanged(Set<QuestionType> selection) {
      ref.read(settingsProvider.notifier).selectType(selection.single);
    }

    return SegmentedButton<QuestionType>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      selected: {selected},
      onSelectionChanged: handleChanged,
      segments: [
        for (final type in QuestionType.values)
          ButtonSegment(value: type, label: Text(type.label)),
      ],
    );
  }
}

class _AmountPicker extends ConsumerWidget {
  const _AmountPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider.select((s) => s.amount));

    void handleChanged(Set<int> selection) {
      ref.read(settingsProvider.notifier).selectAmount(selection.single);
    }

    return SegmentedButton<int>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      selected: {selected},
      onSelectionChanged: handleChanged,
      segments: [
        for (final amount in QuizSettings.amounts)
          ButtonSegment(value: amount, label: Text('$amount')),
      ],
    );
  }
}

class _TimedSwitch extends ConsumerWidget {
  const _TimedSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timed = ref.watch(settingsProvider.select((s) => s.timed));
    final seconds = QuizSession.timeLimit.inSeconds;

    void handleChanged(bool value) {
      ref.read(settingsProvider.notifier).setTimed(value);
    }

    final theme = Theme.of(context);

    // Laid out like the other options: label on the left edge, control on
    // the right, rather than a list tile with its own icon and type sizes.
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timed mode',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$seconds s per question. Faster answers earn bonus points.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: timed, onChanged: handleChanged),
        ],
      ),
    );
  }
}
