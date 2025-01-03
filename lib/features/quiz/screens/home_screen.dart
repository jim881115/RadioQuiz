import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("主頁")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz', arguments: 'level1');
              },
              child: const Text("開始 Level 1"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz', arguments: 'level2');
              },
              child: const Text("開始 Level 2"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz', arguments: 'level3');
              },
              child: const Text("開始 Level 3"),
            ),
          ],
        ),
      ),
    );
  }
}
