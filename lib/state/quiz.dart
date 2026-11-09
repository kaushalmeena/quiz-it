import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api.dart';
import '../models/session.dart';
import 'settings.dart';
import 'stats.dart';

final triviaApiProvider = Provider<TriviaApi>((ref) => TriviaApi());

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
    state = QuizSession(questions: questions, startedAt: DateTime.now());
  }

  /// Locks in an answer for the current question. Answers can't be changed.
  void answer(String answer) {
    final session = state;
    if (session == null || session.isFinished || session.current.isAnswered) {
      return;
    }
    state = session.answerCurrent(answer);
  }

  void next() {
    final session = state;
    if (session == null || session.isLast || !session.current.isAnswered) {
      return;
    }
    state = session.next();
  }

  /// Ends the quiz and adds it to the lifetime stats.
  void finish() {
    final session = state;
    if (session == null || session.isFinished) return;

    final finished = session.finish(DateTime.now());
    state = finished;
    ref.read(statsProvider.notifier).record(finished);
  }
}
