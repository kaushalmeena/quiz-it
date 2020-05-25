import 'package:async_redux/async_redux.dart';
import 'package:quiz_it/actions/action.dart';
import 'package:quiz_it/constants/state.dart';
import 'package:quiz_it/models/quiz.dart';
import "package:test/test.dart";

void main() {
  dynamic storeTester;
  dynamic temp;

  test('Initial store state', () {
    storeTester = StoreTester<Quiz>(initialState: Quiz.initial());

    expect(storeTester.state.loading, false);
    expect(storeTester.state.error, null);
    expect(storeTester.state.questions, []);
    expect(storeTester.state.category, "");
    expect(storeTester.state.difficulty, "");
    expect(storeTester.state.amount, "10");
  });

  test('Check hide and show loader actions', () async {
    storeTester = StoreTester<Quiz>(initialState: Quiz.initial());

    expect(storeTester.state.loading, false);

    storeTester.dispatch(ShowLoader());
    temp = await storeTester.wait(ShowLoader);
    expect(temp.state.loading, true);

    storeTester.dispatch(HideLoader());
    temp = await storeTester.wait(HideLoader);
    expect(temp.state.loading, false);
  });

  test('Check set category action', () async {
    storeTester = StoreTester<Quiz>(initialState: Quiz.initial());

    expect(storeTester.state.category, "");

    storeTester.dispatch(SetCategory(category: "10"));
    temp = await storeTester.wait(SetCategory);
    expect(temp.state.category, "10");
  });

  test('Check set difficulty action', () async {
    storeTester = StoreTester<Quiz>(initialState: Quiz.initial());

    expect(storeTester.state.difficulty, "");

    storeTester.dispatch(SetDifficulty(difficulty: "easy"));
    temp = await storeTester.wait(SetDifficulty);
    expect(temp.state.difficulty, "easy");
  });

  test('Check set amount action', () async {
    storeTester = StoreTester<Quiz>(initialState: Quiz.initial());

    expect(storeTester.state.amount, "10");

    storeTester.dispatch(SetAmount(amount: "20"));
    temp = await storeTester.wait(SetAmount);
    expect(temp.state.amount, "20");
  });

  test('Check fetch questions and mark answer actions', () async {
    storeTester = StoreTester<Quiz>(initialState: Quiz.initial());

    expect(storeTester.state.questions, []);

    storeTester.dispatch(FetchQuestions());
    temp = await storeTester.waitAll([FetchQuestions, ShowLoader, HideLoader]);
    temp = temp.get(HideLoader, 1);
    expect(temp.state.questions, isNotEmpty);

    storeTester.dispatch(MarkAnswer(answer: "RandomAnswer", index: 0));
    temp = await storeTester.wait(MarkAnswer);
    expect(temp.state.questions[0].state, equals(QuestionState.WRONG_ANSWERED));
  });
}
