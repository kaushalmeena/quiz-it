import 'package:flutter/material.dart';
import 'package:quiz_it/screens/home.dart';

void main() {
  runApp(QuizIt());
}

class QuizIt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
