import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session.dart';
import '../../state/quiz.dart';
import '../../widgets/layout.dart';
import '../results/results.dart';
import 'feedback.dart';
import 'question_view.dart';

/// Plays the current session one question at a time.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const QuizScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizProvider);
    if (session == null) return const Scaffold();

    Future<void> handlePop(bool didPop, Object? result) async {
      if (didPop) return;
      final leave = await _confirmLeave(context);
      if (leave && context.mounted) Navigator.of(context).pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: handlePop,
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: Text('Question ${session.index + 1} of ${session.total}'),
          actions: [_ScorePill(session), const SizedBox(width: 16)],
          bottom: _Progress(session),
        ),
        body: SingleChildScrollView(
          padding: contentInsets(context).copyWith(top: 24, bottom: 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: _slideFade,
            child: QuestionView(
              key: ValueKey(session.index),
              question: session.current,
            ),
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnswerFeedback(session: session),
              const SizedBox(height: 12),
              _NextButton(session),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _slideFade(Widget child, Animation<double> animation) {
    final offset = Tween(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: offset, child: child),
    );
  }

  static Future<bool> _confirmLeave(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _LeaveDialog(),
    );
    return result ?? false;
  }
}

class _LeaveDialog extends StatelessWidget {
  const _LeaveDialog();

  @override
  Widget build(BuildContext context) {
    void stay() => Navigator.of(context).pop(false);
    void leave() => Navigator.of(context).pop(true);

    return AlertDialog(
      title: const Text('Leave this quiz?'),
      content: const Text("Your answers in this round won't be saved."),
      actions: [
        TextButton(onPressed: stay, child: const Text('Keep playing')),
        TextButton(onPressed: leave, child: const Text('Leave')),
      ],
    );
  }
}

class _NextButton extends ConsumerWidget {
  const _NextButton(this.session);

  final QuizSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answered = session.current.isAnswered;

    void handleNext() => ref.read(quizProvider.notifier).next();

    void handleFinish() {
      ref.read(quizProvider.notifier).finish();
      Navigator.of(context).pushReplacement(ResultsScreen.route());
    }

    final onPressed = !answered
        ? null
        : session.isLast
        ? handleFinish
        : handleNext;

    return FilledButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: Icon(
        session.isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded,
      ),
      label: Text(session.isLast ? 'See results' : 'Next question'),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill(this.session);

  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final streak = session.streak;

    return Semantics(
      label: '${session.correctCount} correct',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              streak >= 2
                  ? Icons.local_fire_department_rounded
                  : Icons.check_circle_rounded,
              size: 18,
              color: streak >= 2 ? Colors.deepOrange : scheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '${session.correctCount}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget implements PreferredSizeWidget {
  const _Progress(this.session);

  final QuizSession session;

  @override
  Size get preferredSize => const Size.fromHeight(4);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: session.answeredCount / session.total),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        minHeight: 4,
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}
