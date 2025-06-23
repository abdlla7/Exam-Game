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
  late Sprite backgroundSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    backgroundSprite = await loadSprite('background.png');
  }

  @override
  void onMount() {
    super.onMount();

    final screenSize = size;

    background = SpriteComponent(
      sprite: backgroundSprite,
      size: screenSize,
      anchor: Anchor.topLeft,
    );
    add(background!);

    player = Player();
    add(player!);
    ammoNotifier.value = player!.ammo;

    addAll([
      EnemySpawner(
        spawnPosition: Vector2(screenSize.x - 10, screenSize.y - 50),
        spawnInterval: 2.0,
        createEnemy: () => EnemyMelee(),
      ),
      // باقي السبونرز ...
    ]);

    onLoadComplete?.call();
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
        !player.isDead) {
      pauseEngine();
      removeAll(children);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (buildContext.mounted) {
          Navigator.of(buildContext).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const GameOverScreen(didWin: true),
            ),
          );
        }
      });
    }
  }

  @override
  void reset() async {
    removeAll(children);
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
}
