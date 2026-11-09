import 'dart:math';

import 'package:flutter/foundation.dart';

import 'session.dart';

/// Lifetime totals across every finished quiz. Persisted between launches.
@immutable
class Stats {
  const Stats({
    this.quizzesPlayed = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.bestStreak = 0,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      quizzesPlayed: json['quizzesPlayed'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  final int quizzesPlayed;
  final int questionsAnswered;
  final int correctAnswers;
  final int bestStreak;

  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;

  Stats record(QuizSession session) {
    return Stats(
      quizzesPlayed: quizzesPlayed + 1,
      questionsAnswered: questionsAnswered + session.answeredCount,
      correctAnswers: correctAnswers + session.correctCount,
      bestStreak: max(bestStreak, session.bestStreak),
    );
  }

  Map<String, dynamic> toJson() => {
    'quizzesPlayed': quizzesPlayed,
    'questionsAnswered': questionsAnswered,
    'correctAnswers': correctAnswers,
    'bestStreak': bestStreak,
  };

  @override
  bool operator ==(Object other) {
    return other is Stats &&
        other.quizzesPlayed == quizzesPlayed &&
        other.questionsAnswered == questionsAnswered &&
        other.correctAnswers == correctAnswers &&
        other.bestStreak == bestStreak;
  }

  @override
  int get hashCode =>
      Object.hash(quizzesPlayed, questionsAnswered, correctAnswers, bestStreak);
}
