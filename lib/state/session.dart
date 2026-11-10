import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api.dart';
import '../models/progress.dart';
import '../models/session.dart';
import '../models/settings.dart';
import 'clock.dart';
import 'daily.dart';
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
    state = QuizSession(
      questions: questions,
      settings: settings,
      startedAt: _now(),
    );
  }

  /// Starts today's daily challenge: the same timed questions for everyone.
  Future<void> startDaily() async {
    final bank = await ref.read(dailyBankProvider.future);
    if (!ref.mounted) return;
    final now = _now();
    state = QuizSession(
      questions: bank.questionsFor(now),
      settings: const QuizSettings(timed: true),
      dailyDay: dayKey(now),
      startedAt: now,
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
    if (finished.isDaily) ref.read(dailyProvider.notifier).complete(finished);
  }

  DateTime _now() => ref.read(clockProvider)();
}
