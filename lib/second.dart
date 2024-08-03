import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final int level;

  SecondPage({required this.level});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "レベル${this.level}です",
              style: TextStyle(fontSize: 40),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("戻る")
            )
          ],
        )
      )
    );
  }
}