import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/difficulty.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import '../models/settings.dart';

/// Client for the public Open Trivia Database API (https://opentdb.com).
class TriviaApi {
  TriviaApi({http.Client? client, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static Uri questionsUri(QuizSettings settings) {
    return Uri.https('opentdb.com', '/api.php', {
      'amount': '${settings.amount}',
      if (settings.categoryId != null) 'category': '${settings.categoryId}',
      if (settings.difficulty != Difficulty.any)
        'difficulty': settings.difficulty.name,
      if (settings.type != QuestionType.any) 'type': settings.type.name,
      'encode': 'url3986',
    });
  }

  Future<List<Question>> fetchQuestions(QuizSettings settings) async {
    final http.Response response;
    try {
      response = await _client.get(questionsUri(settings)).timeout(timeout);
    } on TimeoutException {
      throw const TriviaException(TriviaError.network);
    } on http.ClientException {
      throw const TriviaException(TriviaError.network);
    }

    if (response.statusCode == 429) {
      throw const TriviaException(TriviaError.rateLimited);
    }
    if (response.statusCode != 200) {
      throw const TriviaException(TriviaError.unknown);
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    switch (body['response_code']) {
      case 0:
        return (body['results'] as List)
            .cast<Map<String, dynamic>>()
            .map(Question.fromApi)
            .toList(growable: false);
      case 1:
        throw const TriviaException(TriviaError.notEnoughQuestions);
      case 5:
        throw const TriviaException(TriviaError.rateLimited);
      default:
        throw const TriviaException(TriviaError.unknown);
    }
  }
}

enum TriviaError {
  network(
    "Couldn't reach the trivia server. Check your connection and try again.",
  ),
  notEnoughQuestions(
    'Not enough questions for these options. Try fewer questions or a different difficulty.',
  ),
  rateLimited('Too many requests. Wait a few seconds and try again.'),
  unknown('Something went wrong while loading questions. Please try again.');

  const TriviaError(this.message);

  final String message;
}

class TriviaException implements Exception {
  const TriviaException(this.error);

  final TriviaError error;

  String get message => error.message;

  @override
  String toString() => 'TriviaException(${error.name})';
}
