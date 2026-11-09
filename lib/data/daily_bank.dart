import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/question.dart';

/// A fixed bank of questions bundled with the app, so every player gets the
/// same daily challenge on the same day, even offline.
///
/// Built with `dart run tool/build_daily_bank.dart`.
class DailyBank {
  DailyBank(List<Map<String, dynamic>> questions)
    : _questions = List.unmodifiable(questions),
      _order = List.generate(questions.length, (i) => i)
        ..shuffle(Random(_seed));

  static const asset = 'assets/daily/questions.json';
  static const questionsPerDay = 10;

  /// Fixes the order the bank is played through. Changing it changes every
  /// day's questions.
  static const _seed = 20261109;

  /// Day zero of the rotation.
  static final _epoch = DateTime.utc(2026, 1, 1);

  static Future<DailyBank> load(AssetBundle bundle) async {
    final raw = await bundle.loadString(asset);
    return DailyBank((json.decode(raw) as List).cast<Map<String, dynamic>>());
  }

  final List<Map<String, dynamic>> _questions;
  final List<int> _order;

  int get size => _questions.length;

  /// The questions for the calendar day of [day]. The bank is walked in a
  /// fixed shuffled order, so a 1000-question bank lasts 100 days before
  /// questions come round again. Answer order is fixed per day too.
  List<Question> questionsFor(DateTime day) {
    final index = DateTime.utc(
      day.year,
      day.month,
      day.day,
    ).difference(_epoch).inDays;
    final random = Random(index);
    final count = min(questionsPerDay, size);

    return List.unmodifiable([
      for (var i = 0; i < count; i++)
        Question.fromApi(
          _questions[_order[(index * questionsPerDay + i) % size]],
          random: random,
        ),
    ]);
  }
}
