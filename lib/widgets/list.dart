import 'package:flutter/material.dart';
import 'package:quiz_it/constants/state.dart';
import 'package:quiz_it/models/quiz.dart';
import 'package:quiz_it/screens/view.dart';

class QuestionList extends StatelessWidget {
  final Quiz quiz;

  QuestionList({Key key, @required this.quiz}) : super(key: key);

  getValueAccoringQuestionState(
    int index,
    value1,
    value2,
    value3,
  ) {
    switch (quiz.questions[index].state) {
      case QuestionState.UNANSWERED:
        return value1;
      case QuestionState.RIGHT_ANSWERED:
        return value2;
      case QuestionState.WRONG_ANSWERED:
        return value3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: quiz.questions.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ViewPageConnector(initialPage: index);
                },
              ),
            );
          },
          child: Card(
            color: getValueAccoringQuestionState(
              index,
              Colors.white,
              Colors.green[100],
              Colors.red[100],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Icon(
                      getValueAccoringQuestionState(
                        index,
                        Icons.help_outline,
                        Icons.check_circle_outline,
                        Icons.highlight_off,
                      ),
                      size: 32,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              quiz.questions[index].question,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 8,
                            children: [
                              Text(
                                quiz.questions[index].category,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Text(
                                quiz.questions[index].difficulty,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
