import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_it/screens/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomePageConnector();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset(
          'image/splash.png',
          height: 138,
          width: 252,
        ),
      ),
    );
  }
}
