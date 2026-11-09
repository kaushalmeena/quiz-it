import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Builds an Open Trivia Database result, percent-encoded like `encode=url3986`.
Map<String, dynamic> apiQuestion({
  String question = 'What is 2 + 2?',
  String correct = '4',
  List<String> incorrect = const ['3', '5', '22'],
  String type = 'multiple',
  String difficulty = 'easy',
  String category = 'Science: Mathematics',
}) {
  return {
    'type': type,
    'difficulty': difficulty,
    'category': Uri.encodeComponent(category),
    'question': Uri.encodeComponent(question),
    'correct_answer': Uri.encodeComponent(correct),
    'incorrect_answers': incorrect.map(Uri.encodeComponent).toList(),
  };
}

/// A mock Open Trivia Database that records every requested URL in
/// [requests].
///
/// Token requests get `token-1`, `token-2`, … and resets always succeed.
/// Question requests answer with [responseCodes] in turn (the last one
/// repeats), or [responseCode] when none are given, and [statusCode].
MockClient mockTrivia({
  int responseCode = 0,
  List<int>? responseCodes,
  List<Map<String, dynamic>>? results,
  int statusCode = 200,
  List<Uri>? requests,
}) {
  var tokens = 0;
  var questionRequests = 0;

  return MockClient((request) async {
    requests?.add(request.url);

    if (request.url.path == '/api_token.php') {
      final command = request.url.queryParameters['command'];
      return http.Response(
        json.encode({
          'response_code': 0,
          'token': command == 'request'
              ? 'token-${++tokens}'
              : request.url.queryParameters['token'],
        }),
        200,
      );
    }

    final codes = responseCodes ?? [responseCode];
    final code = codes[questionRequests.clamp(0, codes.length - 1)];
    questionRequests++;
    final body = json.encode({
      'response_code': code,
      'results': code != 0
          ? []
          : results ?? List.generate(3, (i) => apiQuestion(question: 'Q$i')),
    });
    return http.Response(body, statusCode);
  });
}

/// Only the question requests (`/api.php`) from a [mockTrivia] log.
Iterable<Uri> questionRequests(List<Uri> requests) {
  return requests.where((uri) => uri.path == '/api.php');
}
