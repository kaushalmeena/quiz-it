import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_it/data/api.dart';
import 'package:quiz_it/models/difficulty.dart';
import 'package:quiz_it/models/question_type.dart';
import 'package:quiz_it/state/quiz.dart';
import 'package:quiz_it/state/settings.dart';
import 'package:quiz_it/state/stats.dart';
import 'package:quiz_it/state/storage.dart';

import '../fixtures.dart';

ProviderContainer createContainer({http.Client? client, Storage? storage}) {
  return ProviderContainer.test(
    overrides: [
      storageProvider.overrideWithValue(storage ?? MemoryStorage()),
      triviaApiProvider.overrideWithValue(
        TriviaApi(client: client ?? mockTrivia()),
      ),
    ],
  );
}

void main() {
  test('settings changes are applied and persisted', () {
    final storage = MemoryStorage();
    final container = createContainer(storage: storage);
    final settings = container.read(settingsProvider.notifier);

    settings
      ..selectCategory(18)
      ..selectDifficulty(Difficulty.hard)
      ..selectType(QuestionType.boolean)
      ..selectAmount(20);

    final state = container.read(settingsProvider);
    expect(state.categoryId, 18);
    expect(state.difficulty, Difficulty.hard);
    expect(state.type, QuestionType.boolean);
    expect(state.amount, 20);

    // A new app launch reads the same settings back.
    final relaunched = createContainer(storage: storage);
    expect(relaunched.read(settingsProvider), state);
  });

  test('ignores corrupt stored data', () {
    final container = createContainer(
      storage: MemoryStorage({SettingsNotifier.storageKey: '{oops'}),
    );

    expect(container.read(settingsProvider).amount, 10);
  });

  test('start() fetches questions using the current settings', () async {
    final requests = <Uri>[];
    final container = createContainer(client: mockTrivia(requests: requests));
    container.read(settingsProvider.notifier).selectAmount(5);

    await container.read(quizProvider.notifier).start();

    expect(requests.single.queryParameters['amount'], '5');
    expect(container.read(quizProvider)?.total, 3);
    expect(container.read(quizProvider)?.index, 0);
  });

  test('start() surfaces API errors and keeps the old session', () async {
    final container = createContainer(client: mockTrivia(responseCode: 1));

    await expectLater(
      container.read(quizProvider.notifier).start(),
      throwsA(
        isA<TriviaException>().having(
          (e) => e.error,
          'error',
          TriviaError.notEnoughQuestions,
        ),
      ),
    );
    expect(container.read(quizProvider), isNull);
  });

  test('a full round updates the session and the stats', () async {
    final storage = MemoryStorage();
    final container = createContainer(storage: storage);
    final quiz = container.read(quizProvider.notifier);
    await quiz.start();

    // Can't skip ahead without answering.
    quiz.next();
    expect(container.read(quizProvider)!.index, 0);

    quiz.answer('4');
    // The first answer is final.
    quiz.answer('5');
    expect(container.read(quizProvider)!.current.selectedAnswer, '4');

    quiz
      ..next()
      ..answer('4')
      ..next()
      ..answer('3')
      // Already on the last question.
      ..next();

    final session = container.read(quizProvider)!;
    expect(session.index, 2);
    expect(session.correctCount, 2);
    expect(session.bestStreak, 2);
    expect(session.streak, 0);

    quiz
      ..finish()
      // Finishing twice doesn't double count.
      ..finish();

    final stats = container.read(statsProvider);
    expect(container.read(quizProvider)!.isFinished, isTrue);
    expect(stats.quizzesPlayed, 1);
    expect(stats.questionsAnswered, 3);
    expect(stats.correctAnswers, 2);
    expect(stats.bestStreak, 2);

    final relaunched = createContainer(storage: storage);
    expect(relaunched.read(statsProvider), stats);
  });
}
