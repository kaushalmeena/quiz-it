import 'package:flutter/foundation.dart';

import 'session.dart';

/// The calendar day of [time] in local time, as `yyyy-mm-dd`.
String dayKey(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)}';
}

/// Daily challenge history: the latest result and the streak of
/// consecutive days played. Persisted between launches.
@immutable
class DailyProgress {
  const DailyProgress({
    this.lastDay,
    this.lastCorrect = 0,
    this.lastTotal = 0,
    this.lastPoints = 0,
    this.streak = 0,
    this.bestStreak = 0,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      lastDay: json['lastDay'] as String?,
      lastCorrect: json['lastCorrect'] as int? ?? 0,
      lastTotal: json['lastTotal'] as int? ?? 0,
      lastPoints: json['lastPoints'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  /// The last day a daily challenge was finished, as a [dayKey].
  final String? lastDay;
  final int lastCorrect;
  final int lastTotal;
  final int lastPoints;

  /// Consecutive days played, up to [lastDay].
  final int streak;
  final int bestStreak;

  bool isDoneOn(DateTime today) => lastDay == dayKey(today);

  /// The streak as of [today]: it only survives if yesterday or today was
  /// played.
  int streakOn(DateTime today) {
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    return lastDay == dayKey(today) || lastDay == dayKey(yesterday)
        ? streak
        : 0;
  }

  DailyProgress complete(QuizSession session, DateTime today) {
    if (isDoneOn(today)) return this;
    final newStreak = streakOn(today) + 1;
    return DailyProgress(
      lastDay: dayKey(today),
      lastCorrect: session.correctCount,
      lastTotal: session.total,
      lastPoints: session.points,
      streak: newStreak,
      bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
    );
  }

  Map<String, dynamic> toJson() => {
    'lastDay': lastDay,
    'lastCorrect': lastCorrect,
    'lastTotal': lastTotal,
    'lastPoints': lastPoints,
    'streak': streak,
    'bestStreak': bestStreak,
  };

  @override
  bool operator ==(Object other) {
    return other is DailyProgress &&
        other.lastDay == lastDay &&
        other.lastCorrect == lastCorrect &&
        other.lastTotal == lastTotal &&
        other.lastPoints == lastPoints &&
        other.streak == streak &&
        other.bestStreak == bestStreak;
  }

  @override
  int get hashCode => Object.hash(
    lastDay,
    lastCorrect,
    lastTotal,
    lastPoints,
    streak,
    bestStreak,
  );
}
