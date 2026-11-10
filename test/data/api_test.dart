import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_it/data/api.dart';
import 'package:quiz_it/models/difficulty.dart';
import 'package:quiz_it/models/choices.dart';
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

  group('session token', () {
    TriviaApi createApi(MockClient client) =>
        TriviaApi(client: client, retryDelay: Duration.zero);

    test('is requested once and sent with every question request', () async {
      final requests = <Uri>[];
      final api = createApi(mockTrivia(requests: requests));

      await api.fetchQuestions(const QuizSettings());
      await api.fetchQuestions(const QuizSettings());

      expect(requests.where((uri) => uri.path == '/api_token.php'), [
        TriviaApi.tokenUri('request'),
      ]);
      expect(
        questionRequests(requests).map((uri) => uri.queryParameters['token']),
        ['token-1', 'token-1'],
      );
    });

    test('is renewed when it has expired', () async {
      final requests = <Uri>[];
      final api = createApi(
        mockTrivia(requests: requests, responseCodes: [3, 0]),
      );

      final questions = await api.fetchQuestions(const QuizSettings());

      expect(questions, hasLength(3));
      expect(
        questionRequests(requests).map((uri) => uri.queryParameters['token']),
        ['token-1', 'token-2'],
      );
    });

    test('is reset once every question has been served', () async {
      final requests = <Uri>[];
      final api = createApi(
        mockTrivia(requests: requests, responseCodes: [4, 0]),
      );

      final questions = await api.fetchQuestions(const QuizSettings());

      expect(questions, hasLength(3));
      expect(requests, contains(TriviaApi.tokenUri('reset', token: 'token-1')));
      expect(questionRequests(requests), hasLength(2));
    });

    test('retries only once', () async {
      final requests = <Uri>[];
      final api = createApi(mockTrivia(requests: requests, responseCodes: [3]));

      await expectLater(
        api.fetchQuestions(const QuizSettings()),
        throwsA(isA<TriviaException>()),
      );
      expect(questionRequests(requests), hasLength(2));
    });

    test('is skipped if the API refuses to issue one', () async {
      final requests = <Uri>[];
      final api = createApi(
        MockClient((request) async {
          requests.add(request.url);
          if (request.url.path == '/api_token.php') {
            return http.Response('oops', 500);
          }
          return http.Response(
            json.encode({
              'response_code': 0,
              'results': [apiQuestion(), apiQuestion(), apiQuestion()],
            }),
            200,
          );
        }),
      );

      final questions = await api.fetchQuestions(const QuizSettings());

      expect(questions, hasLength(3));
      expect(
        questionRequests(requests).single.queryParameters,
        isNot(contains('token')),
      );
    });
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
