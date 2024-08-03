import 'package:flutter/material.dart';

import 'second.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Training',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: this.selectedLevel,
              items: [1, 2, 3].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('Level $value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                // Handle dropdown value change
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => SecondPage(level: 2)));
              },
              child: const Text("Go to Second Page"),
            ),
          ],
        ),
      ),
    );
  }
}