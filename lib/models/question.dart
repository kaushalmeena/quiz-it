import 'dart:math';

import 'package:flutter/foundation.dart';

import 'difficulty.dart';
import 'choices.dart';

@immutable
class Question {
  const Question({
    required this.text,
    required this.category,
    required this.difficulty,
    required this.type,
    required this.correctAnswer,
    required this.answers,
    this.selectedAnswer,
    this.timedOut = false,
    this.points = 0,
  });

  /// Parses a result from the Open Trivia Database, requested with
  /// `encode=url3986` so every string is percent-encoded.
  factory Question.fromApi(Map<String, dynamic> json, {Random? random}) {
    final type = QuestionType.parse(json['type'] as String?);
    final correctAnswer = Uri.decodeComponent(json['correct_answer'] as String);
    final incorrectAnswers = (json['incorrect_answers'] as List)
        .cast<String>()
        .map(Uri.decodeComponent);

    final answers = [correctAnswer, ...incorrectAnswers];
    if (type == QuestionType.boolean) {
      // Keep True / False in a predictable order.
      answers.sort((a, b) => b.compareTo(a));
    } else {
      answers.shuffle(random);
    }

    return Question(
      text: Uri.decodeComponent(json['question'] as String),
      category: Uri.decodeComponent(json['category'] as String),
      difficulty: Difficulty.parse(json['difficulty'] as String?),
      type: type,
      correctAnswer: correctAnswer,
      answers: List.unmodifiable(answers),
    );
  }

  final String text;
  final String category;
  final Difficulty difficulty;
  final QuestionType type;
  final String correctAnswer;
  final List<String> answers;
  final String? selectedAnswer;

  /// The timer ran out before an answer was picked.
  final bool timedOut;

  /// Points earned for this question, including any speed bonus.
  final int points;

  bool get isAnswered => selectedAnswer != null || timedOut;

  bool get isCorrect => selectedAnswer == correctAnswer;

  Question answer(String answer, {int points = 0}) =>
      _copy(selectedAnswer: answer, points: points);

  Question timeOut() => _copy(timedOut: true);

  Question _copy({
    String? selectedAnswer,
    bool timedOut = false,
    int points = 0,
  }) {
    return Question(
      text: text,
      category: category,
      difficulty: difficulty,
      type: type,
      correctAnswer: correctAnswer,
      answers: answers,
      selectedAnswer: selectedAnswer,
      timedOut: timedOut,
      points: points,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Question &&
        other.text == text &&
        other.category == category &&
        other.difficulty == difficulty &&
        other.type == type &&
        other.correctAnswer == correctAnswer &&
        listEquals(other.answers, answers) &&
        other.selectedAnswer == selectedAnswer &&
        other.timedOut == timedOut &&
        other.points == points;
  }

  @override
  int get hashCode => Object.hash(
    text,
    category,
    difficulty,
    type,
    correctAnswer,
    Object.hashAll(answers),
    selectedAnswer,
    timedOut,
    points,
  );
}
