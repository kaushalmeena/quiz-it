import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bank.dart';
import '../models/progress.dart';
import '../models/session.dart';
import 'clock.dart';
import 'storage.dart';

final dailyBankProvider = FutureProvider<DailyBank>(
  (ref) => DailyBank.load(rootBundle),
);

final dailyProvider = NotifierProvider<DailyNotifier, DailyProgress>(
  DailyNotifier.new,
);

/// The daily challenge streak and latest result, remembered between launches.
class DailyNotifier extends Notifier<DailyProgress> {
  static const storageKey = 'quiz_it.daily.v1';

  @override
  DailyProgress build() {
    final raw = ref.read(storageProvider).read(storageKey);
    if (raw == null) return const DailyProgress();
    try {
      return DailyProgress.fromJson(json.decode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const DailyProgress();
    }
  }

  void complete(QuizSession session) {
    final day = session.dailyDay;
    final today = day == null ? ref.read(clockProvider)() : DateTime.parse(day);
    final updated = state.complete(session, today);
    if (updated == state) return;
    state = updated;
    ref.read(storageProvider).write(storageKey, json.encode(state.toJson()));
  }
}
