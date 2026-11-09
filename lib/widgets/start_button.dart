import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api.dart';
import '../state/quiz.dart';

/// Loads a new quiz with the current settings, showing progress in place and
/// errors in a snack bar. Calls [onStarted] once the questions are ready.
class StartQuizButton extends ConsumerStatefulWidget {
  const StartQuizButton({
    super.key,
    required this.label,
    required this.onStarted,
    this.icon = Icons.play_arrow_rounded,
    this.daily = false,
    this.tonal = false,
  });

  final String label;
  final IconData icon;

  /// Starts today's daily challenge instead of a quiz with the user's settings.
  final bool daily;

  /// A secondary action: tonal instead of filled, for when another button on
  /// screen is the primary one.
  final bool tonal;
  final void Function(BuildContext context) onStarted;

  @override
  ConsumerState<StartQuizButton> createState() => _StartQuizButtonState();
}

class _StartQuizButtonState extends ConsumerState<StartQuizButton> {
  bool _loading = false;

  Future<void> _start() async {
    if (_loading) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    try {
      final quiz = ref.read(quizProvider.notifier);
      await (widget.daily ? quiz.startDaily() : quiz.start());
      if (mounted) widget.onStarted(context);
    } on TriviaException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(label: 'Retry', onPressed: _start),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spinnerColor = widget.tonal
        ? scheme.onSecondaryContainer
        : scheme.onPrimary;
    final icon = _loading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: spinnerColor,
            ),
          )
        : Icon(widget.icon);
    final label = Text(_loading ? 'Loading questions…' : widget.label);

    // The button stays the same size and colour while loading; only the icon
    // and label swap, so nothing around it shifts.
    return widget.tonal
        ? FilledButton.tonalIcon(onPressed: _start, icon: icon, label: label)
        : FilledButton.icon(onPressed: _start, icon: icon, label: label);
  }
}
