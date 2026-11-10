// Renders the README screenshots into screenshots/.
//
//   flutter test tool/screenshots --update-goldens
//
// Uses the Roboto and Material Icons fonts that ship with the Flutter SDK,
// a fixed date, seeded stats and a fixed set of questions, so the images are
// reproducible. Not part of the regular `flutter test` run (it lives outside
// test/), because pixel output varies across machines.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_it/app.dart';
import 'package:quiz_it/data/api.dart';
import 'package:quiz_it/models/progress.dart';
import 'package:quiz_it/state/clock.dart';
import 'package:quiz_it/state/daily.dart';
import 'package:quiz_it/state/effects.dart';
import 'package:quiz_it/state/session.dart';
import 'package:quiz_it/state/settings.dart';
import 'package:quiz_it/state/stats.dart';
import 'package:quiz_it/state/storage.dart';

/// iPhone-sized: 390 × 844 points at 3x.
const _size = Size(1170, 2532);
const _pixelRatio = 3.0;

final _questions = [
  _q('What is the capital of Australia?', 'Canberra', [
    'Sydney',
    'Melbourne',
    'Perth',
  ], 'easy'),
  _q('Which river flows through Cairo?', 'Nile', [
    'Tigris',
    'Danube',
    'Congo',
  ], 'easy'),
  _q('What is the largest ocean on Earth?', 'Pacific Ocean', [
    'Atlantic Ocean',
    'Indian Ocean',
    'Arctic Ocean',
  ], 'easy'),
  _q('Mount Kilimanjaro is located in which country?', 'Tanzania', [
    'Kenya',
    'Uganda',
    'Ethiopia',
  ], 'medium'),
  _q('Which country has the most natural lakes?', 'Canada', [
    'Russia',
    'United States',
    'Finland',
  ], 'medium'),
  _q('What is the smallest country in the world by area?', 'Vatican City', [
    'Monaco',
    'San Marino',
    'Liechtenstein',
  ], 'medium'),
  _q('What is the largest hot desert in the world?', 'Sahara', [
    'Gobi',
    'Kalahari',
    'Arabian',
  ], 'medium'),
  _q('Reykjavik is the capital of which country?', 'Iceland', [
    'Norway',
    'Finland',
    'Denmark',
  ], 'easy'),
  _q('Which South American country is named after the equator?', 'Ecuador', [
    'Colombia',
    'Peru',
    'Brazil',
  ], 'medium'),
  _q('In which country is the ancient city of Petra?', 'Jordan', [
    'Egypt',
    'Israel',
    'Syria',
  ], 'hard'),
];

Map<String, dynamic> _q(
  String question,
  String correct,
  List<String> incorrect,
  String difficulty,
) {
  return {
    'type': 'multiple',
    'difficulty': difficulty,
    'category': 'Geography',
    'question': Uri.encodeComponent(question),
    'correct_answer': Uri.encodeComponent(correct),
    'incorrect_answers': incorrect.map(Uri.encodeComponent).toList(),
  };
}

String _correct(int i) =>
    Uri.decodeComponent(_questions[i]['correct_answer'] as String);

String _wrong(int i) =>
    Uri.decodeComponent((_questions[i]['incorrect_answers'] as List).first);

http.Client _api() => MockClient((request) async {
  if (request.url.path == '/api_token.php') {
    return http.Response(json.encode({'response_code': 0, 'token': 't'}), 200);
  }
  return http.Response(
    json.encode({'response_code': 0, 'results': _questions}),
    200,
  );
});

/// A returning player: some history, a live daily streak, Geography picked.
MemoryStorage _storage() {
  final today = DateTime(2026, 11, 9);
  return MemoryStorage({
    SettingsNotifier.storageKey: json.encode({
      'categoryId': 22,
      'difficulty': 'any',
      'type': 'multiple',
      'amount': 10,
      'timed': true,
    }),
    StatsNotifier.storageKey: json.encode({
      'quizzesPlayed': 14,
      'questionsAnswered': 140,
      'correctAnswers': 109,
      'bestStreak': 12,
      'categories': {
        'any': {
          'quizzesPlayed': 4,
          'questionsAnswered': 40,
          'correctAnswers': 29,
          'bestScore': 0.8,
        },
        '9': {
          'quizzesPlayed': 3,
          'questionsAnswered': 30,
          'correctAnswers': 24,
          'bestScore': 0.9,
        },
        '22': {
          'quizzesPlayed': 5,
          'questionsAnswered': 50,
          'correctAnswers': 41,
          'bestScore': 1.0,
        },
        '11': {
          'quizzesPlayed': 2,
          'questionsAnswered': 20,
          'correctAnswers': 15,
          'bestScore': 0.8,
        },
      },
    }),
    DailyNotifier.storageKey: json.encode({
      'lastDay': dayKey(today.subtract(const Duration(days: 1))),
      'lastCorrect': 8,
      'lastTotal': 10,
      'lastPoints': 1310,
      'streak': 6,
      'bestStreak': 6,
    }),
  });
}

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('Run through `flutter test`.');
  final dir = '$root/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File('$dir/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

/// Pumps the app with a controllable clock. Returns a function that moves
/// the clock and the test's frames forward together.
Future<Future<void> Function(Duration)> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = _pixelRatio;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  var now = DateTime(2026, 11, 9, 9, 41);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(_storage()),
        clockProvider.overrideWithValue(() => now),
        effectsProvider.overrideWithValue(SilentEffects()),
        triviaApiProvider.overrideWithValue(
          TriviaApi(client: _api(), random: Random(7)),
        ),
      ],
      child: const QuizItApp(),
    ),
  );

  final context = tester.element(find.byType(Scaffold).first);
  await tester.runAsync(
    () => precacheImage(const AssetImage('assets/launcher.png'), context),
  );
  await tester.pumpAndSettle();

  // Pump real frames (not one big jump) so animations run to their end.
  return (Duration step) async {
    const frame = Duration(milliseconds: 16);
    var left = step;
    while (left > Duration.zero) {
      final next = left < frame ? left : frame;
      now = now.add(next);
      await tester.pump(next);
      left -= next;
    }
  };
}

Future<void> _startQuiz(WidgetTester tester) async {
  await tester.tap(find.text('Start quiz · 10 questions'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _snap(String name) async {
  await expectLater(
    find.byType(QuizItApp),
    matchesGoldenFile('../../screenshots/$name.png'),
  );
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('home', (tester) async {
    await _pumpApp(tester);
    await _snap('home');
  });

  testWidgets('quiz and results', (tester) async {
    final advance = await _pumpApp(tester);
    await _startQuiz(tester);

    // Three quick right answers, then a fourth to show the streak.
    for (var i = 0; i < 3; i++) {
      await advance(const Duration(seconds: 3));
      await tester.tap(find.text(_correct(i)));
      await advance(const Duration(milliseconds: 300));
      await tester.tap(find.text('Next question'));
      await advance(const Duration(milliseconds: 500));
    }
    await advance(const Duration(seconds: 4));
    await tester.tap(find.text(_correct(3)));
    await advance(const Duration(milliseconds: 400));
    await _snap('quiz');

    // Finish the round with one miss.
    await tester.tap(find.text('Next question'));
    await advance(const Duration(milliseconds: 500));
    for (var i = 4; i < 10; i++) {
      await advance(const Duration(seconds: 5));
      await tester.tap(find.text(i == 6 ? _wrong(i) : _correct(i)));
      await advance(const Duration(milliseconds: 300));
      await tester.tap(find.text(i == 9 ? 'See results' : 'Next question'));
      await advance(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();
    await _snap('results');
  });
}
