import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api.dart';
import '../models/session.dart';
import 'settings.dart';
import 'stats.dart';

final triviaApiProvider = Provider<TriviaApi>((ref) => TriviaApi());

/// The current time. Overridden in tests to control timers and points.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final quizProvider = NotifierProvider<QuizNotifier, QuizSession?>(
  QuizNotifier.new,
);

/// The current (or most recently finished) quiz. `null` before the first one.
class QuizNotifier extends Notifier<QuizSession?> {
  @override
  QuizSession? build() => null;

  /// Fetches a fresh set of questions for the current settings.
  ///
  /// Throws a [TriviaException] when questions can't be loaded; the previous
  /// session is left untouched in that case.
  Future<void> start() async {
    final settings = ref.read(settingsProvider);
    final questions = await ref
        .read(triviaApiProvider)
        .fetchQuestions(settings);
    if (!ref.mounted) return;
    state = QuizSession(
      questions: questions,
      settings: settings,
      startedAt: _now(),
    );
  }

  /// Locks in an answer for the current question. Answers can't be changed.
  void answer(String answer) {
    final session = state;
    if (session == null || session.isFinished || session.current.isAnswered) {
      return;
    }
    state = session.answerCurrent(answer, at: _now());
  }

  /// Marks the current question as unanswered in time (timed quizzes only).
  void timeOut() {
    final session = state;
    if (session == null ||
        !session.isTimed ||
        session.isFinished ||
        session.current.isAnswered) {
      return;
    }
    state = session.timeOutCurrent();
  }

  void next() {
    final session = state;
    if (session == null || session.isLast || !session.current.isAnswered) {
      return;
    }
    state = session.next(at: _now());
  }

  /// Ends the quiz and adds it to the lifetime stats.
  void finish() {
    final session = state;
    if (session == null || session.isFinished) return;

    final finished = session.finish(_now());
    state = finished;
    ref.read(statsProvider.notifier).record(finished);
  }

  DateTime _now() => ref.read(clockProvider)();
}
