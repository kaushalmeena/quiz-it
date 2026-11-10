// Downloads the question bank used by the daily challenge.
//
//   dart run tool/bank.dart [count]
//
// Questions come from the Open Trivia Database (https://opentdb.com),
// licensed under CC BY-SA 4.0. They're stored as returned by the API with
// `encode=url3986`, so the app parses them with `Question.fromApi`.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _output = 'assets/daily/questions.json';
const _batch = 50;

// The API allows one question request per IP every 5 seconds.
const _pause = Duration(milliseconds: 5500);

Future<void> main(List<String> args) async {
  final target = args.isEmpty ? 1000 : int.parse(args.first);
  final client = http.Client();

  final tokenResponse = await client.get(
    Uri.https('opentdb.com', '/api_token.php', {'command': 'request'}),
  );
  final token = (json.decode(tokenResponse.body) as Map)['token'] as String;

  final questions = <Map<String, dynamic>>[];
  final seen = <String>{};

  while (questions.length < target) {
    final response = await client.get(
      Uri.https('opentdb.com', '/api.php', {
        'amount': '$_batch',
        'token': token,
        'encode': 'url3986',
      }),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;
    final code = body['response_code'];

    if (code == 5) {
      await Future<void>.delayed(_pause);
      continue;
    }
    // 1 or 4: fewer than [_batch] unseen questions left in the database.
    if (code != 0) break;

    for (final question
        in (body['results'] as List).cast<Map<String, dynamic>>()) {
      if (seen.add(question['question'] as String)) questions.add(question);
    }
    stdout.writeln('${questions.length} / $target');
    await Future<void>.delayed(_pause);
  }

  client.close();
  final file = File(_output)..createSync(recursive: true);
  file.writeAsStringSync(json.encode(questions.take(target).toList()));
  stdout.writeln(
    'Wrote ${questions.length.clamp(0, target)} questions to $_output',
  );
}
