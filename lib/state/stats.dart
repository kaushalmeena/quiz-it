import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../models/statistics.dart';
import 'storage.dart';

final statsProvider = NotifierProvider<StatsNotifier, Stats>(StatsNotifier.new);

/// Lifetime totals across finished quizzes, remembered between launches.
class StatsNotifier extends Notifier<Stats> {
  static const storageKey = 'quiz_it.stats.v1';

  @override
  Stats build() {
    final raw = ref.read(storageProvider).read(storageKey);
    if (raw == null) return const Stats();
    try {
      return Stats.fromJson(json.decode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const Stats();
    }
  }

  void record(QuizSession session) {
    state = state.record(session);
    ref.read(storageProvider).write(storageKey, json.encode(state.toJson()));
  }
}
