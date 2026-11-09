import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_it/models/category.dart';
import 'package:quiz_it/models/difficulty.dart';
import 'package:quiz_it/models/question.dart';
import 'package:quiz_it/models/question_type.dart';

import '../fixtures.dart';

void main() {
  test('decodes percent-encoded fields', () {
    final question = Question.fromApi(
      apiQuestion(question: 'Who wrote "Hamlet" & co?', correct: 'Shakespeare'),
      random: Random(1),
    );

    expect(question.text, 'Who wrote "Hamlet" & co?');
    expect(question.category, 'Science: Mathematics');
    expect(question.difficulty, Difficulty.easy);
    expect(question.type, QuestionType.multiple);
    expect(question.answers, containsAll(['Shakespeare', '3', '5', '22']));
    expect(question.answers, hasLength(4));
    expect(question.isAnswered, isFalse);
  });

  test('keeps true / false answers in a fixed order', () {
    final question = Question.fromApi(
      apiQuestion(type: 'boolean', correct: 'False', incorrect: ['True']),
    );

    expect(question.answers, ['True', 'False']);
  });

  test('answer() records the selection without mutating', () {
    final question = Question.fromApi(apiQuestion());
    final right = question.answer('4');
    final wrong = question.answer('5');

    expect(question.isAnswered, isFalse);
    expect(right.isCorrect, isTrue);
    expect(wrong.isAnswered, isTrue);
    expect(wrong.isCorrect, isFalse);
  });

  test('shortens category names', () {
    expect(Category.shortName('Entertainment: Film'), 'Film');
    expect(Category.shortName('History'), 'History');
  });
}
