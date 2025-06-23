import 'package:flutter/material.dart';
import 'package:study/start_screen.dart';
import 'package:study/overlays/game_over.dart';
import 'package:study/main_game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Game',
      theme: ThemeData.dark(),
      // ✅ تعريف المسارات
      routes: {
        '/': (context) => const StartScreen(),
        '/gameover': (context) => const GameOverScreen(didWin: false),
        '/game': (context) => const MainGameScreen(),
      },
    );
  }
}
