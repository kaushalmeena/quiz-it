import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session.dart';
import '../../state/quiz.dart';

/// Time left for the current question in a timed quiz. Times the question out
/// when it reaches zero, and freezes once an answer is picked.
///
/// Give it a key per question so each question gets a fresh countdown.
class Countdown extends ConsumerStatefulWidget {
  const Countdown({super.key, required this.session});

  final QuizSession session;

  @override
  ConsumerState<Countdown> createState() => _CountdownState();
}

class _CountdownState extends ConsumerState<Countdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final limit = QuizSession.timeLimit;
    final used = ref
        .read(clockProvider)()
        .difference(widget.session.questionStartedAt);

    _controller = AnimationController(vsync: this, duration: limit)
      ..value = used.inMilliseconds / limit.inMilliseconds
      ..addStatusListener(_handleStatus);
    if (!widget.session.current.isAnswered) _controller.forward();
  }

  @override
  void didUpdateWidget(Countdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.current.isAnswered) _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (status.isCompleted) ref.read(quizProvider.notifier).timeOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final left = 1 - _controller.value;
        final seconds = (QuizSession.timeLimit.inMilliseconds * left / 1000)
            .ceil();
        final urgent = seconds <= 5;
        final color = urgent ? scheme.error : scheme.primary;

        return Semantics(
          label: '$seconds seconds left',
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 20, color: color),
              const SizedBox(width: 6),
              SizedBox(
                width: 32,
                child: Text(
                  '${seconds}s',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: left,
                    minHeight: 6,
                    color: color,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
