import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_it/data/api.dart';
import 'package:quiz_it/models/difficulty.dart';
import 'package:quiz_it/models/question_type.dart';
import 'package:quiz_it/models/settings.dart';

import '../fixtures.dart';

void main() {
  test('omits "any" filters from the request', () {
    final uri = TriviaApi.questionsUri(const QuizSettings(amount: 5));

    expect(uri.host, 'opentdb.com');
    expect(uri.queryParameters, {'amount': '5', 'encode': 'url3986'});
  });

  test('includes chosen filters in the request', () {
    final uri = TriviaApi.questionsUri(
      const QuizSettings(
        categoryId: 18,
        difficulty: Difficulty.hard,
        type: QuestionType.boolean,
        amount: 20,
      ),
    );

    expect(uri.queryParameters, {
      'amount': '20',
      'category': '18',
      'difficulty': 'hard',
      'type': 'boolean',
      'encode': 'url3986',
    });
  });

  test('parses questions', () async {
    final api = TriviaApi(client: mockTrivia());
    final questions = await api.fetchQuestions(const QuizSettings());

    expect(questions.map((q) => q.text), ['Q0', 'Q1', 'Q2']);
  });

  test('maps API response codes to errors', () async {
    Future<TriviaError?> errorFor({int code = 0, int status = 200}) async {
      final api = TriviaApi(
        client: mockTrivia(responseCode: code, statusCode: status),
      );
      try {
        await api.fetchQuestions(const QuizSettings());
        return null;
      } on TriviaException catch (e) {
        return e.error;
      }
    }

    expect(await errorFor(code: 1), TriviaError.notEnoughQuestions);
    expect(await errorFor(code: 5), TriviaError.rateLimited);
    expect(await errorFor(code: 2), TriviaError.unknown);
    expect(await errorFor(status: 429), TriviaError.rateLimited);
    expect(await errorFor(status: 500), TriviaError.unknown);
  });

  test('reports network failures', () async {
    final api = TriviaApi(
      client: MockClient((_) => throw http.ClientException('offline')),
    );

    expect(
      api.fetchQuestions(const QuizSettings()),
      throwsA(
        isA<TriviaException>().having(
          (e) => e.error,
          'error',
          TriviaError.network,
        ),
      ),
    );
  });
}
