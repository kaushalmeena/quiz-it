import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/difficulty.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import '../models/settings.dart';

/// Client for the public Open Trivia Database API (https://opentdb.com).
///
/// Requests go through a session token, so the API never serves the same
/// question twice while the app is running. The token is requested lazily,
/// renewed when it expires and reset once every question has been seen.
class TriviaApi {
  TriviaApi({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
    this.retryDelay = const Duration(milliseconds: 5100),
    this.random,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  /// Shuffles answer order. Seed it for reproducible output (screenshots).
  final Random? random;
  final Duration timeout;

  /// The API allows one question request per IP every 5 seconds, so a retry
  /// after renewing or resetting the token has to wait this long.
  final Duration retryDelay;

  String? _token;

  static Uri questionsUri(QuizSettings settings, {String? token}) {
    return Uri.https('opentdb.com', '/api.php', {
      'amount': '${settings.amount}',
      if (settings.categoryId != null) 'category': '${settings.categoryId}',
      if (settings.difficulty != Difficulty.any)
        'difficulty': settings.difficulty.name,
      if (settings.type != QuestionType.any) 'type': settings.type.name,
      'token': ?token,
      'encode': 'url3986',
    });
  }

  static Uri tokenUri(String command, {String? token}) {
    return Uri.https('opentdb.com', '/api_token.php', {
      'command': command,
      'token': ?token,
    });
  }

  Future<List<Question>> fetchQuestions(QuizSettings settings) async {
    for (var attempt = 0; ; attempt++) {
      final token = await _sessionToken();
      final body = await _getJson(questionsUri(settings, token: token));
      final code = body['response_code'];

      // 3: token expired (6 hours idle). 4: every matching question was
      // already served. Renew or reset the token, then retry once.
      if ((code == 3 || code == 4) && token != null && attempt == 0) {
        if (code == 3) {
          _token = null;
        } else {
          await _resetToken(token);
        }
        await Future<void>.delayed(retryDelay);
        continue;
      }

      switch (code) {
        case 0:
          return (body['results'] as List)
              .cast<Map<String, dynamic>>()
              .map((json) => Question.fromApi(json, random: random))
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

  /// The current token, requesting one if needed. Returns `null` if the API
  /// won't issue one, in which case questions are fetched without it.
  Future<String?> _sessionToken() async {
    if (_token != null) return _token;
    try {
      final body = await _getJson(tokenUri('request'));
      if (body['response_code'] == 0) _token = body['token'] as String?;
    } on TriviaException catch (error) {
      if (error.error == TriviaError.network) rethrow;
    }
    return _token;
  }

  Future<void> _resetToken(String token) async {
    try {
      final body = await _getJson(tokenUri('reset', token: token));
      if (body['response_code'] != 0) _token = null;
    } on TriviaException {
      _token = null;
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
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

    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } on FormatException {
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
