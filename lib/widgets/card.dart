import 'package:flutter/material.dart';
import 'package:quiz_it/constants/state.dart';
import 'package:quiz_it/models/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final int total;
  final void Function(String, int) markAnswer;

  QuestionCard({
    Key key,
    @required this.question,
    @required this.index,
    @required this.total,
    @required this.markAnswer,
  }) : super(key: key);

  getValueAccoringQuestionState(
    value1,
    value2,
    value3,
  ) {
    switch (question.state) {
      case QuestionState.UNANSWERED:
        return value1;
      case QuestionState.RIGHT_ANSWERED:
        return value2;
      case QuestionState.WRONG_ANSWERED:
        return value3;
    }
  }

  getDisabledColor(int index) {
    if (question.state == QuestionState.RIGHT_ANSWERED &&
            question.allAnswers[index] == question.markedAnswer ||
        question.state == QuestionState.WRONG_ANSWERED &&
            question.allAnswers[index] == question.correctAnswer) {
      return Colors.green[200];
    }
    if (question.state == QuestionState.WRONG_ANSWERED &&
        question.allAnswers[index] == question.markedAnswer) {
      return Colors.red[200];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Card(
        color: getValueAccoringQuestionState(
          Colors.white,
          Colors.green[100],
          Colors.red[100],
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Text(
                      '/$total',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Text(
                  question.category,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  question.difficulty,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Icon(
                    getValueAccoringQuestionState(
                      Icons.help_outline,
                      Icons.check_circle_outline,
                      Icons.highlight_off,
                    ),
                    size: 80,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.allAnswers.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ButtonTheme(
                          height: 50,
                          disabledColor: getDisabledColor(index),
                          child: RaisedButton(
                            onPressed: question.state ==
                                    QuestionState.UNANSWERED
                                ? () {
                                    markAnswer(
                                        question.allAnswers[index], this.index);
                                  }
                                : null,
                            child: Text(
                              question.allAnswers[index],
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    question.state == QuestionState.UNANSWERED
                                        ? Colors.white
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
