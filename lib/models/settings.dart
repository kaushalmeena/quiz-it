import 'package:flutter/foundation.dart';

import 'difficulty.dart';
import 'question_type.dart';

/// What the next quiz should look like. Persisted between launches.
@immutable
class QuizSettings {
  const QuizSettings({
    this.categoryId,
    this.difficulty = Difficulty.any,
    this.type = QuestionType.any,
    this.amount = 10,
  });

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    return QuizSettings(
      categoryId: json['categoryId'] as int?,
      difficulty: Difficulty.parse(json['difficulty'] as String?),
      type: QuestionType.parse(json['type'] as String?),
      amount: amounts.contains(amount) ? amount as int : 10,
    );
  }

  static const amounts = [5, 10, 15, 20];

  /// `null` means any category.
  final int? categoryId;
  final Difficulty difficulty;
  final QuestionType type;
  final int amount;

  QuizSettings withCategory(int? categoryId) => QuizSettings(
    categoryId: categoryId,
    difficulty: difficulty,
    type: type,
    amount: amount,
  );

  QuizSettings withDifficulty(Difficulty difficulty) => QuizSettings(
    categoryId: categoryId,
    difficulty: difficulty,
    type: type,
    amount: amount,
  );

  QuizSettings withType(QuestionType type) => QuizSettings(
    categoryId: categoryId,
    difficulty: difficulty,
    type: type,
    amount: amount,
  );

  QuizSettings withAmount(int amount) => QuizSettings(
    categoryId: categoryId,
    difficulty: difficulty,
    type: type,
    amount: amount,
  );

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'difficulty': difficulty.name,
    'type': type.name,
    'amount': amount,
  };

  @override
  bool operator ==(Object other) {
    return other is QuizSettings &&
        other.categoryId == categoryId &&
        other.difficulty == difficulty &&
        other.type == type &&
        other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(categoryId, difficulty, type, amount);
}
