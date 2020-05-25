import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:quiz_it/actions/action.dart';
import 'package:quiz_it/models/quiz.dart';
import 'package:quiz_it/widgets/card.dart';

class ViewPageConnector extends StatelessWidget {
  final int initialPage;

  ViewPageConnector({
    Key key,
    this.initialPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<Quiz, ViewPageViewModel>(
      model: ViewPageViewModel(),
      builder: (BuildContext context, ViewPageViewModel vm) {
        return ViewPage(
          quiz: vm.quiz,
          initialPage: initialPage,
          markAnswer: vm.markAnswer,
        );
      },
    );
  }
}

class ViewPageViewModel extends BaseModel<Quiz> {
  Quiz quiz;
  void Function(String, int) markAnswer;

  ViewPageViewModel();

  ViewPageViewModel.build({
    @required this.quiz,
    @required this.markAnswer,
  }) : super(equals: [quiz]);

  @override
  ViewPageViewModel fromStore() {
    return ViewPageViewModel.build(
      quiz: state,
      markAnswer: (String answer, int index) {
        dispatch(MarkAnswer(answer: answer, index: index));
      },
    );
  }
}

class ViewPage extends StatelessWidget {
  final Quiz quiz;
  final int initialPage;
  final PageController controller;
  final void Function(String, int) markAnswer;

  ViewPage({
    Key key,
    @required this.quiz,
    this.initialPage,
    @required this.markAnswer,
  })  : controller = PageController(initialPage: initialPage ?? 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView.builder(
        controller: controller,
        itemCount: quiz.questions.length,
        itemBuilder: (context, index) {
          return QuestionCard(
            question: quiz.questions[index],
            index: index,
            total: quiz.questions.length,
            markAnswer: markAnswer,
          );
        },
      ),
    );
  }
}
