import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:study/overlays/game_over.dart';
import 'components/player.dart';
import 'components/enemy_spawner.dart';
import 'components/enemy.dart';
import 'components/slime.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  VoidCallback? onLoadComplete;
  ValueNotifier<int> ammoNotifier = ValueNotifier(0);
  Player? player;
  SpriteComponent? background;
  int totalEnemiesToSpawn = 50;
  int enemiesSpawned = 0;

  late BuildContext buildContext; // Keep this if used for navigation, ensure it's valid

  // late Sprite backgroundSprite; // No longer needed as direct field if loaded and used in onLoad

  @override
  Future<void> onLoad() async {
    debugPrint("[MyGame] onLoad started.");
    await super.onLoad();

    // Load assets directly here
    final bgSprite = await loadSprite('background.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: size, // Size might not be correct here yet, onGameResize is better
      anchor: Anchor.topLeft,
    );
    add(background!);
    debugPrint("[MyGame] Background loaded and added.");

    player = Player();
    await add(player!); // Ensure player's onLoad completes
    ammoNotifier.value = player!.ammo;
    debugPrint("[MyGame] Player loaded and added. Ammo: ${player!.ammo}");

    // Consider moving Spawner setup to onGameResize or after initial size is known
    // For now, let's assume size is available or they adapt.
    final screenSize = size; // size should be available after super.onLoad
     addAll([
      EnemySpawner(
        spawnPosition: Vector2(screenSize.x - 10, screenSize.y - 50),
        spawnInterval: 2.0,
        createEnemy: () => EnemyMelee(),
      ),
       EnemySpawner(
        spawnPosition: Vector2(0, screenSize.y - 50),
        spawnInterval: 3.0,
        createEnemy: () => EnemyMelee(),
      ),
      EnemySpawner(
        spawnPosition: Vector2(screenSize.x - 10, screenSize.y / 2),
        spawnInterval: 2.0,
        createEnemy: () => Enemy(),
      ),
      EnemySpawner(
        spawnPosition: Vector2(0, screenSize.y / 2),
        spawnInterval: 3.0,
        createEnemy: () => Enemy(),
      ),
    ]);
    debugPrint("[MyGame] EnemySpawners added.");

    // Call onLoadComplete after all essential async operations in onLoad are done
    // and components are added.
    onLoadComplete?.call();
    debugPrint("[MyGame] onLoad finished, onLoadComplete callback invoked.");
  }

  @override
  void onMount() {
    debugPrint("[MyGame] onMount started.");
    super.onMount();
    // Most initialization is now in onLoad.
    // onMount is suitable for things that must happen after the game is in the widget tree
    // but before the first update, if any.
    // If `size` is critical for initial layout and not reliably set before/during `onLoad`,
    // some component additions might be better here or in `onGameResize`.
    // However, Flame usually guarantees `size` is available after `super.onLoad()`.
    debugPrint("[MyGame] onMount finished.");
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    camera.viewport = FixedResolutionViewport(resolution: canvasSize);
    background?.size = canvasSize;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = this.player;
    if (player != null && player.isMounted && !player.isDead) {
      player.shootNearestEnemy(this);
    }

    final aliveEnemies =
        children.whereType<Enemy>().where((e) => !e.isDying).length +
        children.whereType<EnemyMelee>().length;

    if (enemiesSpawned >= totalEnemiesToSpawn &&
        aliveEnemies == 0 &&
        player != null &&
        !player.isDead &&
        !isNavigatingToGameOver) { // Prevent multiple navigation attempts
      isNavigatingToGameOver = true; // Set flag
      debugPrint("[MyGame] Victory Condition Met! Enemies Spawned: $enemiesSpawned, Alive Enemies: $aliveEnemies");

      // Try to navigate first.
      // Consider passing a specific navigation callback from MainGameScreen
      // to make this cleaner and less reliant on MyGame holding a BuildContext.
      // For now, we'll use the existing buildContext with checks.

      Future.delayed(const Duration(milliseconds: 100), () { // Shortened delay
        if (buildContext.mounted) {
          debugPrint("[MyGame] Navigating to GameOverScreen (Win).");
          Navigator.of(buildContext).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const GameOverScreen(didWin: true),
            ),
          ).then((_) {
            // After navigation, then pause and clean up.
            // This might be too late if navigation takes time or fails.
            // A better pattern is often to show an overlay *within* the GameWidget managed by MyGame,
            // and then have that overlay trigger navigation via a callback.
            // For now, let's proceed with this slightly modified flow.
            debugPrint("[MyGame] Navigation to GameOver (Win) complete. Pausing and cleaning up.");
            pauseEngine();
            removeAll(children.toList()); // Ensure we operate on a copy if modifying during iteration
          }).catchError((e) {
            debugPrint("[MyGame] Error during navigation to GameOver (Win): $e");
            isNavigatingToGameOver = false; // Reset flag on error
            // Optionally, try to pause/clean again or handle error
          });
        } else {
          debugPrint("[MyGame] Victory: buildContext not mounted, cannot navigate.");
          isNavigatingToGameOver = false; // Reset flag
        }
      });
    }
  }

  bool isNavigatingToGameOver = false; // Add this flag

  @override
  void reset() async {
    debugPrint("[MyGame] Resetting game.");
    isNavigatingToGameOver = false; // Reset navigation flag
    removeAll(children.toList()); // Use toList() to avoid issues if children list is modified during removal
    enemiesSpawned = 0;

    final sprite = await loadSprite('background.png');
    background = SpriteComponent(
      sprite: sprite,
      size: size,
      anchor: Anchor.topLeft,
    );
    add(background!);

    player = Player();
    await add(player!);
    ammoNotifier.value = player!.ammo;

    addAll([
      EnemySpawner(
        spawnPosition: Vector2(size.x - 10, size.y - 50),
        spawnInterval: 2.0,
        createEnemy: () => EnemyMelee(),
      ),
      EnemySpawner(
        spawnPosition: Vector2(0, size.y - 50),
        spawnInterval: 3.0,
        createEnemy: () => EnemyMelee(),
      ),
      EnemySpawner(
        spawnPosition: Vector2(size.x - 10, size.y / 2),
        spawnInterval: 2.0,
        createEnemy: () => Enemy(),
      ),
      EnemySpawner(
        spawnPosition: Vector2(0, size.y / 2),
        spawnInterval: 3.0,
        createEnemy: () => Enemy(),
      ),
    ]);
  }

  @override
  void onRemove() {
    debugPrint("[MyGame] onRemove called. Game is being detached.");
    // Perform any specific cleanup for MyGame's resources here if needed.
    // For example, if you manually started timers or streams that aren't
    // Flame components, they might need to be cancelled/closed.
    // ammoNotifier is a ValueNotifier. If it's not used elsewhere after the game
    // is removed, it could be disposed here. However, if MainGameScreen might
    // still listen to it briefly during transitions, defer disposal or ensure
    // listeners are removed. Given it's part of MyGame, and MyGame is disposed
    // with the screen state, it should be okay.
    super.onRemove(); // Important to call super.onRemove()
  }
}
