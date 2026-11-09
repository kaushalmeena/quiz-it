import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_it/data/daily_bank.dart';

import '../fixtures.dart';

void main() {
  List<Map<String, dynamic>> bank(int size) => [
    for (var i = 0; i < size; i++)
      apiQuestion(
        question: 'Q$i',
        correct: 'A$i',
        incorrect: ['B$i', 'C$i', 'D$i'],
      ),
  ];

  List<String> texts(DailyBank bank, DateTime day) =>
      bank.questionsFor(day).map((q) => q.text).toList();

  test('everyone gets the same questions and answer order on a day', () {
    final day = DateTime(2026, 11, 9, 8);
    final a = DailyBank(bank(100)).questionsFor(day);
    final b = DailyBank(bank(100)).questionsFor(DateTime(2026, 11, 9, 23));

    expect(a, hasLength(DailyBank.questionsPerDay));
    expect(a, b);
  });

  test('consecutive days get different questions until the bank cycles', () {
    final daily = DailyBank(bank(30));
    final seen = <String>{
      ...texts(daily, DateTime(2026, 1, 1)),
      ...texts(daily, DateTime(2026, 1, 2)),
      ...texts(daily, DateTime(2026, 1, 3)),
    };

    expect(seen, hasLength(30));
    expect(
      texts(daily, DateTime(2026, 1, 4)),
      texts(daily, DateTime(2026, 1, 1)),
    );
  });

  test('the bundled bank parses into full days of questions', () {
    final raw = File(DailyBank.asset).readAsStringSync();
    final daily = DailyBank(
      (json.decode(raw) as List).cast<Map<String, dynamic>>(),
    );

    expect(daily.size, greaterThanOrEqualTo(1000));
    for (var day = 0; day < daily.size ~/ DailyBank.questionsPerDay; day++) {
      final questions = daily.questionsFor(DateTime(2026, 1, 1 + day));
      expect(questions, hasLength(DailyBank.questionsPerDay));
      expect(
        questions.every((q) => q.answers.contains(q.correctAnswer)),
        isTrue,
      );
    }
  });
}
