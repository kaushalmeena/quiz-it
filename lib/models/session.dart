import 'dart:math';

import 'package:flutter/foundation.dart';

import 'question.dart';

/// One round of questions, from start to results.
@immutable
class QuizSession {
  const QuizSession({
    required this.questions,
    required this.startedAt,
    this.index = 0,
    this.finishedAt,
  });

  final List<Question> questions;
  final int index;
  final DateTime startedAt;
  final DateTime? finishedAt;

  Question get current => questions[index];

  int get total => questions.length;

  bool get isLast => index == questions.length - 1;

  bool get isFinished => finishedAt != null;

  int get answeredCount => questions.where((q) => q.isAnswered).length;

  int get correctCount => questions.where((q) => q.isCorrect).length;

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

  QuizSession answerCurrent(String answer) {
    return _copy(
      questions: List.unmodifiable([
        for (var i = 0; i < questions.length; i++)
          i == index ? questions[i].answer(answer) : questions[i],
      ]),
    );
  }

  QuizSession next() => _copy(index: min(index + 1, questions.length - 1));

  QuizSession finish(DateTime at) => _copy(finishedAt: at);

  QuizSession _copy({
    List<Question>? questions,
    int? index,
    DateTime? finishedAt,
  }) {
    return QuizSession(
      questions: questions ?? this.questions,
      index: index ?? this.index,
      startedAt: startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuizSession &&
        listEquals(other.questions, questions) &&
        other.index == index &&
        other.startedAt == startedAt &&
        other.finishedAt == finishedAt;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(questions), index, startedAt, finishedAt);
}
