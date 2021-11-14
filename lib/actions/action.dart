import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async_redux/async_redux.dart';
import 'package:quiz_it/constants/state.dart';
import 'package:quiz_it/models/quiz.dart';
import 'package:quiz_it/models/question.dart';

class HideLoader extends ReduxAction<Quiz> {
  @override
  Quiz reduce() {
    return state.copy(loading: false);
  }
}

class ShowLoader extends ReduxAction<Quiz> {
  @override
  Quiz reduce() {
    return state.copy(loading: true);
  }
}

class FetchQuestions extends ReduxAction<Quiz> {
  @override
  Future<Quiz> reduce() async {
    var url = Uri.parse(
        'https://opentdb.com/api.php?amount=${state.amount}&category=${state.category}&difficulty=${state.difficulty}');
    dynamic response = await http.get(url);
    dynamic data = json.decode(response.body);

    if (data['response_code'] != 0) {
      throw const UserException("Error occured while fetching questions.");
    }

    List<Question> questions = [];

    data['results'].forEach((item) {
      questions.add(Question.fromJson(item));
    });

    return state.copy(questions: questions);
  }

  void before() {
    dispatch(ShowLoader());
  }

  void after() {
    dispatch(HideLoader());
  }
}

class MarkAnswer extends ReduxAction<Quiz> {
  String answer;
  int index;

  MarkAnswer({
    this.answer,
    this.index,
  });

  @override
  Quiz reduce() {
    state.questions[index].markedAnswer = answer;
    state.questions[index].state =
        answer == state.questions[index].correctAnswer
            ? QuestionState.RIGHT_ANSWERED
            : QuestionState.WRONG_ANSWERED;

    return state.copy(questions: state.questions);
  }
}

class SetCategory extends ReduxAction<Quiz> {
  String category;

  SetCategory({
    this.category,
  });

  @override
  Quiz reduce() {
    return state.copy(category: category);
  }
}

class SetDifficulty extends ReduxAction<Quiz> {
  String difficulty;

  SetDifficulty({
    this.difficulty,
  });

  @override
  Quiz reduce() {
    return state.copy(difficulty: difficulty);
  }
}

class SetAmount extends ReduxAction<Quiz> {
  String amount;

  SetAmount({
    this.amount,
  });

  @override
  Quiz reduce() {
    return state.copy(amount: amount);
  }
}
