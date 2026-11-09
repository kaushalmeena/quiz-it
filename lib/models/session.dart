import 'dart:math';

import 'package:flutter/foundation.dart';

import 'question.dart';
import 'settings.dart';

/// One round of questions, from start to results.
@immutable
class QuizSession {
  const QuizSession({
    required this.questions,
    required this.startedAt,
    this.settings = const QuizSettings(),
    this.index = 0,
    DateTime? questionStartedAt,
    this.finishedAt,
  }) : questionStartedAt = questionStartedAt ?? startedAt;

  /// Points for any correct answer.
  static const basePoints = 100;

  /// Extra points for answering instantly in a timed quiz, falling linearly
  /// to zero at the time limit.
  static const maxBonus = 100;

  /// Time allowed per question in a timed quiz.
  static const timeLimit = Duration(seconds: 20);

  final List<Question> questions;

  /// The settings this round was started with.
  final QuizSettings settings;

  final int index;
  final DateTime startedAt;

  /// When the current question was first shown.
  final DateTime questionStartedAt;

  final DateTime? finishedAt;

  Question get current => questions[index];

  int get total => questions.length;

  bool get isLast => index == questions.length - 1;

  bool get isFinished => finishedAt != null;

  bool get isTimed => settings.timed;

  int get answeredCount => questions.where((q) => q.isAnswered).length;

  int get correctCount => questions.where((q) => q.isCorrect).length;

  int get points => questions.fold(0, (sum, q) => sum + q.points);

  double get score => total == 0 ? 0 : correctCount / total;

  Duration get elapsed => (finishedAt ?? DateTime.now()).difference(startedAt);

  /// Correct answers in a row, counting back from the latest answer.
  int get streak {
    var streak = 0;
    for (final question in questions.reversed.where((q) => q.isAnswered)) {
      if (!question.isCorrect) break;
      streak++;
    }
    return streak;
  }

  /// Longest run of correct answers in this session.
  int get bestStreak {
    var best = 0;
    var run = 0;
    for (final question in questions) {
      run = question.isCorrect ? run + 1 : 0;
      best = max(best, run);
    }
    return best;
  }

  /// Points a correct answer given at [at] would earn.
  int pointsAt(DateTime at) {
    if (!isTimed) return basePoints;
    final used = at.difference(questionStartedAt).inMilliseconds;
    final left = 1 - used / timeLimit.inMilliseconds;
    return basePoints + (maxBonus * left.clamp(0.0, 1.0)).round();
  }

  QuizSession answerCurrent(String answer, {required DateTime at}) {
    final points = answer == current.correctAnswer ? pointsAt(at) : 0;
    return _replaceCurrent(current.answer(answer, points: points));
  }

  QuizSession timeOutCurrent() => _replaceCurrent(current.timeOut());

  QuizSession next({required DateTime at}) =>
      _copy(index: min(index + 1, questions.length - 1), questionStartedAt: at);

  QuizSession finish(DateTime at) => _copy(finishedAt: at);

  QuizSession _replaceCurrent(Question question) {
    return _copy(
      questions: List.unmodifiable([
        for (var i = 0; i < questions.length; i++)
          i == index ? question : questions[i],
      ]),
    );
  }

  QuizSession _copy({
    List<Question>? questions,
    int? index,
    DateTime? questionStartedAt,
    DateTime? finishedAt,
  }) {
    return QuizSession(
      questions: questions ?? this.questions,
      settings: settings,
      index: index ?? this.index,
      startedAt: startedAt,
      questionStartedAt: questionStartedAt ?? this.questionStartedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuizSession &&
        listEquals(other.questions, questions) &&
        other.settings == settings &&
        other.index == index &&
        other.startedAt == startedAt &&
        other.questionStartedAt == questionStartedAt &&
        other.finishedAt == finishedAt;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(questions),
    settings,
    index,
    startedAt,
    questionStartedAt,
    finishedAt,
  );
}
