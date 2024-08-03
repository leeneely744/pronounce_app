import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 200.0,
                width: 200.0,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                color: Colors.yellow,
                height: 200,
                width: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                color: Colors.red,
                height: 200,
                width: 200,
              ),
            )
          ],
        )  
    );
  }
}