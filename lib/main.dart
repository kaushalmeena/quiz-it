import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:quiz_it/models/quiz.dart';
import 'package:quiz_it/screens/splash.dart';

Store<Quiz> store;

void main() {
  store = Store<Quiz>(
    initialState: Quiz.initial(),
  );
  runApp(QuizIt());
}

class QuizIt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<Quiz>(
      store: store,
      child: MaterialApp(
        title: 'QuizIt',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
