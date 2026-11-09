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
  });

  final String label;
  final IconData icon;
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
      await ref.read(quizProvider.notifier).start();
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
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    // The button stays the same size and colour while loading; only the icon
    // and label swap, so nothing around it shifts.
    return FilledButton.icon(
      onPressed: _start,
      icon: _loading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: onPrimary,
              ),
            )
          : Icon(widget.icon),
      label: Text(_loading ? 'Loading questions…' : widget.label),
    );
  }
}
