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

  @override
  late BuildContext buildContext;

  @override
  Future<void> onLoad() async {
    debugPrint("[MyGame] onLoad started.");
    await super.onLoad();

    final bgSprite = await loadSprite('background.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: size,
      anchor: Anchor.topLeft,
    );
    add(background!);
    debugPrint("[MyGame] Background loaded and added.");

    player = Player();
    await add(player!);
    ammoNotifier.value = player!.ammo;
    debugPrint("[MyGame] Player loaded and added. Ammo: ${player!.ammo}");

    final screenSize = size;
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

    onLoadComplete?.call();
    debugPrint("[MyGame] onLoad finished, onLoadComplete callback invoked.");
  }

  @override
  void onMount() {
    debugPrint("[MyGame] onMount started.");
    super.onMount();
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
        !isNavigatingToGameOver) {
      isNavigatingToGameOver = true;
      debugPrint(
        "[MyGame] Victory Condition Met! Enemies Spawned: $enemiesSpawned, Alive Enemies: $aliveEnemies",
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        // Shortened delay
        if (buildContext.mounted) {
          debugPrint("[MyGame] Navigating to GameOverScreen (Win).");
          Navigator.of(buildContext)
              .pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const GameOverScreen(didWin: true),
                ),
              )
              .then((_) {
                debugPrint(
                  "[MyGame] Navigation to GameOver (Win) complete. Pausing and cleaning up.",
                );
                pauseEngine();
                removeAll(children.toList());
              })
              .catchError((e) {
                debugPrint(
                  "[MyGame] Error during navigation to GameOver (Win): $e",
                );
                isNavigatingToGameOver = false;
              });
        } else {
          debugPrint(
            "[MyGame] Victory: buildContext not mounted, cannot navigate.",
          );
          isNavigatingToGameOver = false;
        }
      });
    }
  }

  bool isNavigatingToGameOver = false;

  @override
  void reset() async {
    debugPrint("[MyGame] Resetting game.");
    isNavigatingToGameOver = false;
    removeAll(children.toList());
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
    super.onRemove();
  }
}
