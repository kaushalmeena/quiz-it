import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_it/models/question.dart';
import 'package:quiz_it/models/session.dart';
import 'package:quiz_it/models/settings.dart';

import '../fixtures.dart';

void main() {
  final start = DateTime(2026, 1, 1, 12);
  final questions = [
    Question.fromApi(apiQuestion(question: 'A')),
    Question.fromApi(apiQuestion(question: 'B')),
  ];

  QuizSession session({bool timed = false}) => QuizSession(
    questions: questions,
    settings: QuizSettings(timed: timed),
    startedAt: start,
  );

  test('untimed answers earn base points only', () {
    final later = start.add(const Duration(minutes: 5));
    final answered = session().answerCurrent('4', at: later);

    expect(answered.points, QuizSession.basePoints);
  });

  test('timed answers earn a bonus that shrinks with time', () {
    int pointsAfter(int seconds) =>
        session(timed: true)
            .answerCurrent('4', at: start.add(Duration(seconds: seconds)))
            .points;

    expect(pointsAfter(0), 200);
    expect(pointsAfter(10), 150);
    expect(pointsAfter(20), 100);
    expect(pointsAfter(60), 100);
  });

  test('wrong answers and timeouts earn nothing', () {
    expect(session(timed: true).answerCurrent('5', at: start).points, 0);

    final timedOut = session(timed: true).timeOutCurrent();
    expect(timedOut.current.isAnswered, isTrue);
    expect(timedOut.current.isCorrect, isFalse);
    expect(timedOut.points, 0);
  });

  test('the bonus is measured from when each question was shown', () {
    final second = start.add(const Duration(seconds: 30));
    final points = session(timed: true)
        .answerCurrent('4', at: start)
        .next(at: second)
        .answerCurrent('4', at: second.add(const Duration(seconds: 10)))
        .points;

    expect(points, 200 + 150);
  });
}
