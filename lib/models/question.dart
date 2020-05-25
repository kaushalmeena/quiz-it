import 'package:quiz_it/constants/state.dart';

class Question {
  String category;
  String type;
  String difficulty;
  String question;
  String correctAnswer;
  String markedAnswer;
  List<String> incorrectAnswers;
  List<String> allAnswers;
  QuestionState state;

  Question({
    this.category,
    this.type,
    this.difficulty,
    this.question,
    this.correctAnswer,
    this.markedAnswer,
    this.incorrectAnswers,
    this.allAnswers,
    this.state,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String category = json['category'];
    String type = json['type'];
    String difficulty = json['difficulty'].toString().toUpperCase();
    String question = json['question'];
    String correctAnswer = json['correct_answer'];
    List<String> incorrectAnswers = json['incorrect_answers'].cast<String>();

    List<String> allAnswers = List.from(incorrectAnswers);
    allAnswers.add(correctAnswer);
    allAnswers.shuffle();

    return Question(
      category: category,
      type: type,
      difficulty: difficulty,
      question: question,
      correctAnswer: correctAnswer,
      markedAnswer: null,
      incorrectAnswers: incorrectAnswers,
      allAnswers: allAnswers,
      state: QuestionState.UNANSWERED,
    );
  }
}
