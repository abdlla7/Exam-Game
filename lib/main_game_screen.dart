import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:study/mygame.dart';
import 'package:study/question_area.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  late final MyGame myGame = _initializeGame();
  bool _isPlayerReady = false;
  bool isFirst = true;

  MyGame _initializeGame() {
    debugPrint("[MainGameScreen] Initializing MyGame instance.");
    final game = MyGame();
    game.onLoadComplete = () {
      debugPrint(
        "[MainGameScreen] myGame.onLoadComplete called. Setting _isPlayerReady to true.",
      );
      if (mounted) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    };
    return game;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirst) {
      isFirst = false;
      myGame.buildContext = context;
      debugPrint(
        "[MainGameScreen] didChangeDependencies: buildContext set for MyGame.",
      );
    }
  }

  @override
  void dispose() {
    debugPrint("[MainGameScreen] Disposing MainGameScreen. Detaching game.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color(0xFF121714),
                child: ValueListenableBuilder<int>(
                  valueListenable: myGame.ammoNotifier,
                  builder: (context, ammo, _) {
                    return ClipRRect(
                      child: LinearProgressIndicator(
                        value: ammo / 30,
                        minHeight: 12,
                        backgroundColor: const Color(0xFF121714),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF38E07A),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(flex: 6, child: GameWidget(game: myGame)),
            Expanded(flex: 12, child: QuestionArea()),
          ],
        ),
      ),
    );
  }
}
