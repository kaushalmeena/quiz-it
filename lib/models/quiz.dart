import 'package:quiz_it/models/question.dart';

class Quiz {
  bool loading;
  String error;
  List<Question> questions;
  String category;
  String difficulty;
  String amount;

  Quiz({
    this.loading,
    this.error,
    this.questions,
    this.category,
    this.difficulty,
    this.amount,
  });

  factory Quiz.initial() {
    return Quiz(
      loading: false,
      error: null,
      questions: [],
      category: "",
      difficulty: "",
      amount: "10",
    );
  }

  Quiz copy({
    bool loading,
    String error,
    List<Question> questions,
    String category,
    String difficulty,
    String amount,
  }) {
    return Quiz(
        loading: loading ?? this.loading,
        error: error ?? this.error,
        questions: questions ?? this.questions,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        amount: amount ?? this.amount);
  }
}
