import 'package:quiz_it/models/question.dart';

class Quiz {
  bool loading;
  String error;
  String category;
  String difficulty;
  String amount;
  List<Question> questions;

  Quiz({
    this.loading,
    this.error,
    this.category,
    this.difficulty,
    this.amount,
    this.questions,
  });

  factory Quiz.initial() {
    return Quiz(
      loading: false,
      error: null,
      category: "",
      difficulty: "",
      amount: "10",
      questions: [],
    );
  }

  Quiz copy({
    bool loading,
    String error,
    String category,
    String difficulty,
    String amount,
    List<Question> questions,
  }) {
    return Quiz(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      amount: amount ?? this.amount,
      questions: questions ?? this.questions,
    );
  }
}
