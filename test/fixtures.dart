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

/// A mock client that answers every request with the given body, and records
/// the requested URLs in [requests].
MockClient mockTrivia({
  int responseCode = 0,
  List<Map<String, dynamic>>? results,
  int statusCode = 200,
  List<Uri>? requests,
}) {
  return MockClient((request) async {
    requests?.add(request.url);
    final body = json.encode({
      'response_code': responseCode,
      'results':
          results ?? List.generate(3, (i) => apiQuestion(question: 'Q$i')),
    });
    return http.Response(body, statusCode);
  });
}
