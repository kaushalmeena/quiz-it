import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("QuizIt"),
      ),
      body: BodyLayout(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: Icon(Icons.filter_list),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  final titles = [
    'bike',
    'boat',
    'bus',
    'car',
    'railway',
    'run',
    'subway',
    'transit',
    'walk'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.access_alarm),
            title: Text(titles[index]),
          ),
        );
      },
    );
  }
}
