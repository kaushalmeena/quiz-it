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
    this.categories = const {},
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as Map<String, dynamic>? ?? const {};
    return Stats(
      quizzesPlayed: json['quizzesPlayed'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      categories: Map.unmodifiable({
        for (final entry in categories.entries)
          entry.key: CategoryRecord.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      }),
    );
  }

  final int quizzesPlayed;
  final int questionsAnswered;
  final int correctAnswers;
  final int bestStreak;

  /// Results per category, keyed by [categoryKey].
  final Map<String, CategoryRecord> categories;

  static String categoryKey(int? categoryId) => '${categoryId ?? 'any'}';

  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;

  CategoryRecord? forCategory(int? categoryId) =>
      categories[categoryKey(categoryId)];

  Stats record(QuizSession session) {
    final key = categoryKey(session.settings.categoryId);
    return Stats(
      quizzesPlayed: quizzesPlayed + 1,
      questionsAnswered: questionsAnswered + session.answeredCount,
      correctAnswers: correctAnswers + session.correctCount,
      bestStreak: max(bestStreak, session.bestStreak),
      categories: Map.unmodifiable({
        ...categories,
        key: (categories[key] ?? const CategoryRecord()).record(session),
      }),
    );
  }

  Map<String, dynamic> toJson() => {
    'quizzesPlayed': quizzesPlayed,
    'questionsAnswered': questionsAnswered,
    'correctAnswers': correctAnswers,
    'bestStreak': bestStreak,
    'categories': {
      for (final entry in categories.entries) entry.key: entry.value.toJson(),
    },
  };

  @override
  bool operator ==(Object other) {
    return other is Stats &&
        other.quizzesPlayed == quizzesPlayed &&
        other.questionsAnswered == questionsAnswered &&
        other.correctAnswers == correctAnswers &&
        other.bestStreak == bestStreak &&
        mapEquals(other.categories, categories);
  }

  @override
  int get hashCode => Object.hash(
    quizzesPlayed,
    questionsAnswered,
    correctAnswers,
    bestStreak,
    Object.hashAllUnordered(
      categories.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}

/// How a player has done in one category.
@immutable
class CategoryRecord {
  const CategoryRecord({
    this.quizzesPlayed = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.bestScore = 0,
  });

  factory CategoryRecord.fromJson(Map<String, dynamic> json) {
    return CategoryRecord(
      quizzesPlayed: json['quizzesPlayed'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      bestScore: (json['bestScore'] as num? ?? 0).toDouble(),
    );
  }

  final int quizzesPlayed;
  final int questionsAnswered;
  final int correctAnswers;

  /// Best share of correct answers in a single quiz, from 0 to 1.
  final double bestScore;

  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;

  CategoryRecord record(QuizSession session) {
    return CategoryRecord(
      quizzesPlayed: quizzesPlayed + 1,
      questionsAnswered: questionsAnswered + session.answeredCount,
      correctAnswers: correctAnswers + session.correctCount,
      bestScore: max(bestScore, session.score),
    );
  }

  Map<String, dynamic> toJson() => {
    'quizzesPlayed': quizzesPlayed,
    'questionsAnswered': questionsAnswered,
    'correctAnswers': correctAnswers,
    'bestScore': bestScore,
  };

  @override
  bool operator ==(Object other) {
    return other is CategoryRecord &&
        other.quizzesPlayed == quizzesPlayed &&
        other.questionsAnswered == questionsAnswered &&
        other.correctAnswers == correctAnswers &&
        other.bestScore == bestScore;
  }

  @override
  int get hashCode =>
      Object.hash(quizzesPlayed, questionsAnswered, correctAnswers, bestScore);
}
