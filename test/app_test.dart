import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_it/app.dart';
import 'package:quiz_it/data/api.dart';
import 'package:quiz_it/state/effects.dart';
import 'package:quiz_it/state/quiz.dart';
import 'package:quiz_it/state/settings.dart';
import 'package:quiz_it/state/storage.dart';

import 'fixtures.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  http.Client? client,
  Storage? storage,
  Effects? effects,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage ?? MemoryStorage()),
        effectsProvider.overrideWithValue(effects ?? SilentEffects()),
        triviaApiProvider.overrideWithValue(
          TriviaApi(client: client ?? mockTrivia()),
        ),
      ],
      child: const QuizItApp(),
    ),
  );
}

void main() {
  testWidgets('plays a full round from setup to results', (tester) async {
    final effects = SilentEffects();
    await pumpApp(
      tester,
      effects: effects,
      client: mockTrivia(
        results: [
          apiQuestion(question: 'First?', correct: 'Yes', incorrect: ['No']),
          apiQuestion(question: 'Second?', correct: 'Up', incorrect: ['Down']),
        ],
      ),
    );

    await tester.tap(find.text('Start quiz · 10 questions'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 2'), findsOneWidget);
    expect(find.text('First?'), findsOneWidget);
    expect(find.text('Choose an answer'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Correct! +100'), findsOneWidget);

    await tester.tap(find.text('Next question'));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 2'), findsOneWidget);

    await tester.tap(find.text('Down'));
    await tester.pumpAndSettle();
    expect(find.text('Answer: Up'), findsOneWidget);

    await tester.tap(find.text('See results'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Not bad!'), findsOneWidget);
    // No confetti for 50%.
    expect(effects.played, [Effect.correct, Effect.wrong]);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Lifetime stats and the category record now show on the home screen.
    expect(find.text('Quiz played'), findsOneWidget);
    final record = find.text('Best 50% · 50% accuracy');
    await tester.scrollUntilVisible(record, 200);
    expect(record, findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('shows an error when questions fail to load', (tester) async {
    await pumpApp(tester, client: mockTrivia(responseCode: 1));

    await tester.tap(find.text('Start quiz · 10 questions'));
    await tester.pumpAndSettle();

    expect(find.text(TriviaError.notEnoughQuestions.message), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Ready for a round?'), findsOneWidget);
  });

  testWidgets('asks before leaving a quiz', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Start quiz · 10 questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Leave this quiz?'), findsOneWidget);
    await tester.tap(find.text('Keep playing'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 3'), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for a round?'), findsOneWidget);
  });

  testWidgets('can be played with the keyboard', (tester) async {
    await pumpApp(
      tester,
      client: mockTrivia(
        results: [
          apiQuestion(
            question: 'Pick true',
            type: 'boolean',
            correct: 'True',
            incorrect: ['False'],
          ),
          apiQuestion(question: 'Second?'),
        ],
      ),
    );

    await tester.tap(find.text('Start quiz · 10 questions'));
    await tester.pumpAndSettle();

    // Enter does nothing until an answer is picked.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 2'), findsOneWidget);

    // True / False answers are ordered True first, so "1" picks True.
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    expect(find.text('Correct! +100'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 2'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsOneWidget);
  });

  testWidgets('times out questions in timed mode', (tester) async {
    await pumpApp(
      tester,
      storage: MemoryStorage({SettingsNotifier.storageKey: '{"timed": true}'}),
    );
    await tester.tap(find.text('Start quiz · 10 questions'));
    // The countdown keeps animating, so pump frames instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('20s'), findsOneWidget);

    await tester.pump(const Duration(seconds: 21));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text("Time's up! Answer: 4"), findsOneWidget);
    expect(find.text('0s'), findsOneWidget);
  });

  testWidgets('celebrates high scores', (tester) async {
    final effects = SilentEffects();
    await pumpApp(
      tester,
      effects: effects,
      client: mockTrivia(results: [apiQuestion()]),
    );

    await tester.tap(find.text('Start quiz · 10 questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See results'));
    await tester.pumpAndSettle();

    expect(find.text('Outstanding!'), findsOneWidget);
    expect(effects.played, [Effect.correct, Effect.celebrate]);
  });

  testWidgets('remembers the sound setting', (tester) async {
    final storage = MemoryStorage();
    await pumpApp(tester, storage: storage);

    await tester.tap(find.byTooltip('Mute sound effects'));
    await tester.pump();

    expect(find.byTooltip('Turn on sound effects'), findsOneWidget);
    expect(storage.values[SoundNotifier.storageKey], 'off');
  });
}
