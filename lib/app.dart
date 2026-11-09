import 'package:flutter/material.dart';

import 'screens/home/home.dart';
import 'theme/theme.dart';

class QuizItApp extends StatelessWidget {
  const QuizItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz-It',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}
