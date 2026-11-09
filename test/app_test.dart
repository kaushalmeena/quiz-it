import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_it/app.dart';
import 'package:quiz_it/data/api.dart';
import 'package:quiz_it/state/quiz.dart';
import 'package:quiz_it/state/storage.dart';

import 'fixtures.dart';

Future<void> pumpApp(WidgetTester tester, {http.Client? client}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(MemoryStorage()),
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
    await pumpApp(
      tester,
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
    expect(find.text('Correct!'), findsOneWidget);

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

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Lifetime stats now show on the home screen.
    expect(find.text('Quiz played'), findsOneWidget);
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
}
