import 'package:flutter/material.dart';
import 'package:quiz_it/constants/amounts.dart';
import 'package:quiz_it/constants/categories.dart';
import 'package:quiz_it/constants/difficulties.dart';
import 'package:quiz_it/models/quiz.dart';

class QuestionFilter extends StatelessWidget {
  final Quiz quiz;
  final void Function(String) setCategory;
  final void Function(String) setDifficulty;
  final void Function(String) setAmount;
  final void Function() fetchQuestions;

  QuestionFilter({
    Key key,
    @required this.quiz,
    @required this.setCategory,
    @required this.setDifficulty,
    @required this.setAmount,
    @required this.fetchQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Category'),
              value: quiz.category,
              items: categories.map((item) {
                return DropdownMenuItem(
                  value: item.key,
                  child: Text(item.value),
                );
              }).toList(),
              onChanged: (newValue) {
                setCategory(newValue);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Difficulty'),
              value: quiz.difficulty,
              items: difficulties.map((item) {
                return DropdownMenuItem(
                  value: item.key,
                  child: Text(item.value),
                );
              }).toList(),
              onChanged: (newValue) {
                setDifficulty(newValue);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Number of Questions'),
              value: quiz.amount,
              items: amounts.map((item) {
                return DropdownMenuItem(
                  value: item.key,
                  child: Text(item.value),
                );
              }).toList(),
              onChanged: (newValue) {
                setAmount(newValue);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ButtonTheme(
                    height: 50,
                    minWidth: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ButtonTheme(
                    height: 50,
                    minWidth: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        fetchQuestions();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
