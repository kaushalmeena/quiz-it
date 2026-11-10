import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_it/models/progress.dart';
import 'package:quiz_it/models/question.dart';
import 'package:quiz_it/models/session.dart';

import '../fixtures.dart';

void main() {
  final session = QuizSession(
    questions: [Question.fromApi(apiQuestion()).answer('4', points: 150)],
    startedAt: DateTime(2026),
    dailyDay: '2026-03-01',
  );

  test('dayKey pads month and day', () {
    expect(dayKey(DateTime(2026, 3, 9, 23, 59)), '2026-03-09');
  });

  test('streak grows on consecutive days and resets after a gap', () {
    var progress = const DailyProgress();

    progress = progress.complete(session, DateTime(2026, 2, 28));
    progress = progress.complete(session, DateTime(2026, 3, 1));
    expect(progress.streak, 2);
    expect(progress.lastPoints, 150);
    expect(progress.isDoneOn(DateTime(2026, 3, 1, 22)), isTrue);

    // Still alive the next day, gone the day after.
    expect(progress.streakOn(DateTime(2026, 3, 2)), 2);
    expect(progress.streakOn(DateTime(2026, 3, 3)), 0);

    progress = progress.complete(session, DateTime(2026, 3, 3));
    expect(progress.streak, 1);
    expect(progress.bestStreak, 2);
  });

  test('a day only counts once', () {
    final once = const DailyProgress().complete(session, DateTime(2026, 3, 1));
    expect(once.complete(session, DateTime(2026, 3, 1)), once);
  });

  test('round-trips through JSON', () {
    final progress = const DailyProgress().complete(
      session,
      DateTime(2026, 3, 1),
    );
    expect(DailyProgress.fromJson(progress.toJson()), progress);
  });
}
