import 'package:flutter/material.dart';
import 'main_menu_screen.dart'; // For vibration control

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Mania',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainMenuScreen(),
    );
  }
}




