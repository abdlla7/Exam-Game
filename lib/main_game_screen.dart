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
  late final MyGame myGame;
  bool _isPlayerReady = false;

  // Game instance is created here and potentially re-created on hot reload
  // if not handled carefully. Let's ensure it's truly late final.
  late final MyGame myGame = _initializeGame();
  bool _isPlayerReady = false;

  MyGame _initializeGame() {
    debugPrint("[MainGameScreen] Initializing MyGame instance.");
    final game = MyGame();
    game.onLoadComplete = () {
      debugPrint("[MainGameScreen] myGame.onLoadComplete called. Setting _isPlayerReady to true.");
      if (mounted) { // Ensure the widget is still in the tree
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
    // myGame is now initialized by its declaration.
    // We pass the context here or ensure it's set before game needs it.
    // MyGame already has a buildContext field, let's ensure it's set timely.
    // Consider passing context via constructor or a dedicated method if needed earlier than didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Assigning context here. MyGame needs to handle if it's accessed before this.
    myGame.buildContext = context;
    debugPrint("[MainGameScreen] didChangeDependencies: buildContext set for MyGame.");
  }

  @override
  void dispose() {
    debugPrint("[MainGameScreen] Disposing MainGameScreen. Detaching game.");
    // It's important that onDetach is properly implemented in FlameGame
    // to release resources and prevent errors if the game instance is reused
    // or if another GameWidget tries to attach to it.
    // Flame's default onDetach should handle listeners and basic cleanup.
    // If MyGame has custom resources that need disposing when the widget is removed,
    // they should be handled in MyGame.onRemove or a custom detach logic.
    // For now, relying on Flame's default Game lifecycle.
    // myGame.onDetach(); // This is called by GameWidget automatically.
    // Explicitly calling might be redundant or cause issues if GameWidget also calls it.
    // Let's rely on GameWidget's own disposal logic for its game instance first.
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
                  valueListenable: myGame.ammoNotifier, // myGame is accessible here
                  builder: (context, ammo, _) {
                    return ClipRRect(
                      child: LinearProgressIndicator(
                        value: ammo / 30, // Assuming max ammo is 30
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
