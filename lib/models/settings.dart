import 'package:flutter/foundation.dart';

import 'difficulty.dart';
import 'choices.dart';

/// What the next quiz should look like. Persisted between launches.
@immutable
class QuizSettings {
  const QuizSettings({
    this.categoryId,
    this.difficulty = Difficulty.any,
    this.type = QuestionType.any,
    this.amount = 10,
    this.timed = false,
  });

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    return QuizSettings(
      categoryId: json['categoryId'] as int?,
      difficulty: Difficulty.parse(json['difficulty'] as String?),
      type: QuestionType.parse(json['type'] as String?),
      amount: amounts.contains(amount) ? amount as int : 10,
      timed: json['timed'] as bool? ?? false,
    );
  }

  static const amounts = [5, 10, 15, 20];

  /// `null` means any category.
  final int? categoryId;
  final Difficulty difficulty;
  final QuestionType type;
  final int amount;

  /// Each question has a time limit, and fast answers earn bonus points.
  final bool timed;

  QuizSettings withCategory(int? categoryId) => QuizSettings(
    categoryId: categoryId,
    difficulty: difficulty,
    type: type,
    amount: amount,
    timed: timed,
  );

  QuizSettings withDifficulty(Difficulty difficulty) =>
      _copy(difficulty: difficulty);

  QuizSettings withType(QuestionType type) => _copy(type: type);

  QuizSettings withAmount(int amount) => _copy(amount: amount);

  QuizSettings withTimed(bool timed) => _copy(timed: timed);

  QuizSettings _copy({
    Difficulty? difficulty,
    QuestionType? type,
    int? amount,
    bool? timed,
  }) {
    return QuizSettings(
      categoryId: categoryId,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      timed: timed ?? this.timed,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'difficulty': difficulty.name,
    'type': type.name,
    'amount': amount,
    'timed': timed,
  };

  @override
  bool operator ==(Object other) {
    return other is QuizSettings &&
        other.categoryId == categoryId &&
        other.difficulty == difficulty &&
        other.type == type &&
        other.amount == amount &&
        other.timed == timed;
  }

  @override
  int get hashCode => Object.hash(categoryId, difficulty, type, amount, timed);
}
