import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:quiz_it/actions/action.dart';
import 'package:quiz_it/models/quiz.dart';
import 'package:quiz_it/widgets/list.dart';
import 'package:quiz_it/widgets/filter.dart';

class HomePageConnector extends StatelessWidget {
  HomePageConnector({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<Quiz, HomePageViewModel>(
      model: HomePageViewModel(),
      onInit: (store) {
        store.dispatch(FetchQuestions());
      },
      builder: (BuildContext context, HomePageViewModel vm) {
        return HomePage(
          quiz: vm.quiz,
          setCategory: vm.setCategory,
          setDifficulty: vm.setDifficulty,
          setAmount: vm.setAmount,
          fetchQuestions: vm.fetchQuestions,
          fetchQuestionsFuture: vm.fetchQuestionsFuture,
        );
      },
    );
  }
}

class HomePageViewModel extends BaseModel<Quiz> {
  Quiz quiz;
  void Function(String) setCategory;
  void Function(String) setDifficulty;
  void Function(String) setAmount;
  void Function() fetchQuestions;
  Future<void> Function() fetchQuestionsFuture;

  HomePageViewModel();

  HomePageViewModel.build({
    @required this.quiz,
    @required this.setCategory,
    @required this.setDifficulty,
    @required this.setAmount,
    @required this.fetchQuestions,
    @required this.fetchQuestionsFuture,
  }) : super(equals: [quiz]);

  @override
  HomePageViewModel fromStore() {
    return HomePageViewModel.build(
      quiz: state,
      setCategory: (String category) {
        dispatch(SetCategory(category: category));
      },
      setDifficulty: (String difficulty) {
        dispatch(SetDifficulty(difficulty: difficulty));
      },
      setAmount: (String amount) {
        dispatch(SetAmount(amount: amount));
      },
      fetchQuestions: () {
        dispatch(FetchQuestions());
      },
      fetchQuestionsFuture: () {
        return dispatchFuture(FetchQuestions());
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final Quiz quiz;
  final void Function(String) setCategory;
  final void Function(String) setDifficulty;
  final void Function(String) setAmount;
  final void Function() fetchQuestions;
  final Future<void> Function() fetchQuestionsFuture;

  HomePage({
    Key key,
    @required this.quiz,
    @required this.setCategory,
    @required this.setDifficulty,
    @required this.setAmount,
    @required this.fetchQuestions,
    @required this.fetchQuestionsFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("QuizIt"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestionsFuture,
        child: quiz.loading
            ? Center(child: CircularProgressIndicator())
            : QuestionList(quiz: quiz),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return QuestionFilter(
                quiz: quiz,
                setCategory: setCategory,
                setDifficulty: setDifficulty,
                setAmount: setAmount,
                fetchQuestions: fetchQuestions,
              );
            },
          );
        },
        child: Icon(Icons.filter_list),
      ),
    );
  }
}
