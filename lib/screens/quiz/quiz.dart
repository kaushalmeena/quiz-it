import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session.dart';
import '../../state/effects.dart';
import '../../state/quiz.dart';
import '../../widgets/layout.dart';
import '../results/results.dart';
import 'countdown.dart';
import 'feedback.dart';
import 'question_view.dart';
import '../../theme/palette.dart';
import '../../theme/radii.dart';
import '../../utils/format.dart';

/// Keys that pick the first, second, third… answer.
final _answerKeys = [
  [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.numpad1,
    LogicalKeyboardKey.keyA,
  ],
  [
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.numpad2,
    LogicalKeyboardKey.keyB,
  ],
  [
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.numpad3,
    LogicalKeyboardKey.keyC,
  ],
  [
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.numpad4,
    LogicalKeyboardKey.keyD,
  ],
];

final _advanceKeys = {
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.numpadEnter,
  LogicalKeyboardKey.arrowRight,
};

/// Moves to the next question, or to the results after the last one.
void advanceQuiz(BuildContext context, WidgetRef ref) {
  final session = ref.read(quizProvider);
  if (session == null || !session.current.isAnswered) return;
  if (!session.isLast) {
    ref.read(quizProvider.notifier).next();
    return;
  }
  ref.read(quizProvider.notifier).finish();
  Navigator.of(context).pushReplacement(ResultsScreen.route());
}

/// Plays the current session one question at a time.
///
/// On keyboards, 1–4 (or A–D) pick an answer and Enter moves on.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const QuizScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizProvider);
    if (session == null) return const Scaffold();

    ref.listen(quizProvider, (previous, next) {
      if (previous == null || next == null || previous.index != next.index) {
        return;
      }
      if (!previous.current.isAnswered && next.current.isAnswered) {
        ref
            .read(effectsProvider)
            .play(next.current.isCorrect ? Effect.correct : Effect.wrong);
      }
    });

    Future<void> handlePop(bool didPop, Object? result) async {
      if (didPop) return;
      final leave = await _confirmLeave(context);
      if (leave && context.mounted) Navigator.of(context).pop();
    }

    KeyEventResult handleKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      final key = event.logicalKey;
      final question = session.current;

      if (_advanceKeys.contains(key) && question.isAnswered) {
        advanceQuiz(context, ref);
        return KeyEventResult.handled;
      }

      final index = _answerKeys.indexWhere((keys) => keys.contains(key));
      if (index != -1 && index < question.answers.length) {
        ref.read(quizProvider.notifier).answer(question.answers[index]);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: handlePop,
      child: Focus(
        autofocus: true,
        onKeyEvent: handleKey,
        child: Scaffold(
          appBar: AppBar(
            leading: const CloseButton(),
            title: Text(
              '${session.isDaily ? 'Daily · ' : ''}'
              'Question ${session.index + 1} of ${session.total}',
            ),
            actions: [_ScorePill(session), const SizedBox(width: 16)],
            bottom: _Progress(session),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            // Clip to the full screen width so questions slide in from the
            // screen edge rather than from the content column's edge.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (session.isTimed)
                  Padding(
                    padding: contentInsets(context).copyWith(bottom: 20),
                    child: Countdown(
                      key: ValueKey(session.index),
                      session: session,
                    ),
                  ),
                ClipRect(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: _stackTop,
                    transitionBuilder: _slideFor(session.index),
                    child: Padding(
                      key: ValueKey(session.index),
                      padding: contentInsets(context),
                      child: QuestionView(question: session.current),
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }

  /// Slides the new question in from the right and the old one out to the
  /// left. The builder is recreated each build, so AnimatedSwitcher re-wraps
  /// the outgoing question with the leftward slide.
  static AnimatedSwitcherTransitionBuilder _slideFor(int index) {
    return (child, animation) {
      final incoming = child.key == ValueKey(index);
      final offset = Tween(
        begin: Offset(incoming ? 1 : -1, 0),
        end: Offset.zero,
      ).animate(animation);
      return SlideTransition(position: offset, child: child);
    };
  }

  static Widget _stackTop(Widget? current, List<Widget> previous) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [...previous, ?current],
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
    void handlePressed() => advanceQuiz(context, ref);

    return FilledButton.icon(
      onPressed: session.current.isAnswered ? handlePressed : null,
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
      label: '${session.points} points',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: Radii.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (streak >= 2) ...[
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: Palette.of(context).streak,
              ),
              Text(
                '$streak',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Icon(Icons.star_rounded, size: 18, color: scheme.primary),
            const SizedBox(width: 4),
            TweenAnimationBuilder<int>(
              tween: IntTween(end: session.points),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, _) => Text(
                formatNumber(value),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
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
